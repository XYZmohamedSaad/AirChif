import 'package:go_router/go_router.dart';

import '../ui/screens/welcome_screen.dart';
import '../ui/screens/sign_in_screen.dart';
import '../ui/screens/sign_up_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/manual_steering.dart';

final router = GoRouter(
  // Erste Seite beim Start der App
  initialLocation: WelcomeScreen.routePath,

  routes: [
    GoRoute(
      path: WelcomeScreen.routePath,       // '/'
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: SignInScreen.routePath,        // '/sign-in'
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routePath,        // '/sign-up'
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: HomeScreen.routePath,          // '/home'
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: ProfileScreen.routePath,       // '/profile'
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: ManualSteering.routePath, // '/manual-steering'
      builder: (context, state) => const ManualSteering(),
    ),
  ],
);
