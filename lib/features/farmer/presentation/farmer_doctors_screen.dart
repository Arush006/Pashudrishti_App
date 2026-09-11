import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../shared/widgets/glass_container.dart';

class FarmerDoctorsScreen extends StatelessWidget {
  const FarmerDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find Nearby Doctors',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(16),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search by doctor name or specialty...',
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
              child: GlassContainer(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(LucideIcons.map, size: 64, color: Colors.black26),
                      SizedBox(height: 16),
                      Text(
                        'Map View',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
