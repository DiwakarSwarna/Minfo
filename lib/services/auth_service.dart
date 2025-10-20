import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = "https://minfo-backend.onrender.com/api/auth";

  // Send OTP
  // Future<Map<String, dynamic>> sendOtp(String email) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/send-otp"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({"email": email}),
  //     );

  //     final data = jsonDecode(response.body);
  //     return {
  //       "success": response.statusCode == 200 && data["success"] == true,
  //       "message": data["message"] ?? "Something went wrong",
  //     };
  //   } catch (e) {
  //     return {"success": false, "message": "Error: $e"};
  //   }
  // }

  // Send OTP (for register or forgot password)
  Future<Map<String, dynamic>> sendOtp(
    String email, {
    String type = "register",
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "type": type, // 👈 either "register" or "forgotPassword"
        }),
      );

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200 && data["success"] == true,
        "message": data["message"] ?? "Something went wrong",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // Verify OTP
  Future<bool> verifyOtp(String email, String otp) async {
    // print(email);
    // print(otp);
    final res = await http.post(
      Uri.parse("$baseUrl/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp}),
    );

    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['success'] == true;
    }
    return false;
  }

  // ✅ Register user and save token
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String role,
    String mandiName = "",
    String ownerName = "",
    double latitude = 0,
    double longitude = 0,
    String farmerName = "",
    List<Map<String, dynamic>> farmerMangoTypes = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
          "role": role,
          "mandiName": mandiName,
          "ownerName": ownerName,
          "latitude": latitude,
          "longitude": longitude,
          "farmerName": farmerName,
          "farmerMangoTypes": farmerMangoTypes,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data["success"] == true) {
        final prefs = await SharedPreferences.getInstance();
        print('manoj$data');

        await prefs.setString("authToken", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));
        await prefs.setString("role", data["user"]["role"]);
        await prefs.setString("email", data["user"]["email"]);

        print(data["user"]["mandiId"]);
        // ✅ Save mandiId if exists
        if (data["user"]["mandiId"] != null) {
          await prefs.setString("mandiId", data["user"]["mandiId"]);
        }

        return {
          "success": true,
          "message": data["message"],
          "user": data["user"],
          "token": data["token"],
        };
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Something went wrong",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // ✅ Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          data["success"] == true &&
          data["token"] != null) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString("authToken", data["token"]);
        await prefs.setString("user", jsonEncode(data["user"]));
        await prefs.setString("role", data["user"]["role"]);
        await prefs.setString("email", data["user"]["email"]);

        // ✅ Save mandiId if exists
        if (data["user"]["mandiId"] != null) {
          await prefs.setString("mandiId", data["user"]["mandiId"]);
        }
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // ✅ Helper: get saved mandiId
  Future<String?> getMandiId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("mandiId");
  }

  /// ✅ Update Mandi Profile
  Future<Map<String, dynamic>> updateMandiProfile({
    required String userId,
    required String mandiname,
    required String username,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/update/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mandiname": mandiname,
          "username": username,
          "location": {
            "type": "Point",
            "coordinates": [longitude, latitude],
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data['updatedUser'] ?? data};
      } else {
        return {
          "success": false,
          "message":
              "Server responded with status ${response.statusCode}: ${response.body}",
        };
      }
    } catch (e) {
      print("❌ Error in updateMandiProfile: $e");
      return {"success": false, "message": "Network or server error: $e"};
    }
  }

  /// ✅ Update Farmer Profile
  Future<Map<String, dynamic>> updateFarmerProfile({
    required String userId,
    required String username,
    required List<Map<String, String>> farmerMangoTypes, // 👈 now objects
    required double latitude,
    required double longitude,
  }) async {
    try {
      // print("objects: $farmerMangoTypes");
      final response = await http.put(
        Uri.parse("$baseUrl/update/farmer/$userId"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "farmerMangoTypes": farmerMangoTypes, // send as objects
          "location": {
            "type": "Point",
            "coordinates": [longitude, latitude],
          },
        }),
      );

      // print('------------------------------------------------');
      // print(response.statusCode);
      // print(response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {"success": true, "data": data['updatedUser'] ?? data};
      } else {
        return {
          "success": false,
          "message":
              "Server responded with status ${response.statusCode}: ${response.body}",
        };
      }
    } catch (e) {
      print("❌ Error in updateFarmerProfile: $e");
      return {"success": false, "message": "Network or server error: $e"};
    }
  }

  // ✅ Get Mandi by ID
  Future<Map<String, dynamic>> getMandiById(String id) async {
    try {
      // print("Calling GET /farmer/$id");
      final response = await http.get(Uri.parse("$baseUrl/mandi/$id"));

      // print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // print(data);
        return {
          "success": data['success'] ?? true,
          "mandi": data['mandi'], // ✅ Match backend response
        };
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("❌ Error in getFarmerById: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  //Get Farmer by ID
  Future<Map<String, dynamic>> getFarmerById(String id) async {
    try {
      // print("Calling GET /farmer/$id");
      final response = await http.get(Uri.parse("$baseUrl/farmer/$id"));

      // print("Response status: ${response.statusCode}");
      // print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": data['success'] ?? true,
          "farmer": data['farmer'], // ✅ Match backend response
        };
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("❌ Error in getFarmerById: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  // /// ✅ Get Farmer Profile
  // Future<Map<String, dynamic>?> getFarmerProfile(String userId) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse("$baseUrl/users/farmer/$userId"),
  //     );
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body)['user'];
  //     }
  //   } catch (e) {
  //     print("Error fetching farmer profile: $e");
  //   }
  //   return null;
  // }

  // /// ✅ Update Farmer Profile
  // Future<bool> updateFarmerProfile(
  //   String userId,
  //   Map<String, dynamic> updates,
  // ) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse("$baseUrl/users/farmer/update/$userId"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(updates),
  //     );
  //     return response.statusCode == 200;
  //   } catch (e) {
  //     print("Error updating farmer profile: $e");
  //     return false;
  //   }
  // }

  //Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/reset-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "newPassword": newPassword}),
      );

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200 && data["success"] == true,
        "message": data["message"] ?? "Something went wrong",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  /// ✅ Change Password with old password verification
  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/change-password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      return {
        "success": response.statusCode == 200 && data["success"] == true,
        "message": data["message"] ?? "Something went wrong",
      };
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  // ✅ Delete user account
  Future<Map<String, dynamic>> deleteAccount({
    required String userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse("$baseUrl/user/delete/$userId");

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': "Failed to delete account: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {'success': false, 'message': "Error deleting account: $e"};
    }
  }
  // // Register user and save token
  // Future<Map<String, dynamic>> registerUser({
  //   required String email,
  //   required String password,
  //   required String role,
  //   String mandiName = "",
  //   String ownerName = "",
  //   double latitude = 0,
  //   double longitude = 0,
  // }) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("$baseUrl/register"),
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode({
  //         "email": email,
  //         "password": password,
  //         "role": role,
  //         "mandiName": mandiName,
  //         "ownerName": ownerName,
  //         "latitude": latitude,
  //         "longitude": longitude,
  //       }),
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 201 && data["success"] == true) {
  //       // ✅ Save token locally
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString("authToken", data["token"]);
  //       await prefs.setString("user", jsonEncode(data["user"]));

  //       return {
  //         "success": true,
  //         "message": data["message"],
  //         "user": data["user"],
  //         "token": data["token"],
  //       };
  //     } else {
  //       return {
  //         "success": false,
  //         "message": data["message"] ?? "Something went wrong",
  //       };
  //     }
  //   } catch (e) {
  //     return {"success": false, "message": "Error: $e"};
  //   }
  // }

  // // ✅ Login user
  // Future<Map<String, dynamic>> loginUser(String email, String password) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/login'),
  //     headers: {"Content-Type": "application/json"},
  //     body: jsonEncode({"email": email, "password": password}),
  //   );

  //   final data = jsonDecode(response.body);

  //   if (data["success"] == true && data["token"] != null) {
  //     // Save token locally
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.setString("token", data["token"]);
  //     await prefs.setString("role", data["user"]["role"]);
  //     await prefs.setString("email", data["user"]["email"]);
  //     await prefs.setString("user", jsonEncode(data["user"]));
  //   }

  //   return data;
  // }

  //   // ✅ Get stored token
  //   Future<String?> getToken() async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     return prefs.getString("token");
  //   }

  //   // ✅ Logout user
  //   Future<void> logoutUser() async {
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.remove("token");
  //     await prefs.remove("role");
  //     await prefs.remove("email");
  //   }
  // }

  //   // Get token from storage
  //   Future<String?> getToken() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     return prefs.getString("authToken");
  //   }

  //   // Logout (clear token)
  //   Future<void> logout() async {
  //     final prefs = await SharedPreferences.getInstance();
  //     await prefs.remove("authToken");
  //   }
  // }
}
