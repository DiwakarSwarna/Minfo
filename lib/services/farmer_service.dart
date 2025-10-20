import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FarmerService {
  final String baseUrl = "https://minfo-backend.onrender.com/api/farmer";

  Future<Map<String, dynamic>> fetchDashboardData({int radiusKm = 500}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString("user");
      if (userJson == null) {
        return {"success": false, "filters": [], "types": []};
      }

      final user = jsonDecode(userJson);
      print("----------------------------------------------");
      print(user);
      final farmerId =
          user["farmer"]['_id'] ?? user['populatedUser']["farmer"]['_id'];
      if (farmerId == null) {
        print("----------------------Farmer ID is null-----------------------");
        return {"success": false, "filters": [], "types": []};
      }
      print(farmerId);
      final response = await http.get(
        Uri.parse("$baseUrl/dashboard/$farmerId?radius=$radiusKm"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Dashboard data: $data");
        return {
          "success": data["success"] ?? false,
          "filters": data["filters"] ?? [],
          "types": data["types"] ?? [],
        };
      } else {
        print("-----------------Error----------------");
        print(response.body);
        return {"success": false, "filters": [], "types": []};
      }
    } catch (e) {
      print("Error fetching farmer dashboard: $e");
      return {"success": false, "filters": [], "types": []};
    }
  }

  /// ✅ Fetch farmer dashboard
  // Future<Map<String, dynamic>> getFarmerDashboard({int radiusKm = 20}) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final userJson = prefs.getString("user");
  //     if (userJson == null) {
  //       return {"success": false, "filters": [], "types": []};
  //     }

  //     final user = jsonDecode(userJson);
  //     final farmerId = user["farmer"] ?? user["farmerId"];
  //     if (farmerId == null) {
  //       return {"success": false, "filters": [], "types": []};
  //     }

  //     final response = await http.get(
  //       Uri.parse("$baseUrl/dashboard/$farmerId?radius=$radiusKm"),
  //       headers: {"Content-Type": "application/json"},
  //     );

  //     final data = jsonDecode(response.body);
  //     if (response.statusCode == 200 && data["success"] == true) {
  //       return {
  //         "success": true,
  //         "filters": List<String>.from(
  //           data["filters"].map((f) => f["typeName"]),
  //         ),
  //         "types": List<Map<String, dynamic>>.from(data["types"]),
  //       };
  //     } else {
  //       return {"success": false, "filters": [], "types": []};
  //     }
  //   } catch (e) {
  //     print("getFarmerDashboard error: $e");
  //     return {"success": false, "filters": [], "types": []};
  //   }
  // }
}
