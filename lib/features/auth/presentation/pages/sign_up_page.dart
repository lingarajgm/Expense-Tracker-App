import 'package:expense/core/common/widgets/loader.dart';
import 'package:expense/core/routes/app_routes.dart';
import 'package:expense/core/utils/show_snackbar.dart';
import 'package:expense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense/features/auth/presentation/widgets/auth_field.dart';
import 'package:expense/features/expense/presentation/pages/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        showSnackBar(context, state.message);
                      }
                      if (state is AuthSuccess) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Loader();
                      }
                      return Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title with Icon
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_add,
                                  size: 30,
                                  color: Colors.deepPurple,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Name Field
                            AuthField(
                              hintText: 'Name',
                              controller: nameController,
                              isObscureText: false,
                            ),
                            const SizedBox(height: 10),

                            // Email Field
                            AuthField(
                              hintText: 'Email',
                              controller: emailController,
                              isObscureText: false,
                            ),
                            const SizedBox(height: 10),

                            // Password Field
                            AuthField(
                              hintText: 'Password',
                              controller: passwordController,
                              isObscureText: true,
                            ),
                            const SizedBox(height: 20),

                            // Animated Sign Up Button
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: Colors.deepPurple,
                                  shadowColor: Colors.purple.withOpacity(0.3),
                                  elevation: 5,
                                ),
                                onPressed: () async {
                                  String name = nameController.text.trim();
                                  String email = emailController.text.trim();
                                  String password =
                                      passwordController.text.trim();

                                  // Validate fields first
                                  if (name.length <= 3) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Name must be at least 4 characters.")),
                                    );
                                    return;
                                  }
                                  if (email.length < 5 ||
                                      !email.contains('@')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Enter a valid email.")),
                                    );
                                    return;
                                  }
                                  if (password.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              "Password must be at least 6 characters.")),
                                    );
                                    return;
                                  }

                                  // Show friendly privacy dialog
                                  final agreed =
                                      await _showPrivacyDialog(context);
                                  if (agreed != true) return;

                                  // Proceed with signup
                                  context.read<AuthBloc>().add(
                                        AuthSignUp(
                                            name: name,
                                            email: email,
                                            password: password),
                                      );
                                },
                                child: const Text(
                                  'SIGN UP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            // Already have an account? Sign In
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(
                                      context,
                                      AppRoutes.login,
                                    );
                                  },
                                  child: const Text(
                                    "Already have an account? Sign In",
                                    style: TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  // Add after the "Already have an account?" button
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '🔒 Your data is stored securely on Firebase and never shared with third parties. You can delete your account anytime.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool?> _showPrivacyDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: const Column(
          children: [
            Text('🔒', style: TextStyle(fontSize: 40)),
            SizedBox(height: 8),
            Text(
              'Your Privacy Matters',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Before we get started:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _privacyPoint('✅', 'Your expense data is only yours'),
            _privacyPoint('✅', 'Never sold or shared with anyone'),
            _privacyPoint('✅', 'Secured by Google Firebase'),
            _privacyPoint('✅', 'Delete your account anytime'),
            const SizedBox(height: 16),
            // Link to full policy
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              child: const Text(
                'Read full Privacy Policy →',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.deepPurple,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          // Proceed button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Got it, Let's Go! 🚀",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _privacyPoint(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
