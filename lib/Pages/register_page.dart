import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


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
    print('🧠 LOADED: RegisterPage from register_page.dart');
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}



