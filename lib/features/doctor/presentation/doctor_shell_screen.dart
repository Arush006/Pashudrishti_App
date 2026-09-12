import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import 'doctor_home_screen.dart';
import 'doctor_cases_screen.dart';
import 'doctor_appointments_screen.dart';
import 'doctor_reports_screen.dart';
import 'doctor_profile_screen.dart';

class DoctorShellScreen extends StatefulWidget {
  const DoctorShellScreen({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<DoctorShellScreen> createState() => _DoctorShellScreenState();
}

class _DoctorShellScreenState extends State<DoctorShellScreen> {
  late int _currentIndex;

  final List<Widget> _screens = [
    const DoctorHomeScreen(),
    const DoctorCasesScreen(),
    const DoctorAppointmentsScreen(),
    const DoctorReportsScreen(),
    const DoctorProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color(0xFFF3F4F6),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const UserAccountsDrawerHeader(
                    decoration: BoxDecoration(color: Color(0xFF2563EB)),
                    accountName: Text('Dr. Guest', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    accountEmail: Text('doctor@example.com', style: TextStyle(color: Colors.white70)),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF2563EB), size: 32),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.black87),
                    title: const Text('Settings', style: TextStyle(color: Colors.black87)),
                    onTap: () {
                      context.push('/settings');
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.black12)),
                color: Colors.white,
              ),
              child: InkWell(
                onTap: () {
                  context.go('/login');
                },
                borderRadius: BorderRadius.circular(12),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.red, size: 22),
                    SizedBox(width: 10),
                    Text(
                      'Log out',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.list_alt, 'Cases', 1),
                _buildNavItem(Icons.calendar_today, 'Appointments', 2),
                _buildNavItem(Icons.insert_drive_file, 'Reports', 3),
                _buildNavItem(Icons.person, 'Profile', 4),
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
