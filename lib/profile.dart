import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
import 'package:mango_app/my_home_page.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/shimmer/profile_shimmer.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mango_app/change_password.dart';
// import 'package:mango_app/services/mango_service.dart';
import 'package:mango_app/widgets/text_input.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  bool shimmerisLoading = true;

  /// ✅ Logout user
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // await prefs.remove("role"); // remove role
    // await prefs.remove("user"); // remove user info
    // await prefs.remove("token"); // optional, if you store JWT

    // Navigate back to login screen and remove all previous routes
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  bool isLoading = false;

  final loc.Location location = loc.Location();
  // final MangoService _mangoService = MangoService();

  final TextEditingController farmerController = TextEditingController();
  final TextEditingController mangoTypesController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  // List<TextEditingController> _mangoControllers = [];

  List<Map<String, dynamic>> _mangoTypes = [];
  List<TextEditingController> _mangoControllers = [];

  Map<String, dynamic>? user;
  double? _selectedLat;
  double? _selectedLng;
  List<Placemark> _geocodingPlacemarks = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  /// ✅ Get address from lat/lng
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return "${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  /// ✅ Load user data from SharedPreferences
  Future<void> loadUserData() async {
    setState(() {
      shimmerisLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");

      if (userJson == null || userJson.isEmpty) {
        setState(() {
          shimmerisLoading = false;
        });
        print("No user data found in SharedPreferences");
        return;
      }

      final parsedUser = jsonDecode(userJson);
      print("Parsed user: $parsedUser");

      // ✅ Safely get user ID
      final userId = parsedUser['_id'] ?? parsedUser['populatedUser']['_id'];
      // print("User ID: $userId");
      if (userId == null) {
        setState(() {
          shimmerisLoading = false;
        });
        print("User ID is null");
        return;
      }

      // print("Fetching farmer data for user ID: $userId");

      final AuthService authService = AuthService();
      final result = await authService.getFarmerById(userId);

      // print("API Result: $result");

      if (result['success'] == true) {
        final farmerData = result['farmer'];
        // print("Farmer data: $farmerData");
        if (farmerData == null) {
          setState(() {
            shimmerisLoading = false;
          });
          print("Farmer data is null");
          return;
        }

        final mangoTypes = (farmerData['farmerMangoTypes'] ?? []) as List;
        // print("Mango types: $mangoTypes");

        // ✅ Safely get coordinates
        final location =
            parsedUser['location'] ?? parsedUser['populatedUser']['location'];
        if (location == null || location['coordinates'] == null) {
          setState(() {
            shimmerisLoading = false;
          });
          print("Location data is missing");
          return;
        }

        final coordinates = location['coordinates'] as List;
        final longitude = (coordinates[0] as num).toDouble();
        final latitude = (coordinates[1] as num).toDouble();

        String address = await getAddressFromLatLng(latitude, longitude);

        setState(() {
          user = parsedUser;
          farmerController.text =
              parsedUser['username'] ?? parsedUser['populatedUser']['username'];
          _mangoTypes = List<Map<String, dynamic>>.from(
            mangoTypes.map((m) => Map<String, dynamic>.from(m as Map)),
          );
          _mangoControllers =
              _mangoTypes
                  .map(
                    (m) => TextEditingController(
                      text: m['typeName']?.toString() ?? '',
                    ),
                  )
                  .toList();
          locationController.text = address;
          shimmerisLoading = false;
        });
      } else {
        setState(() {
          shimmerisLoading = false;
        });
        print("Failed to fetch farmer data: ${result['message']}");
        if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text(
          //       result['message']?.toString() ?? 'Failed to load profile',
          //     ),
          //   ),
          // );
          AppSnackBar.show(
            context,
            message: result['message']?.toString() ?? 'Failed to load profile',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e, stackTrace) {
      print("❌ Error loading user data: $e");
      print("Stack trace: $stackTrace");
      setState(() {
        shimmerisLoading = false;
      });
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Error loading profile data')),
        // );
        AppSnackBar.show(
          context,
          message: 'Error loading profile data',
          type: SnackBarType.error,
        );
      }
    }
  }

  /// ✅ Use current location
  Future<void> _getLocation() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) return;
    }

    loc.LocationData currentLocation = await location.getLocation();
    String address = await getAddressFromLatLng(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    setState(() {
      locationController.text = address;
      _selectedLat = currentLocation.latitude;
      _selectedLng = currentLocation.longitude;
    });
  }

  /// ✅ Search address manually (geocoding)
  Future<void> _fetchGeocodingResults(String query) async {
    if (query.isEmpty) {
      setState(() => _geocodingPlacemarks = []);
      return;
    }
    try {
      final results = await locationFromAddress(query);
      final placemarks = await placemarkFromCoordinates(
        results.first.latitude,
        results.first.longitude,
      );
      setState(() {
        _geocodingPlacemarks = placemarks;
      });
    } catch (e) {
      setState(() => _geocodingPlacemarks = []);
    }
  }

  /// ✅ When user selects suggestion
  Future<void> _selectLocation(String display) async {
    final locations = await locationFromAddress(display);
    if (locations.isNotEmpty) {
      final locData = locations.first;
      setState(() {
        locationController.text = display;
        _geocodingPlacemarks.clear();
        _selectedLat = locData.latitude;
        _selectedLng = locData.longitude;
      });
    }
  }

  /// ✅ Save updated mandi info
  Future<void> _saveChanges() async {
    if (farmerController.text.isEmpty ||
        _mangoControllers.isEmpty ||
        locationController.text.isEmpty) {
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Please fill all fields.")));
      AppSnackBar.show(
        context,
        message: "Please fill all fields.",
        type: SnackBarType.error,
      );
      return;
    }

    try {
      // 🟢 Load existing user from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");
      if (userJson == null) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("User not found. Please log in again.")),
        // );
        AppSnackBar.show(
          context,
          message: "User not found. Please log in again.",
          type: SnackBarType.error,
        );
        return;
      }

      final user = jsonDecode(userJson); // 👈 now user is defined
      // print(user);
      // print(user['data']['_id']);

      // Show progress
      // ScaffoldMessenger.of(
      //   context,
      // ).showSnackBar(const SnackBar(content: Text("Updating profile...")));
      AppSnackBar.show(
        context,
        message: "Updating profile...",
        type: SnackBarType.info,
      );

      final updatedMangoTypes = <Map<String, dynamic>>[];

      for (int i = 0; i < _mangoControllers.length; i++) {
        final text = _mangoControllers[i].text.trim();
        if (text.isEmpty) continue;

        // Preserve existing _id if present
        // final existing = i < _mangoTypes.length ? _mangoTypes[i] : {};
        updatedMangoTypes.add({
          // "_id": existing['_id'], // optional, backend may require
          "typeName": text,
        });
      }

      // 🟢 Call backend API
      final authService = AuthService();
      // Convert updatedMangoTypes to List<Map<String, String>>
      final updatedMangoTypesString =
          updatedMangoTypes
              .map(
                (m) => m.map(
                  (key, value) => MapEntry(key, value?.toString() ?? ""),
                ),
              )
              .toList();

      setState(() {
        isLoading = true;
      });
      final result = await authService.updateFarmerProfile(
        userId: user['_id'] ?? user['populatedUser']['_id'],

        username: farmerController.text.trim(),
        farmerMangoTypes: updatedMangoTypesString,

        // _mangoControllers
        //     .map((c) => c.text.trim())
        //     .where((type) => type.isNotEmpty)
        //     .map((type) => {"typeName": type}) // convert string → object
        //     .toList(),
        longitude:
            _selectedLng ??
            (user['location']['coordinates'][0] ??
                user['populatedUser']['location']['coordinates'][0]),
        latitude:
            _selectedLat ??
            (user['location']['coordinates'][1] ??
                user['populatedUser']['location']['coordinates'][1]),
      );
      setState(() {
        isLoading = false;
      });

      if (result['success']) {
        // // ✅ Update SharedPreferences with latest user data
        // print("-------------------------------------------------success");
        // print(result['data']);
        await prefs.setString("user", jsonEncode(result['data']));

        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text("Profile updated successfully ✅")),
        // );
        AppSnackBar.show(
          context,
          message: "Profile updated successfully ",
          type: SnackBarType.success,
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (builder) => const MyHomePage()),
        );
      } else {
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text("Failed: ${result['message']}")));
        AppSnackBar.show(
          context,
          message: "Failed: ${result['message']}",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Something went wrong. Try again.")),
      // );
      AppSnackBar.show(
        context,
        message: "Something went wrong. Try again.",
        type: SnackBarType.error,
      );
    }
  }

  Future<void> _deleteAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString("user");
    final token = prefs.getString("token"); // if you store JWT
    if (userJson == null) return;

    final user = jsonDecode(userJson);
    final userId = user["_id"] ?? user['populatedUser']["_id"];

    final confirmed = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Account"),
            content: const Text(
              "Are you sure you want to delete your account? This action cannot be undone.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (!confirmed) return;

    final authService = AuthService();
    final result = await authService.deleteAccount(
      userId: userId,
      token: token,
    );

    if (result['success'] == true) {
      await prefs.clear();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['message'] ?? "Account deleted successfully ✅"),
      //   ),
      // );
      AppSnackBar.show(
        context,
        message: result['message'] ?? "Account deleted successfully ",
        type: SnackBarType.success,
      );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(result['message'] ?? "Failed to delete account"),
      //   ),
      // );
      AppSnackBar.show(
        context,
        message: result['message'] ?? "Failed to delete account",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (shimmerisLoading) {
      return const ProfilePageShimmer();
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.green[100],
                child: const Icon(Icons.person, size: 20, color: Colors.green),
              ),
              const Text(
                " Farmer Profile",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                bool confirmed = await showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: const Text("Logout"),
                        content: const Text("Are you sure you want to logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text("Logout"),
                          ),
                        ],
                      ),
                );

                if (confirmed) {
                  _logout();
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Center(
              //   child: CircleAvatar(
              //     radius: 50,
              //     backgroundColor: Colors.green[100],
              //     child: const Icon(
              //       Icons.person,
              //       size: 60,
              //       color: Colors.green,
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 30),

              /// Mandi Name
              TextInput(
                label: "Farmer Name:",
                // hint: "Enter mandi name",
                controller: farmerController,
              ),
              const SizedBox(height: 20),

              // /// Owner Name
              // TextInput(
              //   label: "Cultivating:",
              //   // hint: "Enter owner name",
              //   controller: mangoTypesController,
              // ),
              // const SizedBox(height: 20),

              // 🥭 Mango Types Section as LinkedIn-style dropdown
              Container(
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.green[50],
                ),
                child: ExpansionTile(
                  title: const Text(
                    "Mango Types",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  leading: const Icon(
                    Icons.local_florist,
                    color: Colors.orange,
                  ),
                  children: [
                    Column(
                      children: [
                        // Existing mango types
                        ..._mangoControllers.asMap().entries.map((entry) {
                          final index = entry.key;
                          final controller = entry.value;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 4,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      // labelText: "Type ${index + 1}",
                                      border: const OutlineInputBorder(),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.shade300,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.green.shade600,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _mangoControllers.removeAt(index);
                                      _mangoTypes.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),

                        const SizedBox(height: 8),

                        // Button to add new mango type
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _mangoControllers.add(TextEditingController());
                                _mangoTypes.add({}); // new type without _id
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.green),
                            label: const Text("Add Mango Type"),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// Location Input with Suggestions
              const Text(
                "Location:",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              TextField(
                controller: locationController,
                onChanged: _fetchGeocodingResults,
                decoration: InputDecoration(
                  // hintText: "Enter mandi location",
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

              if (_geocodingPlacemarks.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
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
                        leading: const Icon(
                          Icons.location_on,
                          color: Colors.green,
                        ),
                        title: Text(display),
                        onTap: () => _selectLocation(display),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 10),

              /// Use current location button
              InkWell(
                onTap: _getLocation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.my_location, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        "Use Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Change Password
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ChangePassword(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Change Password",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.green,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Save Button
              InkWell(
                onTap: _saveChanges,
                child: Container(
                  width: double.infinity,
                  // padding: const EdgeInsets.all(14),
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
                                "Save Changes",
                                style: TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ),
              ),
              // Text("Delete Account"),
              TextButton(
                onPressed: _deleteAccount,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey, // Text color
                ),
                child: const Text(
                  "Delete Account",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class Profile extends StatelessWidget {
//   const Profile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("My Profile"),
//         backgroundColor: Colors.green,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Top profile section
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 30),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Colors.green, Colors.green.shade700],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   const CircleAvatar(
//                     radius: 50,
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.person, size: 60, color: Colors.green),
//                   ),
//                   const SizedBox(height: 10),
//                   const Text(
//                     "Farmer Name",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   const Text(
//                     "farmer@email.com",
//                     style: TextStyle(color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Profile details
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   profileCard(
//                     Icons.location_on,
//                     "Location",
//                     "Vijayawada, Andhra Pradesh",
//                     onEdit: () {
//                       // TODO: Add logic to update location
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Update Location clicked"),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 10),
//                   profileCard(
//                     Icons.local_florist,
//                     "Mango Types",
//                     "Alphonso, Kesar, Dasheri",
//                     onEdit: () {
//                       // TODO: Add logic to update mango types
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text("Update Mango Types clicked"),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Logout Button
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: ElevatedButton.icon(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   minimumSize: const Size.fromHeight(50),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 icon: const Icon(Icons.logout, color: Colors.white),
//                 label: const Text(
//                   "Logout",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//                 onPressed: () {
//                   // TODO: Add logout logic
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   /// Reusable profile card with optional edit button
//   Widget profileCard(
//     IconData icon,
//     String title,
//     String value, {
//     VoidCallback? onEdit,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       child: ListTile(
//         leading: Icon(icon, color: Colors.green),
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
//         ),
//         subtitle: Text(value),
//         trailing:
//             onEdit != null
//                 ? IconButton(
//                   icon: const Icon(Icons.edit, color: Colors.green),
//                   onPressed: onEdit,
//                 )
//                 : null,
//       ),
//     );
//   }
// }
