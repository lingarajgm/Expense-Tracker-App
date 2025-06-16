import 'package:expense/core/common/widgets/loader.dart';
import 'package:expense/core/routes/app_routes.dart';
import 'package:expense/core/utils/show_snackbar.dart';
import 'package:expense/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense/features/auth/presentation/widgets/auth_field.dart';
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
                                onPressed: () {
                                  String name = nameController.text.trim();
                                  String email = emailController.text.trim();
                                  String password =
                                      passwordController.text.trim();

                                  if (name.length <= 3) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Name must be at least 4 characters long.",
                                        ),
                                        backgroundColor: Color.fromARGB(
                                          246,
                                          243,
                                          93,
                                          82,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (email.length < 5 ||
                                      !email.contains('@')) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Enter a valid email with '@' and at least 5 characters.",
                                        ),
                                        backgroundColor: Color.fromARGB(
                                          224,
                                          245,
                                          111,
                                          101,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  if (password.length < 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Password must be at least 6 characters long.",
                                        ),
                                        backgroundColor: Color.fromARGB(
                                          230,
                                          246,
                                          109,
                                          99,
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  // If all validations pass, proceed with sign-up
                                  context.read<AuthBloc>().add(
                                    AuthSignUp(
                                      name: name,
                                      email: email,
                                      password: password,
                                    ),
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
                                ),
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
}
