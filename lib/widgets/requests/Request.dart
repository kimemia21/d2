import 'dart:convert';

import 'package:application/widgets/controllers/categoryController.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  static Future <List<CategoryController>> getCategorites() async {
    final url = "$mainUrl/category";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body ) as List<dynamic>;
        CategoryController.fromJsonList(body);
        return CategoryController.fromJsonList(body);

        // print("this is the data $body");
        // return Categorycontroller.fromjson(body);
      } else {
        print(response.statusCode);
        return [];
      }
    } catch (e) {
      throw Exception(e);
      print("error on getcategorie function $e");
    }
  }
}
