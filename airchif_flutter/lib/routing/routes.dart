import 'package:go_router/go_router.dart';
import '../ui/screens/welcome_screen.dart';
import '../ui/screens/sign_in_screen.dart';
import '../ui/screens/sign_up_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/manual_steering.dart'; // <-- import für ManualSteering

final router = GoRouter(
  routes: [
    GoRoute(
      path: WelcomeScreen.routePath,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: HomeScreen.routePath,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: SignInScreen.routePath,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routePath,
      builder: (context, state) => const SignUpScreen(),
    ),

    GoRoute(
      path: ManualSteering.routePath,
      builder: (context, state) => const ManualSteering(),
    ),
  ],
);
