import 'package:flutter/material.dart';
import 'glass_container.dart';

class CaseSummaryCard extends StatelessWidget {
  final String caseId;
  final String date;
  final String animalAndLocation;
  final String status;
  final String diseaseStatus;

  const CaseSummaryCard({
    super.key,
    required this.caseId,
    required this.date,
    required this.animalAndLocation,
    required this.status,
    required this.diseaseStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(caseId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(animalAndLocation, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text('Disease Status: $diseaseStatus', style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.yellow.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow.shade700),
      ),
      child: Text(
        status,
        style: TextStyle(color: Colors.yellow.shade900, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
