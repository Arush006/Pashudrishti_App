import 'package:flutter/material.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/main_background.dart';

class DoctorReportsScreen extends StatelessWidget {
  const DoctorReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Medical Reports', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: MainBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120), // 120px bottom padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Medical Reports',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                const Text(
                  'View and download all your filed medical reports',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 24),
                GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(16),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by patient name, report ID, or disease...',
                      hintStyle: TextStyle(color: Colors.black54),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
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
                          Icon(Icons.insert_drive_file, size: 64, color: Colors.black26),
                          SizedBox(height: 16),
                          Text(
                            'No reports found matching your search.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
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
                            Icon(Icons.insert_drive_file, color: Colors.blue),
                            SizedBox(height: 8),
                            Text('Total Reports', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text('0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
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
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(height: 8),
                            Text('Completed', style: TextStyle(color: Colors.black54, fontSize: 12)),
                            Text('0', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
