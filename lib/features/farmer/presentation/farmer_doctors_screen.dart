import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_container.dart';

class FarmerDoctorsScreen extends ConsumerStatefulWidget {
  const FarmerDoctorsScreen({super.key});

  @override
  ConsumerState<FarmerDoctorsScreen> createState() => _FarmerDoctorsScreenState();
}

class _FarmerDoctorsScreenState extends ConsumerState<FarmerDoctorsScreen> {
  bool _isLoading = true;
  List<dynamic> _doctors = [];

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    final token = ref.read(userProvider).token;
    if (token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final doctors = await ApiService.getNearbyDoctors(token);
      setState(() {
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _doctors.length,
                      itemBuilder: (context, index) {
                        final doctor = _doctors[index] as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF2563EB),
                              child: Text((doctor['name'] ?? 'D').toString().substring(0, 1).toUpperCase()),
                            ),
                            title: Text(doctor['name'] ?? 'Doctor'),
                            subtitle: Text(doctor['specialization'] ?? 'Veterinarian'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.star, color: Colors.orange, size: 16),
                                Text('${doctor['rating'] ?? 0}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
