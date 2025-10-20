import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MangoService {
  final String baseUrl = "https://minfo-backend.onrender.com/api/mangoType";

  // Fetch mango types for mandi
  Future<List<dynamic>> fetchMangoTypes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mandiId = prefs.getString("mandiId");
      if (mandiId == null) return [];

      final response = await http.get(
        Uri.parse("$baseUrl/get/$mandiId"),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["success"] == true) {
          return data["mangoTypes"];
        }
      }
      return [];
    } catch (e) {
      print("fetchMangoTypes error: $e");
      return [];
    }
  }

  // Add mango type with image upload
  Future<Map<String, dynamic>> addMangoType({
    required String type,
    required String price,
    required String capacity,
    required File imageFile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mandiId = prefs.getString("mandiId");
      if (mandiId == null) {
        return {"success": false, "message": "Mandi ID not found"};
      }

      final uri = Uri.parse("$baseUrl/add");
      final request = http.MultipartRequest("POST", uri);

      request.fields["type"] = type;
      request.fields["price"] = price;
      request.fields["capacity"] = capacity;
      request.fields["mandiId"] = mandiId;

      request.files.add(
        await http.MultipartFile.fromPath("image", imageFile.path),
      );

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      return data;
    } catch (e) {
      print("addMangoType error: $e");
      return {"success": false, "message": e.toString()};
    }
  }

  Future<bool> updateMangoType({
    required String id,
    required String typeName,
    required double price,
    required double capacity,
    File? imageFile,
  }) async {
    try {
      // ✅ Retrieve mandiId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final mandiId = prefs.getString("mandiId");

      if (mandiId == null) {
        print("❌ Mandi ID not found in SharedPreferences");
        return false;
      }

      // ✅ Correct endpoint
      final uri = Uri.parse('$baseUrl/update/$id');
      final request = http.MultipartRequest('PUT', uri);

      // ✅ Add fields
      request.fields['typeName'] = typeName;
      request.fields['price'] = price.toString();
      request.fields['buying_capacity'] = capacity.toString();
      request.fields['mandiId'] = mandiId; // include mandiId

      // ✅ Add image if provided
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      // ✅ Send request
      final response = await request.send();

      if (response.statusCode == 200) {
        print("✅ Mango type updated successfully");
        return true;
      } else {
        final respStr = await response.stream.bytesToString();
        print("❌ Failed to update mango type: $respStr");
        return false;
      }
    } catch (e) {
      print("Error updating mango type: $e");
      return false;
    }
  }

  /// 🔴 Delete mango type
  Future<bool> deleteMangoType(String id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/delete/$id"));

      if (response.statusCode == 200) {
        print("✅ Mango deleted successfully");
        return true;
      } else {
        print("❌ Failed to delete mango: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error deleting mango: $e");
      return false;
    }
  }
}
