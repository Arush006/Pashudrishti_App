import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/case_summary_card.dart';
import '../../../core/providers/user_provider.dart';

class FarmerHomeScreen extends ConsumerWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(LucideIcons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF3F4F6),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF2563EB)),
              accountName: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              accountEmail: Text(user.email, style: const TextStyle(color: Colors.white70)),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(LucideIcons.user, color: Color(0xFF2563EB), size: 32),
              ),
            ),
            ListTile(leading: const Icon(LucideIcons.settings, color: Colors.black87), title: const Text('Settings', style: TextStyle(color: Colors.black87)), onTap: () {}),
            ListTile(leading: const Icon(LucideIcons.moon, color: Colors.black87), title: const Text('Toggle Dark/Light Mode', style: TextStyle(color: Colors.black87)), onTap: () {}),
            ListTile(leading: const Icon(LucideIcons.globe, color: Colors.black87), title: const Text('Change Language', style: TextStyle(color: Colors.black87)), onTap: () {}),
            ListTile(leading: const Icon(LucideIcons.helpCircle, color: Colors.black87), title: const Text('Help & Support', style: TextStyle(color: Colors.black87)), onTap: () {}),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.fullName}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track your animal health and connect with expert veterinarians',
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
                _buildSummaryCard('My Pets', '1', LucideIcons.heart, Colors.pink),
                _buildSummaryCard('Pending Cases', '1', LucideIcons.fileText, Colors.yellow.shade800),
                _buildSummaryCard('Consultations', '0', LucideIcons.activity, Colors.blue),
                _buildSummaryCard('Nearby Doctors', '0', LucideIcons.user, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48, // Increased height slightly to prevent cramped padding
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildQuickAction('+ Submit New Case', const Color(0xFF2563EB), Colors.white, () {
                    context.push('/submit-case');
                  }),
                  const SizedBox(width: 12),
                  _buildQuickAction('Find Nearby Doctors', Colors.green, Colors.white, () {}),
                  const SizedBox(width: 12),
                  _buildGlassQuickAction('Upload Report'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('My Cases', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return CaseSummaryCard(
                  caseId: '#${5 - index}',
                  date: index == 0 ? 'Jun 19, 2026' : 'May 22, 2026',
                  animalAndLocation: 'Cattle - Raipur',
                  status: 'Pending',
                  diseaseStatus: 'Pending Review',
                );
              },
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
      borderRadius: BorderRadius.circular(24), // More pill-shaped
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Adjusted padding
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildGlassQuickAction(String title) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        borderRadius: BorderRadius.circular(24),
        child: Center(
          child: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
