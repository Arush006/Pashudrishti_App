import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/case_summary_card.dart';

class FarmerCasesScreen extends StatelessWidget {
  const FarmerCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'My Cases',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(16),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search cases...',
                  hintStyle: TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  icon: Icon(LucideIcons.search, color: Colors.black38),
                  filled: false,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  return CaseSummaryCard(
                    caseId: '#${10 - index}',
                    date: 'Jun ${19 - index}, 2026',
                    animalAndLocation: index % 2 == 0 ? 'Cattle - Raipur' : 'Goat - Bilaspur',
                    status: index < 2 ? 'Pending' : 'Completed',
                    diseaseStatus: index < 2 ? 'Pending Review' : 'Healthy',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
