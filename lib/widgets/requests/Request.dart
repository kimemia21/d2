import 'dart:convert';

import 'package:application/main.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/Inventory.dart';
import 'package:application/widgets/controllers/BrandSerializer.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/controllers/ProductSerializer.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:cherry_toast/cherry_toast.dart';

class AppRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  static Future<List<CategoryController>> getCategorites() async {
    final url = "$mainUrl/category";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> categoryList = body["categories"];
        // CategoryController.fromJsonList(categoryList);

        return CategoryController.fromJsonList(categoryList);
      } else {
        print(response.statusCode);
        return [];
      }
    } catch (e) {
      print("error on getcategorie function $e");
      throw Exception(e);
    }
  }

  static Future CreateCategory(
      {required Map<String, dynamic> body,
      required BuildContext context}) async {
    final Uri url = Uri.parse("$mainUrl/category");
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 201) {
        bloc.changeLoading(false);
        final body = jsonDecode(response.body);
        final List<dynamic> categoryList = body["categories"];
        print(categoryList);
        bloc.changeLoading(true);
        CherryToast.success(
          title: Text("Success",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          description:
              Text("added category successfully", style: GoogleFonts.abel()),
          animationDuration: Duration(milliseconds: 200),
          animationCurve: Curves.easeInOut,
        ).show(context);
        Navigator.of(context).pop();
      } else {
        bloc.changeLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.body,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      print("error on getcategorie function $e");
      throw Exception(e);
    }
  }

  static Future<List<ProductController>> getProducts(id) async {
    final url =
        id == null ? "$mainUrl/products" : "$mainUrl/products/category/$id";
    final request = await http.get(Uri.parse(url));

    if (request.statusCode == 200) {
      final body = jsonDecode(request.body); // Decode the response body
      // Access the 'products' key in the response
      final List productsList = body["products"];

      print(productsList);

      // Map the 'products' list to a list of ProductController objects
      final products = productsList
          .map<ProductController>(
              (element) => ProductController.fromJson(element))
          .toList();

      return products;
    } else {
      throw Exception("Response code error ${request.statusCode}");
    }
  }

  static Future patchProduct(
      {required BuildContext context,
      required int id,
      required Map<String, dynamic> data}) async {
    try {
      final Appbloc bloc = context.read<Appbloc>();
      bloc.changeLoading(true);
      final Uri uri = Uri.parse("$mainUrl/product/$id");
      final http.Response response = await http.patch(uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(data));

      if (response.statusCode == 200) {
        bloc.changeLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Product updated successfully!',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Globals.switchScreens(context: context, screen: InventoryPage());
      } else {
        bloc.changeLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response.body,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        print(response.body);
      }
    } catch (e) {
      print("err in patchProduct $e");
    }
  }

  static Future<List<BrandController>> getBrands(int? id) async {
    final url = id != null ? "$mainUrl/brand/$id" : "$mainUrl/brand";

    try {
      final request = await http.get(Uri.parse(url));

      if (request.statusCode == 200) {
        final body = jsonDecode(request.body);
        final List brandList = body["brands"];

        if (brandList.isEmpty) {
          return [];
        }

        final List<BrandController> brands = brandList
            .map((element) => BrandController.fromJson(element))
            .toList();
        return brands;
      } else {
        throw Exception("Response code error ${request.statusCode}");
      }
    } catch (e) {
      print("Error fetching brands: $e");
      throw Exception("Error fetching brands: $e");
    }
  }
}
