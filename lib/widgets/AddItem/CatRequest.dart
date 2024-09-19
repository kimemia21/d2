import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class CategoryRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  // Fetch only the 'id' and 'name' fields from the category
  static Future<List<Map<String, dynamic>>> fetchCategory(
      BuildContext context) async {
    try {
      final Uri uri = Uri.parse("$mainUrl/category");
      final Map<String, String> headers = {
        "Content-Type": "application/json",
        // "x-auth-token": Provider.of<appBloc>(context, listen: false).token,
      };

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        List<dynamic> categoryJson = responseData['categories'];
        print(categoryJson);

        // Return only a list of maps with id and name
        List<Map<String, dynamic>> category = categoryJson
            .map((category) => {
                  "id": category["id"],
                  "category_name": category["category_name"],
                })
            .toList();

        return category;
      } else {
        throw Exception('Failed to fetch category');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('An error occurred while fetching category: $e');
    }
  }
}
