import 'dart:convert';

import 'package:application/widgets/controllers/Serializers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AppRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  static Future<List<CategoryController>> getCategorites() async {
    final url = "$mainUrl/category";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List<dynamic>;
        CategoryController.fromJsonList(body);
        return CategoryController.fromJsonList(body);

        // print("this is the data $body");
        // return Categorycontroller.fromjson(body);
      } else {
        print(response.statusCode);
        return [];
      }
    } catch (e) {
      print("error on getcategorie function $e");
      throw Exception(e);
    }
  }

  static Future<List<ProductController>> getProducts() async {
    final url = "$mainUrl/product";
    final request = await http.get(Uri.parse(url));
    if (request.statusCode == 200) {
      final body = jsonDecode(request.body) as List<dynamic>;
      print(body);
      return ProductController.fromJsonList(body);
    } else {
      throw Exception("response code error ${request.statusCode}");
    }
  }
}
