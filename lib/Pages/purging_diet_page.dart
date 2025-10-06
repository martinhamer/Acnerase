import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PurgingDietPage extends StatefulWidget {
  const PurgingDietPage({super.key});

  @override
  State<PurgingDietPage> createState() => _PurgingDietPageState();
}

class _PurgingDietPageState extends State<PurgingDietPage> {
  Map<String, dynamic>? dietData;

  @override
  void initState() {
    super.initState();
    _loadDietData();
  }

  Future<void> _loadDietData() async {
    final jsonString =
    await rootBundle.loadString('assets/data/purging_diet.json');
    final data = json.decode(jsonString);
    setState(() {
      dietData = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('The Purging Diet')),
      body: dietData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Introduction",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(dietData!['introduction'] ?? ''),
            const SizedBox(height: 24),
            const Text(
              "Daily Meal Plans",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._buildDaySections(dietData!['days']),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                dietData!['note'] ?? '',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                '🌿 End of Diet Guide',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
  List<Widget> _buildDaySections(List<dynamic> days) {
    return days.map((dayData) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayData['day'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List<Widget>.from(
              (dayData['meals'] as List<dynamic>).map(
                    (meal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text("• $meal"),
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
