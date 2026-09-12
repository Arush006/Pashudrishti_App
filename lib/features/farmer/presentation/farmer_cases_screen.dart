import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/case_summary_card.dart';

class FarmerCasesScreen extends ConsumerStatefulWidget {
  const FarmerCasesScreen({super.key});

  @override
  ConsumerState<FarmerCasesScreen> createState() => _FarmerCasesScreenState();
}

class _FarmerCasesScreenState extends ConsumerState<FarmerCasesScreen> {
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
      final cases = await ApiService.getMyCases(token);
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
              'My Cases',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              borderRadius: BorderRadius.circular(16),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search cases...',
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
                      itemCount: _cases.length,
                      itemBuilder: (context, index) {
                        final caseItem = _cases[index] as Map<String, dynamic>;
                        final animalType = caseItem['animal_type'] ?? 'Animal';
                        final location = caseItem['location'] ?? 'Unknown';
                        final status = caseItem['status'] ?? 'Pending';
                        final diseaseName = caseItem['disease_name'] ?? 'Pending Review';
                        final createdAt = caseItem['created_at']?.toString() ?? '';

                        return CaseSummaryCard(
                          caseId: '#${caseItem['id'] ?? 0}',
                          date: createdAt.isEmpty ? 'N/A' : createdAt.split('T').first,
                          animalAndLocation: '$animalType - $location',
                          status: status,
                          diseaseStatus: diseaseName,
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
