import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/mock_captcha.dart';
import '../../../core/providers/user_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _accountType = 'Livestock Owner';
  bool _isCaptchaVerified = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    if (!_isCaptchaVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the captcha'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    
    // Save to provider
    ref.read(userProvider.notifier).updateUser(
      fullName: _nameController.text.isNotEmpty ? _nameController.text : 'Raju Kumar',
      email: _emailController.text.isNotEmpty ? _emailController.text : 'raju@example.com',
      phone: _phoneController.text,
      role: _accountType,
    );
    
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registration successful!'), backgroundColor: Colors.green),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  Widget _buildAccountTypeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _accountType = 'Livestock Owner'),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: _accountType == 'Livestock Owner' ? const Color(0xFF2563EB).withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Livestock Owner', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _accountType = 'Veterinarian'),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: _accountType == 'Veterinarian' ? const Color(0xFF2563EB).withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Veterinarian', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: MainBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: GlassContainer(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                _buildAccountTypeSelector(),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(LucideIcons.user, color: Colors.black54)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(LucideIcons.mail, color: Colors.black54)),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(LucideIcons.phone, color: Colors.black54)),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Create Password',
                    prefixIcon: const Icon(LucideIcons.lock, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.black54),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Re-enter Password',
                    prefixIcon: const Icon(LucideIcons.lock, color: Colors.black54),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.black54),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                MockCaptcha(
                  onVerificationChanged: (isVerified) {
                    setState(() {
                      _isCaptchaVerified = isVerified;
                    });
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _handleRegister,
                  child: const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
