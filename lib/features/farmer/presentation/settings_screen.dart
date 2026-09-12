import 'package:flutter/material.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';

class AppSettings {
  static String mapApiKey = '';
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Pashudrishti',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: MainBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              GlassContainer(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.map,
                      title: 'Map API Key',
                      subtitle: AppSettings.mapApiKey.isEmpty ? 'Add your map provider API key' : 'Configured',
                      onTap: () => _showMapApiKeyDialog(context),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingTile(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      subtitle: 'Manage alerts and reminders',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingTile(
                      icon: Icons.dark_mode,
                      title: 'Dark Mode / Light Mode',
                      subtitle: 'Switch app appearance',
                      onTap: () => _showComingSoon(context),
                    ),
                    const Divider(height: 1, color: Colors.black12),
                    _buildSettingTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: 'Change app language',
                      onTap: () => _showComingSoon(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54, size: 18),
          ],
        ),
      ),
    );
  }

  void _showMapApiKeyDialog(BuildContext context) {
    final controller = TextEditingController(text: AppSettings.mapApiKey);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Map API Key'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your map API key',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AppSettings.mapApiKey = controller.text.trim();
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map API key saved.')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('This setting is coming soon.'),
        backgroundColor: Color(0xFF2563EB),
      ),
    );
  }
}
