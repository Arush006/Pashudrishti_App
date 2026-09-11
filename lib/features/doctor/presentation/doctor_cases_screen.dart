import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/doctor_case_card.dart';

class DoctorCasesScreen extends StatelessWidget {
  const DoctorCasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // 120px bottom padding to clear nav bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cases',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage and track all your assigned cases',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(16),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by patient name or case ID...',
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(LucideIcons.search, color: Colors.black38),
                        filled: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(LucideIcons.filter, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                itemBuilder: (context, index) {
                  final cases = [
                    {'id': '#102', 'name': 'Raju Kumar', 'animal': 'Cattle', 'severity': 'High'},
                    {'id': '#103', 'name': 'Anita Devi', 'animal': 'Buffalo', 'severity': 'Medium'},
                    {'id': '#104', 'name': 'Surya Singh', 'animal': 'Goat', 'severity': 'Low'},
                    {'id': '#105', 'name': 'Vikram Patel', 'animal': 'Sheep', 'severity': 'High'},
                  ];
                  return DoctorCaseCard(
                    caseId: cases[index]['id']!,
                    date: 'Jun ${19 - index}, 2026',
                    patientName: cases[index]['name']!,
                    animal: cases[index]['animal']!,
                    status: index < 2 ? 'Pending Review' : 'In Progress',
                    severity: cases[index]['severity']!,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text('4', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('Total Cases', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: const [
                        Text('2', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text('In Progress', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
