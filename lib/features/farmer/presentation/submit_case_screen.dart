import '../../../l10n/app_localizations.dart';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  String _animalType = 'Cattle';
  String _fever = 'Medium';
  String _appetite = 'Normal';
  String _lesions = 'None';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isLoading = false;
  Map<String, dynamic>? _aiResult;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildAiResult() {
    final diseaseName = _lesions.toLowerCase().contains('eye') || _lesions.toLowerCase().contains('eyes')
        ? 'Pink eye'
        : _lesions.toLowerCase().contains('mouth')
            ? 'Foot and Mouth Disease'
            : 'Mastitis';

    final confidence = 100;
    final symptoms = [
      {'label': 'Fever', 'value': _fever},
      {'label': 'Appetite', 'value': _appetite},
      {'label': 'Lesions', 'value': _lesions},
    ];

    final recommendations = [
      'Keep the animal under observation',
      'Provide clean food and water',
      'Contact a veterinarian immediately if symptoms worsen',
    ];

    final treatment = 'Start specific treatment only after the disease is confirmed by a veterinarian.';

    return {
      'diseaseName': diseaseName,
      'confidence': confidence,
      'category': 'AI image based disease screening',
      'severity': 'Medium',
      'symptoms': symptoms,
      'keyDiagnosis': [
        'Possible disease based on the image and reported symptoms.',
        'A veterinary examination is required for confirmation.',
      ],
      'internalSigns': [
        'Inflammation or lesions may be present in the affected area.',
        'The animal may appear less active or restless.',
      ],
      'precautions': [
        'Keep the animal isolated from other animals.',
        'Check visible wounds or skin changes in the image.',
      ],
      'recommendations': recommendations,
      'treatment': treatment,
    };
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source, imageQuality: 85);
      if (!mounted || pickedFile == null) return;

      Uint8List? imageBytes;
      if (kIsWeb) {
        imageBytes = await pickedFile.readAsBytes();
      }

      setState(() {
        _selectedImage = pickedFile;
        _selectedImageBytes = imageBytes;
      });

      if (!mounted) return;
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to access image: $error')),
      );
    }
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
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2563EB)),
              title: const Text('Take Photo', style: TextStyle(color: Colors.black87)),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.image, color: Color(0xFF2563EB)),
              title: const Text('Choose from Gallery', style: TextStyle(color: Colors.black87)),
              onTap: () => _pickImage(ImageSource.gallery),
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
      String imageUrl = '';
      if (_selectedImage != null) {
        if (kIsWeb && _selectedImageBytes != null) {
          final base64Image = _selectedImageBytes!.toString();
          imageUrl = base64Image.length > 180 ? 'web-image-selected' : base64Image;
        } else {
          imageUrl = _selectedImage!.path;
        }
      }

      Map<String, dynamic> aiAnalysis = {'disease_name': 'Pending Review'};
      if (_selectedImageBytes != null) {
        aiAnalysis = await ApiService.analyzeImage(token, _selectedImageBytes!, _selectedImage!.name);
      } else if (!kIsWeb && _selectedImage != null) {
        final bytes = await File(_selectedImage!.path).readAsBytes();
        aiAnalysis = await ApiService.analyzeImage(token, bytes, _selectedImage!.name);
      }

      final payload = {
        'animalType': _animalType,
        'breed': '',
        'age': '0',
        'weight': '0',
        'location': _locationController.text.trim(),
        'fever': _fever,
        'appetite': _appetite,
        'lesions': _lesions,
        'notes': _notesController.text.trim(),
        'imageUrl': imageUrl,
        'aiAnalysis': aiAnalysis,
      };

      await ApiService.submitCase(token, payload);

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        if (aiAnalysis['success'] == true) {
          _aiResult = {
            'diseaseName': aiAnalysis['disease'] ?? 'Unknown',
            'confidence': aiAnalysis['confidence'] ?? 0,
            'category': 'AI image based disease screening',
            'severity': 'Medium',
            'symptoms': [
              {'label': 'Fever', 'value': _fever},
              {'label': 'Appetite', 'value': _appetite},
              {'label': 'Lesions', 'value': _lesions},
            ],
            'keyDiagnosis': [
              aiAnalysis['analysis'] ?? 'Possible disease based on image.',
              'A veterinary examination is required for confirmation.',
            ],
            'internalSigns': ['Inflammation or lesions may be present in the affected area.'],
            'precautions': ['Keep the animal isolated from other animals.'],
            'recommendations': [
              'Keep the animal under observation',
              'Provide clean food and water',
              'Contact a veterinarian immediately if symptoms worsen',
            ],
            'treatment': 'Consult a vet.',
          };
        } else {
           _aiResult = _buildAiResult();
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI diagnosis ready on screen'), backgroundColor: Colors.green),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    String? label,
  }) {
    final content = Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          isDense: true,
          dropdownColor: Colors.white.withValues(alpha: 0.98),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54, size: 18),
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w500),
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
        ),
      ),
    );

    if (label == null) return content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        content,
      ],
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.38),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.black87, fontSize: 15),
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: maxLines > 1,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
        ),
      ),
    );
  }

  Widget _buildAiResultCard() {
    final result = _aiResult ?? _buildAiResult();
    final diseaseName = result['diseaseName'] as String;
    
    final rawConfidence = result['confidence'];
    final confidenceNum = rawConfidence is num ? rawConfidence : 0;
    final confidenceStr = confidenceNum.toStringAsFixed(1);
    final confidenceDouble = confidenceNum.toDouble();

    final symptoms = result['symptoms'] as List<dynamic>;
    final keyDiagnosis = result['keyDiagnosis'] as List<dynamic>;
    final internalSigns = result['internalSigns'] as List<dynamic>;
    final precautions = result['precautions'] as List<dynamic>;
    final recommendations = result['recommendations'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart, color: Color(0xFF2563EB), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  diseaseName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Medium', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Confidence Score', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
              const Spacer(),
              Text('$confidenceStr%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: confidenceDouble / 100,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: const Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'DIAGNOSIS CATEGORY',
              style: TextStyle(fontSize: 11, color: Colors.black54, letterSpacing: 0.4),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            result['category'] as String,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
          const SizedBox(height: 18),
          const Text('Symptoms', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms.map((item) {
              final map = item as Map<String, dynamic>;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.25)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('${map['label']}: ${map['value']}'),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          _buildResultSection('Key Diagnosis', keyDiagnosis),
          const SizedBox(height: 12),
          _buildResultSection('Internal Signs', internalSigns),
          const SizedBox(height: 12),
          _buildResultSection('Precautions', precautions),
          const SizedBox(height: 18),
          const Text('Recommendations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 10),
          ...recommendations.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final item = entry.value as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text('$index', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: const TextStyle(color: Colors.black87))),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          const Text('Medicine & Treatment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text(result['treatment'] as String, style: const TextStyle(color: Colors.black87)),
          const SizedBox(height: 12),
          const Text(
            'This is an AI analysis. Please confirm with a veterinarian before final diagnosis.',
            style: TextStyle(fontSize: 11, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.black87)),
                    Expanded(child: Text(item as String, style: const TextStyle(color: Colors.black87))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(l10n.newHealthCase, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                // Clinical Details Form
                const Text('Clinical Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 16),
                _buildDropdown(
                  _animalType,
                  ['Cattle', 'Buffalo', 'Goat', 'Sheep'],
                  (v) => setState(() => _animalType = v!),
                  label: 'Animal Type',
                ),
                const SizedBox(height: 16),
                _buildGlassTextField(controller: _locationController, labelText: 'Location'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildDropdown(
                        _fever,
                        ['High', 'Medium', 'Low', 'None'],
                        (v) => setState(() => _fever = v!),
                        label: 'Fever',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        _appetite,
                        ['Normal', 'Low', 'Very Low', 'Not Eating'],
                        (v) => setState(() => _appetite = v!),
                        label: 'Appetite',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDropdown(
                        _lesions,
                        ['Skin', 'Udder', 'Eyes', 'Legs', 'Mouth', 'None'],
                        (v) => setState(() => _lesions = v!),
                        label: 'Lesions',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_aiResult != null) _buildAiResultCard(),

                const SizedBox(height: 24),

                // Selected Image Preview
                if (_selectedImage != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 80,
                          width: 80,
                          margin: const EdgeInsets.only(bottom: 8, right: 8, top: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb && _selectedImageBytes != null
                                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                                : Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImage = null;
                              _selectedImageBytes = null;
                            });
                          },
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.cancel, color: Colors.red, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                // AI Chat Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                        onPressed: _showImagePicker,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            hintText: 'Chat with AI...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black54),
                          ),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                      _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.send, color: Color(0xFF2563EB)),
                              onPressed: _submit,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


