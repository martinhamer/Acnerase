import 'package:flutter/material.dart';

class EvidencePage extends StatelessWidget {
  const EvidencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence')),
      body: const Center(child: Text('This is the Evidence page.')),
    );
  }
}
