import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/farmer/presentation/farmer_shell_screen.dart';
import '../../features/farmer/presentation/submit_case_screen.dart';

import '../../features/doctor/presentation/doctor_shell_screen.dart';
import '../../features/doctor/presentation/doctor_reports_screen.dart';

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
      path: '/doctor-home',
      builder: (context, state) => const DoctorShellScreen(),
    ),
    GoRoute(
      path: '/doctor-reports',
      builder: (context, state) => const DoctorReportsScreen(),
    ),
  ],
);
