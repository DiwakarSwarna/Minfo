import 'package:flutter/material.dart';
import 'package:mango_app/auth/login.dart';
import 'package:mango_app/auth/password.dart';
// import 'package:mango_app/hero_page.dart';
import 'package:mango_app/mandi.dart';
import 'package:mango_app/my_home_page.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerify extends StatefulWidget {
  final bool forget;
  final bool farmer;
  final String farmerName;
  final String mandiName;
  final String ownerName;
  final double latitude;
  final double longitude;
  final String email;
  final List<Map<String, dynamic>> farmerMangoTypes;
  const OtpVerify({
    super.key,
    this.forget = false,
    this.farmer = false,
    this.farmerName = '',
    this.mandiName = '',
    this.ownerName = '',
    this.latitude = 0,
    this.longitude = 0,
    this.email = '',
    this.farmerMangoTypes = const [],
  });

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  String enteredOtp = "";
  bool isLoading = false;
  final AuthService authService = AuthService(); // 👈 create instance here
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
                Text(
                  "Enter OTP sent to your device",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 5),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => enteredOtp = value,
                  onCompleted: (value) => enteredOtp = value,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 45,
                    fieldWidth: 45,
                    activeFillColor: Colors.white,
                    selectedFillColor: Colors.green.shade50,
                    inactiveFillColor: Colors.grey.shade200,
                    activeColor: Colors.green,
                    inactiveColor: Colors.green.shade200,
                    // selectedColor: Colors.grey.shade400,
                  ),
                ),

                // SizedBox(height: 20),
                SizedBox(height: 30),

                GestureDetector(
                  // onTap: () {
                  //   // print(widget.farmer);
                  //   Navigator.of(context).push(
                  //     MaterialPageRoute(
                  //       builder:
                  //           (builder) => Password(
                  //             btnName:
                  //                 widget.forget ? 'Reset Password' : 'Register',
                  //             onTap:
                  //                 widget.forget
                  //                     ? Login()
                  //                     : (widget.farmer
                  //                         ? MyHomePage()
                  //                         : Mandi()),
                  //             mandiName: widget.mandiName,
                  //             ownerName: widget.ownerName,
                  //             latitude: widget.latitude,
                  //             longitude: widget.longitude,
                  //             email: widget.email,
                  //           ),
                  //     ),
                  //   );
                  // },
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    bool result = await authService.verifyOtp(
                      widget.email,
                      enteredOtp,
                    );
                    setState(() {
                      isLoading = false;
                    });
                    if (result) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (builder) => Password(
                                btnName:
                                    widget.forget
                                        ? 'Reset Password'
                                        : 'Register',
                                onTap:
                                    widget.forget
                                        ? Login()
                                        : (widget.farmer
                                            ? MyHomePage()
                                            : Mandi()),
                                farmerName: widget.farmerName,
                                mandiName: widget.mandiName,
                                ownerName: widget.ownerName,
                                latitude: widget.latitude,
                                longitude: widget.longitude,
                                email: widget.email,
                                role: widget.farmer ? "farmer" : "mandi",
                                farmerMangoTypes: widget.farmerMangoTypes,
                              ),
                        ),
                      );
                    } else {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text("Invalid or expired OTP")),
                      // );
                      AppSnackBar.show(
                        context,
                        message: "Invalid or expired OTP",
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
                                  "Verify OTP",
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
