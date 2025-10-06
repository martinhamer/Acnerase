import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    runApp(AcnEraseApp(cameras: cameras));
}

class AcnEraseApp extends StatelessWidget {
    final List<CameraDescription> cameras;
    AcnEraseApp({required this.cameras});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            debugShowCheckedModeBanner: false,
        title: 'AcnErase',
        theme: ThemeData.dark().copyWith(
        elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
        primary: Colors.deepPurple,
        onPrimary: Colors.white,
        minimumSize: Size(120, 60),
        ),
        ),
        ),
        home: WelcomeScreen(cameras: cameras),
        );
    }
}

class WelcomeScreen extends StatelessWidget {
    final List<CameraDescription> cameras;
    WelcomeScreen({required this.cameras});

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            appBar: AppBar(title: Text('Welcome to AcnErase')),
        body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
            'AcnErase helps you identify acne-triggering ingredients in food and personal care products.',
            textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 20),
        ElevatedButton(
            onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ScanScreen(cameras: cameras)),
            );
        },
        child: Text('Start Scanning'),
        ),
        ],
        ),
        ),
        );
    }
}

class ScanScreen extends StatefulWidget {
    final List<CameraDescription> cameras;
    ScanScreen({required this.cameras});

    @override
    _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
    CameraController? _cameraController;
    late TextRecognizer _textRecognizer;
    bool _isProcessing = false;
    int _quarterTurns = 0;

    List<String> severeTriggers = [
        'Artificial Colour', 'Artificial Flavour', 'Butter', 'Capsules containing bovine gelatin',
        'Caramel Flavour', 'Delactosed whey', 'Gelatin', 'Gelatine', 'Milk Fat', 'Natural Colouring',
        'Natural Flavouring', 'Soda pop with caramel colouring', 'Whey Protein Concentrates (WPC)',
        'Whey Protein Isolates (WPI)', 'Wine (Red)', 'Wine (White)', 'Spice', 'Spices', 'Sulfites', 'Sulphites'
    ];

    List<String> triggerIngredients = [
        'Acetylated Monoglycerides', 'Albumen', 'Albumin', 'Alcohol', 'Ammonium', 'Ammonium Caseinate',
        'Anhydrous Milk Fat', 'Artificial Butter', 'Artificial Color', 'Artificial Colour',
        'Artificial Flavour', 'Artificial Flavor', 'Aspic', 'Beef', 'Beer', 'Beta Lactaglobulin',
        'Bologna', 'Butter', 'Butter Fat', 'Butter Solids', 'Buttermilk', 'Calcium Caseinate',
        'Capsules Containing Bovine Gelatin', 'Caramel', 'Caramel Colour', 'Caramel Color',
        'Caramel Flavour', 'Caramel Flavor', 'Caramel Colouring', 'Caramel Flavouring', 'Casein',
        'Caseinate', 'Cheese', 'Cochineal', 'Cream', 'Curd', 'Dairy', 'Delactosed Whey',
        'Dried Milk Solids', 'E270 (Lactic Acid)', 'Flavouring', 'Flavoring', 'Gelatin', 'Gelatine',
        'Hot Dogs', 'Ice Cream', 'Lactic Acid', 'Lactalbumin', 'Lactate', 'Lactoferrin', 'Lactose',
        'Lanolin', 'Lard', 'Magnesium Lactate', 'Marshmallow', 'Milk', 'Milk Derivative', 'Milk Fat',
        'Milk Protein', 'Natural Flavor', 'Natural Flavour', 'Natural Colouring', 'Natural Flavouring',
        'Nitrates', 'Opta', 'Pepperoni', 'Processed Cheese', 'Processed Meats', 'Rennet Casein',
        'Salami', 'Sodium Caseinate', 'Sodium Stearoyl-2-Lactylate', 'Sour Cream', 'Stearates',
        'Stearic Acid', 'Sulfites', 'Sulphites', 'Tallow', 'Whey', 'Whey Protein Concentrates (WPC)',
        'Whey Protein Isolates (WPI)', 'Yogurt', 'Zinc Caseinate', 'Soda Pop With Caramel Colouring',
        'Wine (Red)', 'Wine (White)', 'Spice', 'Spices'
    ];

    @override
    void initState() {
        super.initState();
        _initializeCamera();
        _textRecognizer = TextRecognizer();
    }

    void _initializeCamera() {
        _cameraController = CameraController(
            widget.cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
        );

        _cameraController!.initialize().then((_) {
        if (!mounted) return;
        setState(() {
            _cameraController!.setFlashMode(FlashMode.auto);
            _adjustCameraRotation();
        });
    });
    }

    void _adjustCameraRotation() {
        final int sensorOrientation = widget.cameras.first.sensorOrientation;
        setState(() {
            _quarterTurns = (sensorOrientation == 90 || sensorOrientation == 270) ? 1 : 0;
        });
    }
}
