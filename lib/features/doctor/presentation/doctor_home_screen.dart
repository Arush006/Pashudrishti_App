import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/glass_container.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Doctor!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here\'s your performance summary for this week',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildSummaryCard('Total Patients', '0', LucideIcons.user, Colors.blue),
                _buildSummaryCard('Active Cases', '0', LucideIcons.alertTriangle, Colors.orange),
                _buildSummaryCard('Appointments', '0', LucideIcons.calendar, Colors.purple),
                _buildSummaryCard('Reports Filed', '0', LucideIcons.fileText, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildActionCard('View Cases', const Color(0xFF2563EB), () {}),
                  const SizedBox(width: 12),
                  _buildActionCard('Appointments', Colors.purple, () {}),
                  const SizedBox(width: 12),
                  _buildActionCard('Reports', Colors.green, () {
                    context.push('/doctor-reports');
                  }),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Recent Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            const Text('Your latest interactions and updates', style: TextStyle(color: Colors.black54)),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: const [
                    Icon(LucideIcons.inbox, size: 48, color: Colors.black26),
                    SizedBox(height: 16),
                    Text('No recent activities', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color iconColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, Color fillColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: GlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
