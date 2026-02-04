// main.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/main_nav_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import '../../utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shoe Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      // Use StreamBuilder to check auth state
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Show loading while checking if user is logged in
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. If user is logged in, go to MainNavScreen
          if (snapshot.hasData) {
            // Remove 'userName: userName' here.
            // Just call the constructor plainly:
            return const MainNavScreen();
          }

          // 3. Otherwise, show Onboarding/Login
          return const OnboardingScreen();
        },
      ),
    );
  }
}
