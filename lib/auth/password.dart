import 'package:flutter/material.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:mango_app/widgets/text_input.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/auth/login.dart';

class Password extends StatefulWidget {
  final String btnName;
  final Widget onTap;
  final String farmerName;
  final String mandiName;
  final String ownerName;
  final double latitude;
  final double longitude;
  final String email;
  final String role;
  final List<Map<String, dynamic>> farmerMangoTypes;

  const Password({
    super.key,
    required this.btnName,
    required this.onTap,
    this.farmerName = '',
    this.mandiName = '',
    this.ownerName = '',
    this.latitude = 0,
    this.longitude = 0,
    this.email = '',
    this.role = '',
    this.farmerMangoTypes = const [],
  });

  @override
  State<Password> createState() => _PasswordState();
}

class _PasswordState extends State<Password> {
  final AuthService authService = AuthService();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  String passwordError = "";

  bool isLoading = false;

  /// 📌 Password validation function
  bool validatePassword(String password) {
    if (password.length < 8) {
      passwordError = "❌ At least 8 characters";
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      passwordError = "❌ At least 1 uppercase letter";
      return false;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      passwordError = "❌ At least 1 lowercase letter";
      return false;
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      passwordError = "❌ At least 1 number";
      return false;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      passwordError = "❌ At least 1 special character";
      return false;
    }
    passwordError = ""; // ✅ valid
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextInput(
                  controller: passwordController,
                  label: "Set Password",
                  hint: "********",
                  obscureText: true,
                  showToggle: true,
                  suffixIcon: Icons.lock,
                  onChanged: (value) {
                    setState(() {
                      validatePassword(value);
                    });
                  },
                ),

                // 🔔 Show password strength message
                if (passwordError.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      passwordError,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  )
                else if (passwordController.text.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      "✅ Strong password",
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 30),

                TextInput(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  hint: "********",
                  obscureText: true,
                  showToggle: true,
                  suffixIcon: Icons.lock,
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () async {
                    if (!validatePassword(passwordController.text)) {
                      // ScaffoldMessenger.of(
                      //   context,
                      // ).showSnackBar(SnackBar(content: Text(passwordError)));
                      AppSnackBar.show(
                        context,
                        message: passwordError,
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    if (passwordController.text !=
                        confirmPasswordController.text) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text("Passwords do not match")),
                      // );
                      AppSnackBar.show(
                        context,
                        message: "Passwords do not match",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    if (widget.btnName == 'Reset Password') {
                      // 👉 Forgot password flow
                      setState(() {
                        isLoading = true;
                      });
                      final result = await authService.resetPassword(
                        email: widget.email,
                        newPassword: passwordController.text,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      if (result['success']) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     content: Text(
                        //       "Password reset successful! Please log in.",
                        //     ),
                        //   ),
                        // );
                        AppSnackBar.show(
                          context,
                          message: "Password reset successful! Please log in.",
                          type: SnackBarType.success,
                        );
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (builder) => Login()),
                        );
                      } else {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       result['message'] ?? "Failed to reset password",
                        //     ),
                        //   ),
                        // );
                        AppSnackBar.show(
                          context,
                          message:
                              result['message'] ?? "Failed to reset password",
                          type: SnackBarType.error,
                        );
                      }
                    } else {
                      // 👉 Registration flow
                      setState(() {
                        isLoading = true;
                      });
                      final response = await authService.registerUser(
                        email: widget.email,
                        password: passwordController.text,
                        role: widget.role,
                        mandiName: widget.mandiName,
                        ownerName: widget.ownerName,
                        latitude: widget.latitude,
                        longitude: widget.longitude,
                        farmerName: widget.farmerName,
                        farmerMangoTypes: widget.farmerMangoTypes,
                      );
                      setState(() {
                        isLoading = false;
                      });
                      if (response["success"]) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (builder) => widget.onTap),
                        );
                      } else {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text(
                        //       response["message"] ?? "Registration failed",
                        //     ),
                        //   ),
                        // );
                        AppSnackBar.show(
                          context,
                          message: response["message"] ?? "Registration failed",
                          type: SnackBarType.error,
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
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
                                : Text(
                                  widget.btnName,
                                  style: TextStyle(color: Colors.white),
                                ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
