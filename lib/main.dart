import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AcnErase',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final List<String> _triggerIngredients = [];
  final List<String> _scanHistory = [];
  String _scanResult = '';
  CameraController? _cameraController;
  bool _isDetecting = false;

  @override
  void initState() {
    super.initState();
    _loadTriggerIngredients();
    _loadScanHistory();
    _initializeCamera();
  }

  Future<void> _loadTriggerIngredients() async {
    final jsonString = await rootBundle.loadString('assets/trigger_ingredients.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    setState(() {
      _triggerIngredients.clear();
      _triggerIngredients.addAll(jsonList.map((e) => e.toString().toLowerCase()));
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

  void _initializeCamera() {
    if (_cameras.isEmpty) return;
    _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    _cameraController!.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
      _cameraController!.startImageStream((CameraImage image) async {
        if (_isDetecting) return;
        _isDetecting = true;
        try {
          final inputImage = convertCameraImage(image);
          final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
          _processScanResult(recognizedText.text);
        } catch (e) {
          print('Error detecting text: $e');
        } finally {
          _isDetecting = false;
        }
      });
    });
  }

  InputImage convertCameraImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,  // Adjust if needed
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  void _processScanResult(String text) {
    final foundIngredients = <String>[];
    final words = text.toLowerCase().split(RegExp(r'[\s,;:\n]'));
    for (final word in words) {
      if (_triggerIngredients.any((ingredient) => word.contains(ingredient))) {
        foundIngredients.add(word);
      }
    }

    if (foundIngredients.isNotEmpty) {
      final result = 'Triggers found: ${foundIngredients.join(', ')}';
      setState(() {
        _scanResult = result;
        _scanHistory.add(result);
      });
      _saveScanHistory();
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('AcnErase')),
      body: Column(
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: _cameraController!.value.aspectRatio,
              child: CameraPreview(_cameraController!),
            )
          else
            CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(_scanResult, style: TextStyle(fontSize: 18)),
          Expanded(
            child: ListView.builder(
              itemCount: _scanHistory.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_scanHistory[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

InputImageRotation _rotationIntToImageRotation(int rotation) {
  switch (rotation) {
    case 90:
      return InputImageRotation.rotation90deg;
    case 180:
      return InputImageRotation.rotation180deg;
    case 270:
      return InputImageRotation.rotation270deg;
    case 0:
    default:
      return InputImageRotation.rotation0deg;
  }
}
