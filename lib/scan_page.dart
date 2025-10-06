import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart'; // for access to cameras list

enum FlashStatus { none, found, notFound }

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  List<Map<String, dynamic>> _triggerIngredients = [];
  final List<String> _scanHistory = [];
  String _scanResult = '';
  bool _isDetecting = false;
  FlashStatus _flashStatus = FlashStatus.none;
  String _selectedTriggerType = 'dairy';

  @override
  void initState() {
    super.initState();
    _loadTriggerIngredients();
    _loadScanHistory();
    _initializeCamera();
    testManualScan();
  }

  void _triggerFlash(bool foundTrigger) {
    setState(() {
      _flashStatus = foundTrigger ? FlashStatus.found : FlashStatus.notFound;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _flashStatus = FlashStatus.none;
      });
    });
  }

  void _updateTriggerType(String type) {
    setState(() {
      _selectedTriggerType = type;
    });
    _loadTriggerIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('AcnErase'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'About') {
                    _navigateTo(
                      'About AcnErase',
                      'Veteran-founded in Alberta, Canada. Contact: 403-853-8481 | acnerase@gmail.com',
                    );
                  } else if (value == 'Evidence') {
                    _navigateTo('Science Behind AcnErase', 'This app is built on the immune-response theory of acne genesis...');
                  } else if (value == 'History') {
                    _navigateTo('Scan History', _scanHistory.join('\n'));
                  } else if (value == 'Register') {
                    _navigateToRegister();
                  } else if (value == 'Share') {
                    _shareResults();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'About', child: Text('About')),
                  PopupMenuItem(value: 'Evidence', child: Text('Evidence')),
                  PopupMenuItem(value: 'History', child: Text('Scan History')),
                  PopupMenuItem(value: 'Register', child: Text('Register')),
                  PopupMenuItem(value: 'Share', child: Text('Share Results')),
                ],
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('Dairy/Beef'),
                      selected: _selectedTriggerType == 'dairy',
                      onSelected: (selected) {
                        if (selected) _updateTriggerType('dairy');
                      },
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Wheat/Gluten'),
                      selected: _selectedTriggerType == 'gluten',
                      onSelected: (selected) {
                        if (selected) _updateTriggerType('gluten');
                      },
                    ),
                  ],
                ),
                if (_cameraController != null && _cameraController!.value.isInitialized)
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                const SizedBox(height: 12),
                Text(_scanResult, style: const TextStyle(fontSize: 18, color: Colors.red)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _performScan,
                  child: const Text('Scan Ingredient Label'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (_flashStatus != FlashStatus.none)
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              color: _flashStatus == FlashStatus.found
                  ? Colors.red.withOpacity(0.5)
                  : Colors.green.withOpacity(0.5),
            ),
          ),
      ],
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = cameras;
    if (_cameras.isEmpty) return;
    _cameraController = CameraController(_cameras[0], ResolutionPreset.veryHigh);
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadTriggerIngredients() async {
    List<Map<String, dynamic>> loadedTriggers = [];

    if (_selectedTriggerType == 'dairy') {
      final dairyJson = await rootBundle.loadString('assets/dairy_acne_trigger_ingredients.json');
      loadedTriggers = List<Map<String, dynamic>>.from(json.decode(dairyJson));
    } else if (_selectedTriggerType == 'gluten') {
      final glutenJson = await rootBundle.loadString('assets/gluten_acne_trigger_ingredients.json');
      loadedTriggers = List<Map<String, dynamic>>.from(json.decode(glutenJson));
    }

    setState(() {
      _triggerIngredients = loadedTriggers;
    });
  }

  Future<void> _loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _scanHistory.clear();
      _scanHistory.addAll(prefs.getStringList('scanHistory') ?? []);
    });
  }

  Future<void> _saveScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('scanHistory', _scanHistory);
  }

  Future<void> _performScan() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isDetecting) return;
    _isDetecting = true;
    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      _processScanResult(recognizedText.text);
    } catch (e) {
      print('Scan error: $e');
    } finally {
      _isDetecting = false;
    }
  }

  void testManualScan() {
    final fakeLabel = 'INGREDIENTS: Salt, Milk, Natural Flavour, Caramel Colour, Spices';
    _processScanResult(fakeLabel);
  }

  void _processScanResult(String text) {
    final cleanedText = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    final foundIngredients = <String>[];
    for (var trigger in _triggerIngredients) {
      final triggerName = trigger['visible_name']?.toString().toLowerCase();
      if (triggerName == null || triggerName.isEmpty) continue;
      final triggerPhrase = triggerName.replaceAll(RegExp(r'\s+'), ' ').trim();

      if (cleanedText.contains(triggerPhrase)) {
        foundIngredients.add(triggerName);
      }
    }

    setState(() {
      if (foundIngredients.isNotEmpty) {
        _scanResult = 'Acne Triggers Identified As Below:\n- ${foundIngredients.join('\n- ')}';
        _scanHistory.add('Triggers found: ${foundIngredients.join(', ')}');
      } else {
        _scanResult = 'No known acne triggers found.';
      }
    });

    _saveScanHistory();
  }

  void _navigateTo(String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage(title: title, content: content)),
    );
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegistrationPage()),
    );
  }

  void _shareResults() {
    if (_scanResult.isNotEmpty) {
      Share.share(_scanResult, subject: 'AcnErase Scan Result');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }
}

class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(content, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> _submitRegistration() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'acnerase@gmail.com',
      queryParameters: {
        'subject': 'AcnErase Registration',
        'body': 'Name: $name\nEmail: $email',
      },
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email client.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitRegistration,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
