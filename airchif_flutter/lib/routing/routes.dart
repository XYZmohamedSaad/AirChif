import 'package:go_router/go_router.dart';
import '../ui/screens/welcome_screen.dart';
import '../ui/screens/sign_in_screen.dart';
import '../ui/screens/sign_up_screen.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: WelcomeScreen.routePath,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: SignInScreen.routePath,
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: SignUpScreen.routePath,
      builder: (context, state) => const SignUpScreen(),
    ),
  ],
);
