import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:mango_app/widgets/text_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  String passwordError = "";

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

  final AuthService _authService = AuthService();

  bool isLoading = false;

  void _showSnack(String msg) {
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    AppSnackBar.show(context, message: msg, type: SnackBarType.info);
  }

  Future<void> _changePassword() async {
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();
    final confirmPass = confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnack("Please fill all fields");
      return;
    }

    if (newPass != confirmPass) {
      _showSnack("New passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");
      if (userJson == null) {
        _showSnack("User not found. Please login again.");
        return;
      }

      final user = jsonDecode(userJson);
      final email = user['email'];

      final result = await _authService.changePassword(
        email: email,
        oldPassword: oldPass,
        newPassword: newPass,
      );

      _showSnack(result['message']);
      if (result['success']) Navigator.pop(context);
    } catch (e) {
      _showSnack("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Change Password")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInput(
                label: "Old Password:",
                hint: "Enter old password",
                controller: oldPasswordController,
                obscureText: true,
                showToggle: true,
              ),
              const SizedBox(height: 20),
              TextInput(
                label: "New Password:",
                hint: "Enter new password",
                controller: newPasswordController,
                obscureText: true,
                showToggle: true,
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
              else if (newPasswordController.text.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    "✅ Strong password",
                    style: TextStyle(color: Colors.green, fontSize: 14),
                  ),
                ),

              const SizedBox(height: 30),
              const SizedBox(height: 20),
              TextInput(
                label: "Confirm Password:",
                hint: "Re-enter new password",
                controller: confirmPasswordController,
                obscureText: true,
                showToggle: true,
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: isLoading ? null : _changePassword,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child:
                          isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Save password",
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
    );
  }
}
