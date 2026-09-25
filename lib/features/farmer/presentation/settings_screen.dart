import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pashudrishti_app/l10n/app_localizations.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/providers/locale_provider.dart';

class AppSettings {
  static String mapApiKey = '';
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: MainBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.settings,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 48), // For balance
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSettingTile(
                            icon: Icons.notifications,
                            title: AppLocalizations.of(context)!.notifications,
                            subtitle: AppLocalizations.of(context)!.manageAlertsAndReminders,
                            onTap: () => _showComingSoon(context),
                          ),
                          const Divider(height: 1, color: Colors.black12),
                          _buildSettingTile(
                            icon: Icons.language,
                            title: AppLocalizations.of(context)!.language,
                            subtitle: AppLocalizations.of(context)!.changeAppLanguage,
                            onTap: () => _showLanguageDialog(context, ref),
                          ),
                          const Divider(height: 1, color: Colors.black12),
                          _buildSettingTile(
                            icon: Icons.info_outline,
                            title: AppLocalizations.of(context)!.aboutApp,
                            subtitle: AppLocalizations.of(context)!.appVersionAndDescription,
                            onTap: () => _showAboutApp(context),
                          ),
                          const Divider(height: 1, color: Colors.black12),
                          _buildSettingTile(
                            icon: Icons.contact_support_outlined,
                            title: AppLocalizations.of(context)!.contactUs,
                            subtitle: AppLocalizations.of(context)!.getSupportAndHelp,
                            onTap: () => _showContactUs(context),
                          ),
                        ],
                      ),
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

  void _showContactUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.contact_support_outlined, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Expanded(child: Text('Contact Us')),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For any support or queries, please reach out to us at:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Text('support@pashudrishti.com', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Text('+91 9876543210', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
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

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.english),
              trailing: ref.watch(localeProvider).languageCode == 'en' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                Navigator.pop(context);
              },
            ),
            const Divider(height: 1),
            ListTile(
              title: Text(AppLocalizations.of(context)!.hindi),
              trailing: ref.watch(localeProvider).languageCode == 'hi' ? const Icon(Icons.check, color: Color(0xFF2563EB)) : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = const Locale('hi');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Expanded(child: Text('About Pashudrishti')),
          ],
        ),
        content: const Text(
          'Pashudrishti is an advanced AI-powered platform for rural veterinarians and farmers. '
          'It provides real-time disease diagnosis, health tracking, and seamless communication '
          'to ensure the well-being of livestock.\n\nVersion: 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
