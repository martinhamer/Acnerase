import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart'; // ✅ ADD THIS LINE
import 'pages/splash_screen.dart';
import 'pages/evidence_page.dart';
import 'pages/register_page.dart';
import 'scan_page.dart';
import 'pages/purging_diet_page.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AcnErase Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),

      // ✅ REVERTING TO ORIGINAL SPLASH SCREEN
      home: Builder(
        builder: (context) {
          return SplashScreen(
            onContinue: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            },
          );
        },
      ),
    );
  }
}

enum FlashStatus { none, found, notFound }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  List<Map<String, dynamic>> _triggerIngredients = [];
  final List<String> _scanHistory = [];
  String _scanResult = '';
  bool _isDetecting = false;
  FlashStatus _flashStatus = FlashStatus.none;
  String _selectedTriggerType = 'dairy';

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _navigateToEvidence() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EvidencePage()),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTriggerIngredients();
    _loadScanHistory();
    _initializeCamera();
    testManualScan();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera(); // Re-initialize when returning
    }
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
    return Scaffold(
      appBar: AppBar(
        title: Text('AcnErase'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'About') {
                _navigateTo(
                    'About AcnErase',
                    '''
Now 70 years old, I have lived through severe, scarring acne, persistent rosacea, and relentless breakouts triggered by wheat and gluten. 
The shame, frustration, and isolation I felt are still vivid — especially when nothing seemed to help.

My name is Martin Hamer, and I know firsthand the emotional toll that acne can take.

I created Acnerase not as a business, but as a mission. With no formal training in coding, no budget, and no roadmap, I built this app because I *had to*. 
For over 22 years, I've studied the overlooked connection between certain ingredients — like Neu5Gc and gluten — and chronic acne. 
I believe that understanding this link could spare countless people from physical pain and the silent mental suffering that so often follows.

This app is completely free. No ads. No upsells. Just a focused, educational tool for those seeking answers. 
If Acnerase helps even one young person step back from the edge of despair or reclaim a sense of hope, then every hour spent developing it has been worth it.

Acnerase isn't just about clear skin. It's about healing, understanding, and preventing suffering — especially for those who feel forgotten.

---

**Note on Ambiguous Ingredients:**  
Some ingredients such as “natural flavors,” “calcium,” or “salt” may or may not be dairy-derived. Unless the product clearly states “Vegan,” “Parve,” or “Parev,” please assume dairy may be present. This cautious approach helps protect acne-prone skin from hidden dairy triggers.
'''
                );
              } else if (value == 'Evidence') {
                _navigateToEvidence();
              } else if (value == 'History') {
                _navigateTo('Scan History', _scanHistory.join('\n'));
              } else if (value == 'Register') {
                _navigateToRegister();
              } else if (value == 'PurgeDiet') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PurgingDietPage()),
                );
              } else if (value == 'Share') {
                _shareResults();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'About', child: Text('About')),
              const PopupMenuItem(value: 'Evidence', child: Text('Evidence')),
              const PopupMenuItem(value: 'History', child: Text('Scan History')),
              const PopupMenuItem(value: 'Register', child: Text('Register')),
              const PopupMenuItem(value: 'PurgeDiet', child: Text('7-Day Purge Diet')),
              const PopupMenuItem(value: 'Share', child: Text('Share Results')),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text('Dairy/Beef'),
                      selected: _selectedTriggerType == 'dairy',
                      onSelected: (selected) {
                        if (selected) _updateTriggerType('dairy');
                      },
                    ),
                    SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Wheat/Gluten'),
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
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                SizedBox(height: 12),
                Text(_scanResult, style: TextStyle(fontSize: 18, color: Colors.red)),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _performScan,
                  child: Text('Scan Ingredient Label'),
                ),
                SizedBox(height: 12),
              ],
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
      ),
    );
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
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

      // Looser matching with 'contains' instead of regex whole word match
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

  void _shareResults() {
    if (_scanResult.isNotEmpty) {
      Share.share(_scanResult, subject: 'AcnErase Scan Result');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_cameraController != null) {
      if (_cameraController!.value.isInitialized) {
        _cameraController!.dispose();
      }
    }
    _textRecognizer.close();
    super.dispose();
  }
} // end of _HomePageState

// InfoPage class

class InfoPage extends StatelessWidget {
  final String title;
  final String content;

  const InfoPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 48), // Extra space at bottom
        child: Text(content, style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

// RegisterPage and state

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSfJRpAaYlvGeeh4LDkQ17kPFieHplE9XT_Eb4eZlCGQQOsZww/viewform?usp=header'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}















