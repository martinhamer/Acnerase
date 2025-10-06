import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// for camera initialization

class SplashScreen extends StatefulWidget {
  final VoidCallback onContinue;

  const SplashScreen({super.key, required this.onContinue});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _dontShowAgain = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPreferenceAndNavigate();
  }

  Future<void> _checkPreferenceAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final skipSplash = prefs.getBool('skipSplash') ?? false;

    if (skipSplash) {
      widget.onContinue();
    } else {
      // show splash for 2 seconds before allowing interaction
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleContinue() async {
    if (_dontShowAgain) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('skipSplash', true);
    }

    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'AcnErase',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 30),
            if (!_isLoading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _dontShowAgain,
                    onChanged: (value) {
                      setState(() {
                        _dontShowAgain = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    "Don't show again",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _handleContinue,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: const Text('Continue to Scanner'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}



