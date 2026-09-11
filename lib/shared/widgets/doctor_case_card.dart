import 'package:flutter/material.dart';
import 'glass_container.dart';

class DoctorCaseCard extends StatelessWidget {
  final String caseId;
  final String date;
  final String patientName;
  final String animal;
  final String status;
  final String severity;

  const DoctorCaseCard({
    super.key,
    required this.caseId,
    required this.date,
    required this.patientName,
    required this.animal,
    required this.status,
    required this.severity,
  });

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    if (status.toLowerCase().contains('pending')) {
      return Colors.orange;
    }
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(caseId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 16)),
              Text(date, style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 18)),
          Text(animal, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildBadge(status, _getStatusColor(status)),
              const SizedBox(width: 8),
              _buildBadge(severity, _getSeverityColor(severity)),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB), // Solid Royal Blue fill
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text('Review Case', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
