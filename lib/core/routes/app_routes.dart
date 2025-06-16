import 'package:flutter/material.dart';
import 'package:expense/features/auth/presentation/pages/login_page.dart'; // Ensure correct path
import 'package:expense/features/expense/presentation/pages/home.dart';
import 'package:expense/features/auth/presentation/pages/sign_up_page.dart'; // Ensure correct path

class AppRoutes {
  static const String home = "/home";
  static const String login = "/login";
  static const String signup = "/signup";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeWidget());
      case login:
        return MaterialPageRoute(builder: (_) => SignInPage());
      case signup:
        return MaterialPageRoute(builder: (_) => SignUpPage());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text("No route defined for ${settings.name}"),
                ),
              ),
        );
    }
  }
}
