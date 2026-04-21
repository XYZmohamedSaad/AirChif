import 'package:go_router/go_router.dart';

import '../ui/screens/drone_settings.dart';
import '../ui/screens/welcome_screen.dart';
import '../ui/screens/sign_in_screen.dart';
import '../ui/screens/sign_up_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/manual_steering.dart';
import '../ui/screens/automatic_steering.dart';
import '../ui/screens/journey_workshop.dart';

// NEU:
import '../ui/screens/edit_profile_screen.dart';
import '../ui/screens/change_password_screen.dart';

final router = GoRouter(
  initialLocation: WelcomeScreen.routePath,
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
    GoRoute(
      path: HomeScreen.routePath,
      builder: (context, state) => const HomeScreen(),
    ),

    // Profile
    GoRoute(
      path: ProfileScreen.routePath,
      builder: (context, state) => const ProfileScreen(),
    ),

    // NEU: Edit Profile
    GoRoute(
      path: EditProfileScreen.routePath,
      builder: (context, state) => const EditProfileScreen(),
    ),

    // NEU: Change Password
    GoRoute(
      path: ChangePasswordScreen.routePath,
      builder: (context, state) => const ChangePasswordScreen(),
    ),

    GoRoute(
      path: ManualSteering.routePath,
      builder: (context, state) => const ManualSteering(),
    ),
    GoRoute(
      path: AutomaticSteeringScreen.routePath,
      builder: (context, state) => const AutomaticSteeringScreen(),
    ),
    GoRoute(
      path: JourneyWorkshopScreen.routePath,
      builder: (context, state) => const JourneyWorkshopScreen(),
    ),
    GoRoute(
      path: DroneSettingsScreen.routePath,
      builder: (context, state) => const DroneSettingsScreen(),
    ),
  ],
);
