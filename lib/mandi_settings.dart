import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart' as loc;
// import 'package:mango_app/auth/login.dart';
import 'package:mango_app/services/auth_service.dart';
import 'package:mango_app/shimmer/mandi_settings_shimmer.dart';
import 'package:mango_app/widgets/app_snack_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mango_app/change_password.dart';
// import 'package:mango_app/services/mango_service.dart';
import 'package:mango_app/widgets/text_input.dart';

class MandiSettings extends StatefulWidget {
  const MandiSettings({super.key});

  @override
  State<MandiSettings> createState() => _MandiSettingsState();
}

class _MandiSettingsState extends State<MandiSettings> {
  bool isLoading = true; // ✅ Add loading state for initial load
  bool isSaving = false; // Keep existing for save button

  final loc.Location location = loc.Location();
  final TextEditingController mandiController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  Map<String, dynamic>? user;
  double? _selectedLat;
  double? _selectedLng;
  List<Placemark> _geocodingPlacemarks = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

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

  Future<void> _loadUserData() async {
    setState(() => isLoading = true); // ✅ Show shimmer

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");

      if (userJson != null) {
        final parsedUser = jsonDecode(userJson);
        print(parsedUser);

        String mandiname = "";
        final AuthService authService = AuthService();
        final result = await authService.getMandiById(parsedUser['_id']);
        print("Result---------$result");

        if (result['success']) {
          mandiname = result['mandi']['mandiname'];
        }

        final coordinates = parsedUser['location']['coordinates'];
        final longitude = coordinates[0].toDouble();
        final latitude = coordinates[1].toDouble();

        String address = await getAddressFromLatLng(latitude, longitude);

        setState(() {
          user = parsedUser;
          mandiController.text = mandiname;
          ownerController.text = parsedUser['username'] ?? '';
          locationController.text = address;
          isLoading = false; // ✅ Hide shimmer
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);

      if (mounted) {
        AppSnackBar.show(
          context,
          message: 'Error loading profile data',
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

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

  Future<void> _saveChanges() async {
    if (mandiController.text.isEmpty ||
        ownerController.text.isEmpty ||
        locationController.text.isEmpty) {
      AppSnackBar.show(
        context,
        message: "Please fill all fields.",
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");
      if (userJson == null) {
        AppSnackBar.show(
          context,
          message: "User not found. Please log in again.",
          type: SnackBarType.error,
        );
        return;
      }

      final user = jsonDecode(userJson);
      print(user);
      print(user['_id']);

      AppSnackBar.show(
        context,
        message: "Updating profile...",
        type: SnackBarType.info,
      );

      final authService = AuthService();
      setState(() {
        isSaving = true; // Use isSaving for button state
      });

      final result = await authService.updateMandiProfile(
        userId: user['_id'],
        mandiname: mandiController.text.trim(),
        username: ownerController.text.trim(),
        longitude: _selectedLng ?? user['location']['coordinates'][0],
        latitude: _selectedLat ?? user['location']['coordinates'][1],
      );

      setState(() {
        isSaving = false;
      });

      if (result['success']) {
        await prefs.setString("user", jsonEncode(result['data']));

        AppSnackBar.show(
          context,
          message: "Profile updated successfully ",
          type: SnackBarType.success,
        );

        Navigator.pop(context, true);
      } else {
        AppSnackBar.show(
          context,
          message: "Failed: ${result['message']}",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
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
    final token = prefs.getString("token");
    if (userJson == null) return;

    final user = jsonDecode(userJson);
    print(user);
    final userId = user["_id"];

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
      AppSnackBar.show(
        context,
        message: result['message'] ?? "Account deleted successfully ",
        type: SnackBarType.success,
      );
    } else {
      AppSnackBar.show(
        context,
        message: result['message'] ?? "Failed to delete account",
        type: SnackBarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show shimmer while loading
    if (isLoading) {
      return const MandiSettingsShimmer();
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text(
            "Mandi Profile",
            style: TextStyle(color: Colors.white),
          ),
          foregroundColor: Colors.white,
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
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green[100],
                  child: const Icon(
                    Icons.store_mall_directory,
                    size: 60,
                    color: Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              TextInput(label: "Mandi Name:", controller: mandiController),
              const SizedBox(height: 20),

              TextInput(label: "Owner Name:", controller: ownerController),
              const SizedBox(height: 20),

              const Text(
                "Location:",
                style: TextStyle(fontSize: 18, color: Colors.green),
              ),
              TextField(
                controller: locationController,
                onChanged: _fetchGeocodingResults,
                decoration: InputDecoration(
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

              InkWell(
                onTap: _saveChanges,
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
                          isSaving // ✅ Use isSaving here
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

              TextButton(
                onPressed: _deleteAccount,
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
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
