import 'package:flutter/material.dart';
import 'package:mango_app/auth/otp_verify.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
// import 'package:mango_app/widgets/navbutton.dart';
import 'package:mango_app/widgets/text_input.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  final AuthService authService = AuthService();

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextInput(
                label: "Email",
                hint: "Enter your registered email",
                controller: emailController,
              ),
              SizedBox(height: 30),
              // NavButton(
              //   label: "Send OTP",
              //   destination: OtpVerify(forget: true),
              // ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: () async {
                  final email = emailController.text.trim();
                  if (email.isEmpty) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(content: Text("Please enter email")),
                    // );
                    AppSnackBar.show(
                      context,
                      message: "Please enter email",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  // ✅ Email format validation
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!emailRegex.hasMatch(email)) {
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   const SnackBar(
                    //     content: Text("Please enter a valid email"),
                    //   ),
                    // );
                    AppSnackBar.show(
                      context,
                      message: "Please enter a valid email",
                      type: SnackBarType.error,
                    );
                    return;
                  }

                  setState(() {
                    isLoading = true;
                  });
                  // ✅ Call service
                  final result = await authService.sendOtp(
                    email,
                    type: 'forgotPassword',
                  );
                  setState(() {
                    isLoading = false;
                  });
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder: (builder) => OtpVerify(forget: true),
                  //     ),
                  //   );
                  // },
                  // child: Container(
                  //   width: double.infinity,
                  //   decoration: BoxDecoration(
                  //     color: Colors.green,
                  //     borderRadius: BorderRadius.circular(8),
                  //   ),
                  //   child: Padding(
                  //     padding: const EdgeInsets.all(10),
                  //     child: Center(
                  //       child: Text(
                  //         "Send OTP",
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  if (result["success"]) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (builder) => OtpVerify(forget: true, email: email),
                      ),
                    );
                  } else {
                    // ScaffoldMessenger.of(
                    //   context,
                    // ).showSnackBar(SnackBar(content: Text(result["message"])));
                    AppSnackBar.show(
                      context,
                      message: result["message"],
                      type: SnackBarType.error,
                    );
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
                              : const Text(
                                "Send OTP",
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
