import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/farmer/presentation/farmer_shell_screen.dart';
import '../../features/farmer/presentation/submit_case_screen.dart';
import '../../features/farmer/presentation/settings_screen.dart';

import '../../features/doctor/presentation/doctor_shell_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/farmer-home',
      builder: (context, state) => const FarmerShellScreen(),
    ),
    GoRoute(
      path: '/submit-case',
      builder: (context, state) => const SubmitCaseScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/doctor-home',
      builder: (context, state) => const DoctorShellScreen(),
    ),
    GoRoute(
      path: '/doctor-cases',
      builder: (context, state) => const DoctorShellScreen(initialIndex: 1),
    ),
    GoRoute(
      path: '/doctor-appointments',
      builder: (context, state) => const DoctorShellScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/doctor-reports',
      builder: (context, state) => const DoctorShellScreen(initialIndex: 3),
    ),
  ],
);
