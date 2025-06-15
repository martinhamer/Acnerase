import 'package:flutter/material.dart';

class AppHistoryPage extends StatelessWidget {
  const AppHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App History')),
      body: const Center(child: Text('This is the App History page.')),
    );
  }
}
