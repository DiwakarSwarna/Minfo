import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:mango_app/auth/otp_verify.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:mango_app/widgets/text_input.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final loc.Location location = loc.Location();

  // Controllers
  final TextEditingController mandiController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  String locationText = "Click button to get location";
  final AuthService authService = AuthService();

  // State for suggestions
  List<Location> _geocodingResults = [];
  List<Placemark> _geocodingPlacemarks = [];

  // 👉 Store selected lat/lng
  double? _selectedLat;
  double? _selectedLng;
  // Get address from lat/lng
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  /// 📌 Get current GPS location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          locationText = "Location services are disabled.";
        });
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        setState(() {
          locationText = "Location permission denied.";
        });
        return;
      }
    }

    loc.LocationData currentLocation = await location.getLocation();

    String address = await getAddressFromLatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    setState(() {
      locationText = address;
      locationController.text = address;
      _selectedLat = currentLocation.latitude; // ✅ store lat
      _selectedLng = currentLocation.longitude; // ✅ store lng
    });
  }

  /// 📌 Fetch suggestions when user types
  Future<void> _fetchGeocodingResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _geocodingResults = [];
        _geocodingPlacemarks = [];
      });
      return;
    }
    try {
      final results = await locationFromAddress(query);
      List<Placemark> placemarks = [];
      if (results.isNotEmpty) {
        placemarks = await placemarkFromCoordinates(
          results.first.latitude,
          results.first.longitude,
        );
      }
      setState(() {
        _geocodingResults = results;
        _geocodingPlacemarks = placemarks;
      });
    } catch (e) {
      setState(() {
        _geocodingResults = [];
        _geocodingPlacemarks = [];
      });
    }
  }

  /// 📌 Finalize selection (when user taps a suggestion)
  Future<void> _searchAndSendLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        final lat = loc.latitude;
        final lng = loc.longitude;

        setState(() {
          locationController.text = query; // ✅ fill text field
          _geocodingResults.clear(); // hide suggestions
          _geocodingPlacemarks.clear();
          _selectedLat = lat; // ✅ store lat
          _selectedLng = lng; // ✅ store lng
        });

        print(
          "📍 Selected Location: $lat, $lng",
        ); // here you can send to Bloc/backend
      } else {
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(const SnackBar(content: Text('Location not found.')));
        AppSnackBar.show(
          context,
          message: 'Location not found.',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(SnackBar(content: Text('Failed to get location: $e')));
      AppSnackBar.show(
        context,
        message: 'Failed to get location: $e',
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Register on Mango",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),

                TextInput(
                  label: "Mandi:",
                  hint: "Enter Mandi Name",
                  controller: mandiController,
                ),
                SizedBox(height: 30),
                TextInput(
                  label: "Owner:",
                  hint: "Enter Owner Name",
                  controller: ownerController,
                ),
                SizedBox(height: 30),

                /// 📌 Location with suggestions
                Text(
                  "Location:",
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
                TextField(
                  controller: locationController,
                  onChanged: _fetchGeocodingResults,
                  decoration: InputDecoration(
                    // labelText: "Location:",
                    hintText: "Enter Mandi location",

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Colors.green.shade500,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                // const SizedBox(height: 10),

                // Suggestion list
                if (_geocodingPlacemarks.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _geocodingPlacemarks.length,
                      itemBuilder: (context, index) {
                        final place = _geocodingPlacemarks[index];
                        final display =
                            "${place.locality}, ${place.administrativeArea}, ${place.country}";
                        return ListTile(
                          leading: Icon(Icons.location_on, color: Colors.green),
                          title: Text(display),
                          onTap: () {
                            _searchAndSendLocation(display);
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 10),

                // Use current location button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.green,
                  ),
                  child: InkWell(
                    onTap: _getLocation,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 20,
                            color: Colors.orange[800],
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            "Use current location",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                TextInput(
                  label: "Email:",
                  hint: "Enter your email",
                  controller: emailController,
                ),
                const SizedBox(height: 30),

                // GestureDetector(
                //   onTap: () {
                //     Navigator.of(context).push(
                //       MaterialPageRoute(
                //         builder:
                //             (builder) => OtpVerify(
                //               email: emailController.text.trim(),
                //               mandiName: mandiController.text.trim(),
                //               ownerName: ownerController.text.trim(),
                //               latitude: _selectedLat!,
                //               longitude: _selectedLng!,
                //             ),
                //       ),
                //     );
                //   },
                //   child: Container(
                //     width: double.infinity,
                //     decoration: BoxDecoration(
                //       color: Colors.green,
                //       borderRadius: BorderRadius.circular(8),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(10),
                //       child: Center(
                //         child: Text(
                //           "Send OTP",
                //           style: TextStyle(color: Colors.white),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                GestureDetector(
                  onTap: () async {
                    final email = emailController.text.trim();
                    final mandi = mandiController.text.trim();
                    final owner = ownerController.text.trim();
                    // final location = locationController.text.trim();

                    // if (mandi.isEmpty ||
                    //     owner.isEmpty ||
                    //     location.isEmpty ||
                    //     email.isEmpty) {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     const SnackBar(content: Text("Please fill all fields")),
                    //   );
                    //   return;
                    // }

                    if (mandi.isEmpty) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Please enter your Mandi Name"),
                      //   ),
                      // );
                      AppSnackBar.show(
                        context,
                        message: "Please enter your Mandi Name",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    if (owner.isEmpty) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Please enter Mandi Owner Name"),
                      //   ),
                      // );
                      AppSnackBar.show(
                        context,
                        message: "Please enter Mandi Owner Name",
                        type: SnackBarType.error,
                      );
                      return;
                    }

                    if (_selectedLat == null || _selectedLng == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select or use current location",
                          ),
                        ),
                      );
                      return;
                    }

                    if (email.isEmpty) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(
                      //     content: Text("Please enter your email"),
                      //   ),
                      // );
                      AppSnackBar.show(
                        context,
                        message: "Please enter your email",
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

                    setState(() => isLoading = true);
                    // ✅ Call service
                    final result = await authService.sendOtp(
                      email,
                      type: 'register',
                    );
                    setState(() => isLoading = false);
                    if (result["success"]) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (builder) => OtpVerify(
                                email: email,
                                mandiName: mandiController.text.trim(),
                                ownerName: ownerController.text.trim(),
                                latitude: _selectedLat!,
                                longitude: _selectedLng!,
                              ),
                        ),
                      );
                    } else {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(content: Text(result["message"])),
                      // );
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
      ),
    );
  }
}
