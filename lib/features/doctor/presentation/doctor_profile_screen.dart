import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/providers/user_provider.dart';

class DoctorProfileScreen extends ConsumerWidget {
  const DoctorProfileScreen({super.key});

  void _showEditDialog(BuildContext context, WidgetRef ref, UserModel user) {
    final nameController = TextEditingController(text: user.fullName);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    final roleController = TextEditingController(text: user.role);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final updatedName = nameController.text.trim();
                final updatedEmail = emailController.text.trim();
                final updatedPhone = phoneController.text.trim();
                final updatedRole = roleController.text.trim();

                if (updatedName.isEmpty || updatedEmail.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name and email cannot be empty.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                ref.read(userProvider.notifier).updateUser(
                  fullName: updatedName,
                  email: updatedEmail,
                  phone: updatedPhone,
                  role: updatedRole.isEmpty ? 'Veterinarian' : updatedRole,
                );

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully.'),
                    backgroundColor: Color(0xFF2563EB),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final String fullName = user.fullName.isNotEmpty ? user.fullName : 'Guest Doctor';
    final String email = user.email.isNotEmpty ? user.email : 'doctor@example.com';
    final String phone = user.phone.isNotEmpty ? user.phone : 'Not provided';
    final String initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'D';
    
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120), // 120px bottom padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Doctor Profile',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Manage your professional information',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showEditDialog(context, ref, user),
                  borderRadius: BorderRadius.circular(20),
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    borderRadius: BorderRadius.circular(20),
                    child: const Text('Edit Profile', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Identity Card
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dr. $fullName',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Senior Veterinarian',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(width: 100, child: _buildStatCard(Icons.star, 'Ratings', '0', Colors.orange)),
                  const SizedBox(width: 8),
                  SizedBox(width: 100, child: _buildStatCard(Icons.monitor_heart, 'Cases Handled', '0', Colors.blue)),
                  const SizedBox(width: 8),
                  SizedBox(width: 100, child: _buildStatCard(Icons.emoji_events, 'Success Rate', '0%', Colors.green)),
                  const SizedBox(width: 8),
                  SizedBox(width: 100, child: _buildStatCard(Icons.work, 'Experience', '0 Years', Colors.purple)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Card
            GlassContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Professional Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.mail, email),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.phone, phone),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.location_on, 'Indore, MP'),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.tag, 'VET-89321'),
                  const SizedBox(height: 16),
                  const Text('About You', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                  const SizedBox(height: 8),
                  const Text(
                    'Dedicated veterinarian with a passion for livestock health and preventative care. Specialized in large animal medicine and rapid diagnostics.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Logout Button
            InkWell(
              onTap: () {
                ref.read(userProvider.notifier).updateUser(
                  fullName: 'Guest User',
                  email: 'guest@example.com',
                  phone: '',
                  role: 'Livestock Owner',
                );
                context.go('/login');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 10, color: Colors.black54), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black54),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.black87, fontSize: 14)),
        ),
      ],
    );
  }
}
