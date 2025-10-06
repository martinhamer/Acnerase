import 'package:flutter/material.dart';

class EvidencePage extends StatelessWidget {
  const EvidencePage({super.key});

  @override
  Widget build(BuildContext context) {
    print('🧠 LOADED: EvidencePage from evidence_page.dart');
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence Behind AcnErase')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Understanding the Evidence Behind AcnErase",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            Text(
              "Why this matters",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "It’s essential that you understand the theory behind AcnErase, because it challenges conventional thinking about acne and offers a different path—one based on decades of observation, a strong biological basis, and a simple tool: reading ingredient labels.",
            ),
            SizedBox(height: 16),

            Text(
              "1. A Personal Theory Backed by 22+ Years of Observation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "After more than 22 years of tracking cause and effect, it has become clear—with virtual certainty—that acne is a normal immune response to a specific molecule found in many foods, drinks, and even some medications.\n\n"
                  "The AcnErase app is designed to identify these ingredients on product labels, empowering you to avoid them and observe the impact for yourself.\n\n"
                  "The results will speak for themselves—and best of all, the app is free.",
            ),
            SizedBox(height: 16),

            Text(
              "2. Two Known Molecules – Two Acne Triggers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "AcnErase helps detect not just the molecule responsible for common acne, but also a well-documented trigger: wheat/gluten.\n\n"
                  "In many individuals, gluten can trigger a skin condition known as Dermatitis Herpetiformis (DH)—a blistering, itchy rash that is, in fact, an immune reaction to gluten.\n\n"
                  "We believe this condition is just another form of acne, triggered by a different molecule—but the same immune mechanism.",
            ),
            SizedBox(height: 24),

            Text(
              "Dermatological Comparison",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text(
              "Dermatitis Herpetiformis (DH)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "DH is a chronic, intensely itchy rash caused by gluten ingestion. It’s linked to celiac disease, but many with DH show no digestive symptoms.\n\n"
                  "Key traits include:\n"
                  "• Severe itching and scratching\n"
                  "• Grouped blisters and papules\n"
                  "• Symmetry—elbows, knees, scalp, and buttocks\n"
                  "• Clear link to gluten\n"
                  "• Treatable with a gluten-free diet\n"
                  "• Linked to other autoimmune conditions",
            ),
            SizedBox(height: 16),

            Text(
              "Conventional Acne: The Mainstream Explanation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Acne is typically described as a skin condition driven by:\n"
                  "• Blocked pores\n"
                  "• Excess oil\n"
                  "• Bacteria (Cutibacterium acnes)\n"
                  "• Hormonal changes\n"
                  "• Genetics and inflammation\n\n"
                  "In short: acne is said to have many possible causes, but no clear culprit.",
            ),
            SizedBox(height: 16),

            Text(
              "AcnErase Offers a Simpler Explanation",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "AcnErase is based on a bold but simple idea:\n"
                  "Acne is the body’s immune response to a molecule that shouldn’t be there.\n\n"
                  "This theory is supported by the work of Dr. Ajit Varki, a Distinguished Professor at UC San Diego, who announced in 2003 that:\n"
                  "“Every human being has an immune response to red meat and milk.”\n\n"
                  "This discovery formed the foundation for AcnErase’s search for similar immune-triggering ingredients in modern food and skincare products.",
            ),
            SizedBox(height: 16),

            Text(
              "In Summary",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              "Most acne theories today are complex and often contradictory. AcnErase proposes a single, testable premise:\n\n"
                  "Remove the immune-triggering molecule(s), and the acne resolves—without pills, creams, or guesswork.\n\n"
                  "Try it. Observe the results. Come to your own conclusion.",
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}