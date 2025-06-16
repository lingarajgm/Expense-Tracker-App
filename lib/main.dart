import 'package:expense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense/features/auth/presentation/pages/sign_up_page.dart';
import 'package:expense/features/expense/presentation/pages/home.dart';
import 'package:expense/features/expense/presentation/pages/onboarding_screen.dart';
import 'package:expense/core/routes/app_routes.dart';
import 'package:expense/core/common/cubits/app_user/app_user_cubit.dart';
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

  // Fetch onboarding status
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // Check if user is logged in
  final User? user = FirebaseAuth.instance.currentUser;
  final bool isLoggedIn = user != null;

  runApp(MyApp(hasSeenOnboarding: hasSeenOnboarding, isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn; // <-- Corrected Usage

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
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        theme: ThemeData.dark(),
        home:
            hasSeenOnboarding
                ? (isLoggedIn
                    ? HomeWidget()
                    : SignUpPage()) // <-- Fixed Navigation Logic
                : OnboardingScreen(),
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
