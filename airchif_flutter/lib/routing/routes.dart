import 'package:go_router/go_router.dart';

import '../ui/screens/welcome_screen.dart';
import '../ui/screens/sign_in_screen.dart';
import '../ui/screens/sign_up_screen.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/profile_screen.dart';
import '../ui/screens/manual_steering.dart';
import '../ui/screens/automatic_steering.dart';
import '../ui/screens/journey_workshop.dart';
import '../ui/screens/general_settings.dart';
import '../ui/screens/drone-settings.dart';
import '../ui/screens/edit_profile_screen.dart';


final router = GoRouter(
  initialLocation: WelcomeScreen.routePath,
  routes: [
    // Welcome
    GoRoute(
      path: WelcomeScreen.routePath,
      builder: (context, state) => const WelcomeScreen(),
    ),

    // Login
    GoRoute(
      path: SignInScreen.routePath,
      builder: (context, state) => const SignInScreen(),
    ),

    // Signup
    GoRoute(
      path: SignUpScreen.routePath,
      builder: (context, state) => const SignUpScreen(),
    ),

    // Home
    GoRoute(
      path: HomeScreen.routePath,
      builder: (context, state) => const HomeScreen(),
    ),

    // Profile
    GoRoute(
      path: ProfileScreen.routePath,
      builder: (context, state) => const ProfileScreen(),
    ),

    // Manual Steering
    GoRoute(
      path: ManualSteering.routePath,
      builder: (context, state) => const ManualSteering(),
    ),

    // Automatic Steering
    GoRoute(
      path: AutomaticSteeringScreen.routePath,
      builder: (context, state) => const AutomaticSteeringScreen(),
    ),

    // Journey Workshop
    GoRoute(
      path: JourneyWorkshopScreen.routePath,
      builder: (context, state) => const JourneyWorkshopScreen(),
    ),

    // General Settings (Seite aus dem linken Bild)
    GoRoute(
      path: GeneralSettingsScreen.routePath,
      builder: (context, state) => const GeneralSettingsScreen(),
    ),

    // Drone-Detail-Settings (Status-Seite, die vom Details-Button aufgerufen wird)
    GoRoute(
      path: DroneSettingsScreen.routePath,
      builder: (context, state) => const DroneSettingsScreen(),
    ),

    GoRoute(
      path: EditProfileScreen.routePath,
      builder: (context, state) => const EditProfileScreen(),
    ),
  ],
);
