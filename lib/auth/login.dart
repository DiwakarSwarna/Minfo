import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mango_app/auth/forgot_password.dart';
import 'package:mango_app/auth/register_type.dart';
import 'package:mango_app/mandi.dart';
import 'package:mango_app/my_home_page.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/widgets/text_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  void handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please enter email",
        type: SnackBarType.error,
      );

      return;
    }
    if (password.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please enter password",
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => isLoading = true);

    final response = await authService.loginUser(email, password);

    setState(() => isLoading = false);

    if (response["success"] == true) {
      final role = response["user"]["role"];
      final user = response["user"];
      final token = response["token"];

      // ✅ Save login session locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("user", jsonEncode(user));
      await prefs.setString("token", token);
      await prefs.setString("role", role);

      // ✅ Navigate based on role
      if (role == "mandi") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => const Mandi()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => const MyHomePage()),
        );
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(response["message"] ?? "Login failed")),
      // );
      AppSnackBar.show(
        context,
        message: response["message"] ?? "Login failed",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Login to Minfo",
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 36,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  TextInput(
                    controller: emailController,
                    label: "Email:",
                    hint: "Enter your email",
                  ),
                  const SizedBox(height: 30),

                  TextInput(
                    controller: passwordController,
                    label: "Password:",
                    hint: "Enter your password",
                    obscureText: true,
                    showToggle: true,
                    suffixIcon: Icons.lock,
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (builder) => const ForgotPassword(),
                          ),
                        );
                      },
                      child: const Text(
                        "Forgot password",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.green, // ✅ underline color
                          decorationThickness: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  GestureDetector(
                    onTap: handleLogin,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // padding: const EdgeInsets.all(0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child:
                              isLoading
                                  ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    "Login",
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (builder) => const RegisterType(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.green,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.green, // ✅ underline color
                            decorationThickness: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
