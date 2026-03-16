// lib/main.dart

import 'package:expense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense/features/auth/presentation/pages/sign_up_page.dart';
import 'package:expense/features/expense/presentation/pages/home.dart';
import 'package:expense/features/expense/presentation/pages/onboarding_screen.dart';
import 'package:expense/core/routes/app_routes.dart';
import 'package:expense/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:expense/core/common/cubits/theme/theme_cubit.dart';
import 'package:expense/core/service_locator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initDependencies();

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final User? user = FirebaseAuth.instance.currentUser;
  final bool isLoggedIn = user != null;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AppUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(
          create: (_) => ThemeCubit()..loadTheme(), // load saved preference
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Expense Tracker',
            // ── Light theme ──
            theme: ThemeData.light().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            // ── Dark theme ──
            darkTheme: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF181820),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1E1E2A),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              cardColor: const Color(0xFF1E1E2A),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
            themeMode: themeMode, // controlled by ThemeCubit
            home: hasSeenOnboarding
                ? (isLoggedIn ? HomeWidget() : SignUpPage())
                : OnboardingScreen(),
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}