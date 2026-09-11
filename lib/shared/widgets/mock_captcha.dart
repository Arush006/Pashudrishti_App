import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'glass_container.dart';

class MockCaptcha extends StatefulWidget {
  final Function(bool isVerified) onVerificationChanged;

  const MockCaptcha({super.key, required this.onVerificationChanged});

  @override
  State<MockCaptcha> createState() => _MockCaptchaState();
}

class _MockCaptchaState extends State<MockCaptcha> {
  String _captchaString = '';
  final TextEditingController _controller = TextEditingController();
  bool _isCaptchaVerified = false;

  @override
  void initState() {
    super.initState();
    _initCaptcha();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initCaptcha() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    _captchaString = String.fromCharCodes(Iterable.generate(
        5, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  void _generateCaptcha() {
    _initCaptcha();
    setState(() {
      _controller.clear();
      _isCaptchaVerified = false;
      widget.onVerificationChanged(false);
    });
  }

  void _verifyCaptcha(String value) {
    final isValid = value.toUpperCase() == _captchaString;
    if (isValid != _isCaptchaVerified) {
      setState(() {
        _isCaptchaVerified = isValid;
      });
      widget.onVerificationChanged(isValid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Security Check', style: TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _captchaString,
                  style: const TextStyle(
                    fontSize: 20,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.black87,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF2563EB)),
                onPressed: _generateCaptcha,
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: _verifyCaptcha,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    suffixIcon: _isCaptchaVerified
                        ? const Icon(LucideIcons.checkCircle2, color: Colors.green)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
