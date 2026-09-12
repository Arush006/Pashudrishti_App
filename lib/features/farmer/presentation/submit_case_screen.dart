import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/api_service.dart';

class SubmitCaseScreen extends ConsumerStatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  ConsumerState<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends ConsumerState<SubmitCaseScreen> {
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _animalType = 'Cattle';
  String _fever = 'Normal';
  String _appetite = 'Normal';
  String _lesions = 'No';
  bool _isLoading = false;

  @override
  void dispose() {
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _breedController.clear();
    _ageController.clear();
    _weightController.clear();
    _locationController.clear();
    _notesController.clear();
    setState(() {
      _animalType = 'Cattle';
      _fever = 'Normal';
      _appetite = 'Normal';
      _lesions = 'No';
    });
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GlassContainer(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.camera, color: Color(0xFF2563EB)),
              title: const Text('Take Photo', style: TextStyle(color: Colors.black87)),
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: const Icon(LucideIcons.image, color: Color(0xFF2563EB)),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.black87)),
              onTap: () => context.pop(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _submit() async {
    final token = ref.read(userProvider).token;
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final payload = {
        'animalType': _animalType,
        'breed': _breedController.text.trim(),
        'age': _ageController.text.trim(),
        'weight': _weightController.text.trim(),
        'location': _locationController.text.trim(),
        'fever': _fever,
        'appetite': _appetite,
        'lesions': _lesions,
        'notes': _notesController.text.trim(),
        'imageUrl': '',
        'aiAnalysis': {'disease_name': 'Pending Review'},
      };

      await ApiService.submitCase(token, payload);

      if (!mounted) return;
      setState(() => _isLoading = false);
      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI Diagnostic Complete - Case sent to Doctor'), backgroundColor: Colors.green),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: Colors.white.withValues(alpha: 0.95),
          icon: const Icon(LucideIcons.chevronDown, color: Colors.black54),
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      borderRadius: BorderRadius.circular(16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: maxLines > 1,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('New Health Case', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: MainBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Emergency Banner
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(LucideIcons.alertTriangle, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Emergency? For life-threatening conditions, call immediately.',
                                style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                          onPressed: () {},
                          child: const Text('Emergency Hotline'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Image Capture Section
                GestureDetector(
                  onTap: _showImagePicker,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.5), width: 1),
                    ),
                    child: const Column(
                      children: [
                        Icon(LucideIcons.camera, size: 48, color: Color(0xFF2563EB)),
                        SizedBox(height: 16),
                        Text('Tap to upload or take a photo', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Clinical Details Form
                const Text('Clinical Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildDropdown(_animalType, ['Cattle', 'Buffalo', 'Goat', 'Sheep'], (v) => setState(() => _animalType = v!)),
                const SizedBox(height: 16),
                _buildGlassTextField(controller: _breedController, labelText: 'Breed (Optional)'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildGlassTextField(controller: _ageController, labelText: 'Age (Years)', keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildGlassTextField(controller: _weightController, labelText: 'Weight (kg)', keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGlassTextField(controller: _locationController, labelText: 'Location'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildDropdown(_fever, ['High', 'Normal'], (v) => setState(() => _fever = v!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown(_appetite, ['Normal', 'Low'], (v) => setState(() => _appetite = v!))),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDropdown(_lesions, ['Yes', 'No'], (v) => setState(() => _lesions = v!))),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGlassTextField(controller: _notesController, labelText: 'Additional Notes', maxLines: 3),
                const SizedBox(height: 32),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Run AI Diagnostic', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
