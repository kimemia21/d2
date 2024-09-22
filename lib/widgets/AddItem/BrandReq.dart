import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class BrandRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  // Fetch only the 'id' and 'name' fields from the Brand
  static Future<List<Map<String, dynamic>>> fetchBrand(
      BuildContext context) async {
    try {
      final Uri uri = Uri.parse("$mainUrl/brands");
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        // "x-auth-token": Provider.of<appBloc>(context, listen: false).token,
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        List<dynamic> BrandJson = responseData['brands'];
        print(BrandJson);

        // Return only a list of maps with id and name
        List<Map<String, dynamic>> Brand = BrandJson
            .map((Brand) => {
                  "id": Brand["id"],
                  "brand_name": Brand["brand_name"],
                })
            .toList();

        return Brand;
      } else {
        throw Exception('Failed to fetch Brand');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('An error occurred while fetching Brand: $e');
    }
  }
}
