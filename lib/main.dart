import 'dart:typed_data';  // For using Float32List or other typed lists
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart'; // For WriteBuffer
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteModel {
  Interpreter? _interpreter;

  // Load model from assets
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('model.tflite');
    } catch (e) {
      debugPrint('Error loading model: $e');
    }
  }

  // Predict with a typed input (e.g., Float32List)
  Future<List<double>> predict(Uint8List input) async {
    var inputData = Float32List.fromList(input.map((e) => e.toDouble()).toList());
    var output = List.filled(1, 0.0);  // Adjust based on your model's output size

    try {
      await _interpreter!.run(inputData, output);
    } catch (e) {
      debugPrint('Error during prediction: $e');
    }

    return output;
  }

  // Close interpreter when done
  void dispose() {
    _interpreter?.close();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MaterialApp(home: HomePage(cameras: cameras)));
}

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomePage({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _controller;
  bool isScanning = false;
  bool isProcessing = false;

  List<String> triggerIngredients = [
    "Acetylated Monoglycerides", "Acidophilus", "Acid Whey", "Albumen", "Albumin",
    "Alcohol", "Ammonium", "Ammonium Caseinate", "AMF", "AMG", "Anhydrous Milk Fat",
    "Artificial butter", "Artificial butter flavor", "Artificial butter flavour",
    "Artificial Colour", "Artificial Color", "Artificial Flavor", "Artificial Flavour",
    "Aspic", "Beef", "Beer", "Beta Lactoglobulin", "Binders", "Bologna", "Butter",
    "Butter extract", "Butter Fat", "Butter Flavoured Oil", "Butter Flavored Oil",
    "Butter Oil", "Butter Solids", "Buttermilk", "Buttermilk blend", "Buttermilk Powder",
    "Buttermilk Solids", "Calcium", "Calcium Caseinate", "Casein", "Casein Hydrolysates",
    "Casein (Hydrolyzed)", "Caseinate", "Capsules containing bovine gelatin", "Caramel",
    "Caramel Colour", "Caramel Color", "Caramel Flavour", "Caramel Flavor", "Cheese",
    "Cheese Flavour", "Cheese Flavor", "Cheese Food", "Chocolate", "Cochineal (Red Dye)",
    "Color", "Colour", "Condensed Milk", "Cottage Cheese", "Cream", "Cream Cheese",
    "Creamers with dairy binders", "Cultured Milk", "Curd", "Curd Whey", "Custard",
    "Dairy Products", "Dairy Product Solids", "Dairy Butter", "Delactosed whey",
    "Demineralized whey", "Derivative Milk", "Diacetyl", "DMS", "Dried Milk",
    "Dried Milk Solids", "Dry Milk", "Dry Milk Powder", "Dry Milk Solids", "E270 (Lactic Acid)",
    "Enriched flour", "Evaporated Milk", "Fat Free Milk", "Fat Replacer (Opta)", "Flavoring",
    "Flavouring", "Flavored drinks", "Flavoured drinks", "Fully Cream Milk Powder", "Galactose",
    "Ghee", "Gelatin", "Gelatine", "Goat Cheese", "Goat Milk", "Half & Half", "High Protein Flour",
    "Hot chocolate mixes", "Hot Dogs", "Hydrolyzed Casein", "Hydrolyzed Milk Protein",
    "Hydrolyzed Whey", "Ice Cream", "Ice Milk", "Imitation Cheese", "Imitation Sour Cream",
    "Iron Caseinate", "Kefir", "Kourmiss", "Lactaglobulin", "Lactalbumin", "Lactalbumin Phosphate",
    "Lactaid Milk", "Lactate", "Lactate Solids", "Lactic Acid (E270)", "Lactic Yeast", "Lactitol Monohydrate",
    "Lactoferrin", "Lactose", "Lactose-containing drinks", "Lactose Free Milk", "Lactulose",
    "Lactulose Free Milk", "Lanolin", "Lard", "Magnesium Lactate", "Maleates",
    "Marshmallow", "Milk", "Malted Milk", "Milk Derivative", "Milk Derivatives", "Milk Fat", "MPC", "Milk Protein",
    "Milk Protein Concentrate (MPC)", "Milk Solids", "Monoglycerides", "Modified Milk Ingredients", "Natural Coloring",
    "Natural Colouring", "Natural Flavoring", "Natural Flavouring", "Natural Flavours", "Natural Flavors",
    "Nitrates", "Nougat", "OPTA (Fat Replacer)", "Modified milk ingredients",
    "Paneer", "Pepperoni", "Powdered Milk", "Prescription capsules (Bovine)", "Processed Cheese",
    "Processed Meats", "Recaldent", "Rennet Casein", "Salami", "Salt", "SAPP", "Sherbet",
    "Simplesse (Fat Replacer)", "Skim Milk", "Soda Pop with caramel colouring", "Sodium Acid Pyrophosphate",
    "Sodium Caseinate", "Sodium Stearoyl-2-lactylate", "Sour Cream", "Sour Milk Solids",
    "Spice", "Spices", "Stearates", "Stearic Acid", "Suet", "Sulfites", "Sulphites",
    "Tagatose", "Tallow", "Whey", "Whey Protein Concentrates (WPC)", "Whey Protein Isolates (WPI)",
    "Wine (Red)", "Wine (White)", "Wool Fat", "WPC", "WPI", "Yogurt", "Zinc Caseinate"
  ];

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.high, enableAudio: false);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      debugPrint("Camera error: $e");
    });
    loadModel();
  }

  void loadModel() async {
    String? res = await Tflite.loadModel(
      model: "assets/1.tflite",
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    debugPrint("Model loaded: $res");
  }

  @override
  void dispose() {
    _controller.dispose();
    Tflite.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: Text('Acnerase')),
      body: Stack(
        children: [
          CameraPreview(_controller),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  textStyle: TextStyle(fontSize: 20),
                ),
                onPressed: isScanning ? null : scanFrame,
                child: Text("Scan"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Grabs a frame from the live camera feed, runs TensorFlow Lite inference,
  // and then uses fuzzy matching to check for trigger ingredients.
  void scanFrame() async {
    if (!_controller.value.isInitialized) return;
    setState(() {
      isScanning = true;
    });
    if (!isProcessing) {
      isProcessing = true;
      _controller.startImageStream((CameraImage image) async {
        try {
          var recognitions = await Tflite.runModelOnFrame(
            bytesList: image.planes.map((plane) => plane.bytes).toList(),
            imageHeight: image.height,
            imageWidth: image.width,
            imageMean: 127.5,
            imageStd: 127.5,
            rotation: _controller.description.sensorOrientation,
            numResults: 5,
            threshold: 0.4,
            asynch: true,
          );
          await _controller.stopImageStream();
          List<String> foundIngredients = [];
          if (recognitions != null) {
            for (var rec in recognitions) {
              String label = rec["label"] ?? "";
              // Use fuzzy matching to compare the model's label with trigger ingredients.
              for (String ingredient in triggerIngredients) {
                if (isSimilar(normalizeText(label), normalizeText(ingredient))) {
                  foundIngredients.add(ingredient);
                }
              }
            }
          }
          debugPrint("TFLite Recognitions: $recognitions");
          debugPrint("Found Ingredients: $foundIngredients");
          if (foundIngredients.isNotEmpty) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text("Alert"),
                content: Text("Ingredients detected:\n${foundIngredients.join(', ')}"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  )
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No trigger ingredients detected.")),
            );
          }
        } catch (e) {
          debugPrint("Error processing frame: $e");
        }
        isProcessing = false;
        setState(() {
          isScanning = false;
        });
      });
    }
  }

  // Normalizes text by lowercasing, removing punctuation and extra spaces.
  String normalizeText(String text) {
    text = text.toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    // Optionally remove a trailing 's' for plural normalization.
    if (text.endsWith('s')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }

  // Returns true if the similarity between two strings is above a threshold.
  bool isSimilar(String s1, String s2) {
    // If both strings are single words, check for exact equality.
    if (!s1.contains(' ') && !s2.contains(' ')) {
      return s1 == s2;
    }
    // Check if one string is contained within the other.
    if (s1.contains(s2) || s2.contains(s1)) return true;

    double similarityThreshold = 0.8;
    return calculateSimilarity(s1, s2) >= similarityThreshold;
  }

  // Computes similarity using Levenshtein distance.
  double calculateSimilarity(String s1, String s2) {
    int maxLen = s1.length > s2.length ? s1.length : s2.length;
    if (maxLen == 0) return 1.0;
    int distance = levenshteinDistance(s1, s2);
    return 1.0 - (distance / maxLen);
  }

  // Computes the Levenshtein distance between two strings.
  int levenshteinDistance(String s1, String s2) {
    List<List<int>> matrix =
        List.generate(s1.length + 1, (_) => List<int>.filled(s2.length + 1, 0));
    for (int i = 0; i <= s1.length; i++) matrix[i][0] = i;
    for (int j = 0; j <= s2.length; j++) matrix[0][j] = j;
    for (int i = 1; i <= s1.length; i++) {
      for (int j = 1; j <= s2.length; j++) {
        int cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost
        ].reduce((a, b) => a < b ? a : b);
      }
    }
    return matrix[s1.length][s2.length];
  }
}
