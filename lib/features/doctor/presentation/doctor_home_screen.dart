import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_container.dart';

class DoctorHomeScreen extends ConsumerStatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  ConsumerState<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends ConsumerState<DoctorHomeScreen> {
  bool _isLoading = true;
  Map<String, dynamic> _dashboard = {};

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final token = ref.read(userProvider).token;
    if (token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await ApiService.getDoctorDashboard(token);
      setState(() {
        _dashboard = data;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, Doctor!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Here\'s your performance summary for this week',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
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
                _buildSummaryCard('Assigned Cases', _isLoading ? '...' : '${_dashboard['assignedCases'] ?? 0}', LucideIcons.user, Colors.blue),
                _buildSummaryCard('Pending Cases', _isLoading ? '...' : '${_dashboard['pendingCases'] ?? 0}', LucideIcons.alertTriangle, Colors.orange),
                _buildSummaryCard('Resolved Cases', _isLoading ? '...' : '${_dashboard['resolvedCases'] ?? 0}', LucideIcons.calendar, Colors.purple),
                _buildSummaryCard('Cure Rate', _isLoading ? '...' : '${_dashboard['cureRate'] ?? 0}%', LucideIcons.fileText, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickAction('View Cases', const Color(0xFF2563EB), Colors.white, () {
                    context.push('/doctor-cases');
                  }),
                  const SizedBox(width: 12),
                  _buildQuickAction('Appointments', Colors.purple, Colors.white, () {
                    context.push('/doctor-appointments');
                  }),
                  const SizedBox(width: 12),
                  _buildQuickAction('Reports', Colors.green, Colors.white, () {
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

  Widget _buildQuickAction(String title, Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
