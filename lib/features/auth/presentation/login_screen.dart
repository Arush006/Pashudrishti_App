import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pashudrishti_app/l10n/app_localizations.dart';
import '../../../shared/widgets/main_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/services/api_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email and password are required'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final userData = response['user'] as Map<String, dynamic>? ?? {};
      final token = response['token']?.toString() ?? '';
      final role = ApiService.roleForUi(userData['role']?.toString());

      ref.read(userProvider.notifier).updateUser(
        fullName: userData['name']?.toString() ?? 'Guest User',
        email: userData['email']?.toString() ?? _emailController.text,
        phone: '',
        role: role,
        token: token,
      );

      if (!mounted) return;

      if (role == 'Veterinarian') {
        context.go('/doctor-home');
      } else {
        context.go('/farmer-home');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', '')), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: GlassContainer(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.eco, size: 64, color: Color(0xFF2563EB)),
                        const SizedBox(height: 16),
                        const Text(
                          'Pashudrishti',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(AppLocalizations.of(context)!.livestockHealthMonitoring, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.emailAddress,
                            prefixIcon: const Icon(Icons.mail, color: Colors.black54),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)!.password,
                            prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                color: Colors.black54,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleLogin,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Text(AppLocalizations.of(context)!.login, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context.push('/register');
                          },
                          child: Text(AppLocalizations.of(context)!.dontHaveAccountRegister),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 16,
                child: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  borderRadius: BorderRadius.circular(20),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ref.watch(localeProvider).languageCode == 'hi' ? 'Hindi' : 'English',
                      dropdownColor: Colors.white,
                      icon: const Icon(Icons.language, size: 18, color: Color(0xFF2563EB)),
                      items: [
                        DropdownMenuItem(value: 'English', child: Text(AppLocalizations.of(context)!.english, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))),
                        DropdownMenuItem(value: 'Hindi', child: Text(AppLocalizations.of(context)!.hindi, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87))),
                      ],
                      onChanged: (value) {
                        if (value == 'Hindi') {
                          ref.read(localeProvider.notifier).state = const Locale('hi');
                        } else {
                          ref.read(localeProvider.notifier).state = const Locale('en');
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


