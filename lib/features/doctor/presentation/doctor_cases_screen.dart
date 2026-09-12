import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/doctor_case_card.dart';

class DoctorCasesScreen extends ConsumerStatefulWidget {
  const DoctorCasesScreen({super.key});

  @override
  ConsumerState<DoctorCasesScreen> createState() => _DoctorCasesScreenState();
}

class _DoctorCasesScreenState extends ConsumerState<DoctorCasesScreen> {
  bool _isLoading = true;
  List<dynamic> _cases = [];

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    final token = ref.read(userProvider).token;
    if (token.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final cases = await ApiService.getDoctorCases(token);
      setState(() {
        _cases = cases;
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
              'Your Cases',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage and track all your assigned cases',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    borderRadius: BorderRadius.circular(16),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by patient name or case ID...',
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.search, color: Colors.black38),
                        filled: false,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(16),
                  child: const Icon(Icons.filter_alt, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _cases.length,
                      itemBuilder: (context, index) {
                        final item = _cases[index] as Map<String, dynamic>;
                        return DoctorCaseCard(
                          caseId: '#${item['id'] ?? 0}',
                          date: (item['created_at'] ?? '').toString().split('T').first,
                          patientName: item['user_name'] ?? 'Unknown Patient',
                          animal: item['animal_type'] ?? 'Animal',
                          status: item['status'] ?? 'Pending',
                          severity: item['disease_name'] ?? 'N/A',
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${_cases.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                        const Text('Total Cases', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text('${_cases.where((c) => (c as Map<String, dynamic>)['status'] == 'in_progress').length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
                        const Text('In Progress', style: TextStyle(color: Colors.black54, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
