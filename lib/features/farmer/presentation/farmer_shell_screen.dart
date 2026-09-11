import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import 'farmer_home_screen.dart';
import 'farmer_cases_screen.dart';
import 'submit_case_screen.dart';
import 'farmer_doctors_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerShellScreen extends StatefulWidget {
  const FarmerShellScreen({super.key});

  @override
  State<FarmerShellScreen> createState() => _FarmerShellScreenState();
}

class _FarmerShellScreenState extends State<FarmerShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const FarmerHomeScreen(),
    const FarmerCasesScreen(),
    const SubmitCaseScreen(),
    const FarmerDoctorsScreen(),
    const FarmerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: MainBackground(
        child: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: GlassContainer(
            borderRadius: BorderRadius.circular(30),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(LucideIcons.home, 'Home', 0),
                _buildNavItem(LucideIcons.clipboardList, 'Cases', 1),
                _buildNavItem(LucideIcons.zap, 'AI Assistant', 2),
                _buildNavItem(LucideIcons.plusSquare, 'Doctors', 3),
                _buildNavItem(LucideIcons.user, 'Profile', 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isActive = _currentIndex == index;
    final color = isActive ? const Color(0xFF2563EB) : Colors.black45;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
