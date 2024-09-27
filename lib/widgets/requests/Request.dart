import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:application/main.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/Inventory.dart';
import 'package:application/widgets/controllers/BrandSerializer.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/controllers/ProductQuantity.dart';
import 'package:application/widgets/controllers/ProductSerializer.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:cherry_toast/cherry_toast.dart';

class AppRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";

  static Stream<List<CategoryController>> getCategoriesStream() async* {
    final url = "$mainUrl/category";
    List<CategoryController> previousCategories = [];

    while (true) {
      try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final body = jsonDecode(response.body);
          final List<dynamic> categoriesList = body["categories"];

          // Map the 'categories' list to a list of CategoryController objects
          final List<CategoryController> currentCategories =
              CategoryController.fromJsonList(categoriesList);

          // Only yield new data if it has changed
          if (!_areCategoriesEqual(previousCategories, currentCategories)) {
            previousCategories = currentCategories; // Update the cache
            yield currentCategories;
          }
        } else {
          print("Error: ${response.statusCode}");
          yield [];
        }
      } catch (e) {
        print("Error on getCategories function: $e");
        yield [];
      }

      // Wait for a certain duration before fetching again
      await Future.delayed(Duration(seconds: 10));
    }
  }

// Helper method to compare two lists of CategoryController
  static bool _areCategoriesEqual(
      List<CategoryController> oldList, List<CategoryController> newList) {
    if (oldList.length != newList.length) return false;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return false;
    }

    return true;
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
        final List<dynamic> ProductList = body["categories"];
        print(ProductList);
        bloc.changeLoading(true);
        CherryToast.success(
          title: Text("Success",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          description:
              Text("added product successfully", style: GoogleFonts.abel()),
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
      print("error on product function $e");
      throw Exception(e);
    }
  }

  static Stream<List<ProductController>> getProductsStream(int? id) async* {
    final url =
        id == null ? "$mainUrl/product" : "$mainUrl/product/category/$id";
    List<ProductController> previousProducts = [];

    while (true) {
      try {
        final request = await http.get(Uri.parse(url));

        if (request.statusCode == 200) {
          final body = jsonDecode(request.body);
          final List productsList = body["products"];

          // Map the 'products' list to a list of ProductController objects
          final List<ProductController> currentProducts = productsList
              .map((element) => ProductController.fromJson(element))
              .toList();

          // Only yield new data if it has changed
          if (!_areListsEqual(previousProducts, currentProducts)) {
            previousProducts = currentProducts; // Update the cache
            yield currentProducts;
          }
        } else {
          throw Exception("Response code error ${request.statusCode}");
        }
      } catch (e) {
        throw Exception("Error fetching products: $e");
      }

      // Poll every 3 seconds
      await Future.delayed(Duration(seconds: 3));
    }
  }







// Helper method to compare two lists of ProductController
  static bool _areListsEqual(
      List<ProductController> oldList, List<ProductController> newList) {
    if (oldList.length != newList.length) return false;

    for (int i = 0; i < oldList.length; i++) {
      if (oldList[i] != newList[i]) return false;
    }

    return true;
  }

  static Future patchProduct(
      {
        required bool isRestock,
        required BuildContext context,
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
        isRestock?Navigator.pop(context):
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

  static Future<List<BrandController>> FutureGetBrands(int? id) async {
    final url = id != null ? "$mainUrl/brand/$id" : "$mainUrl/brand";

    try {
      final request = await http.get(Uri.parse(url));

      if (request.statusCode == 200) {
        final body = jsonDecode(request.body);
        final List ProductStock = body["brands"];

        if (ProductStock.isEmpty) {
          return [];
        }

        final List<BrandController> brands = ProductStock
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

    static Future<List<CategoryController>> FutureGetCategories() async {
    final url ="$mainUrl/category";

    try {
      final request = await http.get(Uri.parse(url));

      if (request.statusCode == 200) {
        final body = jsonDecode(request.body);
        final List categoryList = body["categories"];

        if (categoryList.isEmpty) {
          return [];
        }

        final List<CategoryController> category = categoryList
            .map((element) => CategoryController.fromJson(element))
            .toList();
        return category;
      } else {
        throw Exception("Response code error ${request.statusCode}");
      }
    } catch (e) {
      print("Error fetching category: $e");
      throw Exception("Error fetching category: $e");
    }
  }

  static Future CreateBrand(
      {required Map<String, dynamic> body,
      required BuildContext context}) async {
    final Uri url = Uri.parse("$mainUrl/brand");
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 201) {
        bloc.changeLoading(false);
        final body = jsonDecode(response.body);
        final List<dynamic> categoryList = body["brands"];
        print(categoryList);
        bloc.changeLoading(true);
        CherryToast.success(
          title: Text("Success",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          description:
              Text("added brand successfully", style: GoogleFonts.abel()),
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
      print("error on getbrand function $e");
      throw Exception(e);
    }
  }

  static Future<void> CreateProduct({
    required Map<String, dynamic> body,
    required BuildContext context,
  }) async {
    final Uri url = Uri.parse("$mainUrl/product");
    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Appbloc bloc = context.read<Appbloc>();

    bloc.changeLoading(true);

    try {
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 3)); // Add a timeout

      if (response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);

        print("-----------------------$responseBody------------------------");
        CherryToast.success(
          title: Text(
            "Success",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          description: Text(
            "Product added successfully",
            style: GoogleFonts.abel(),
          ),
          animationDuration: Duration(milliseconds: 200),
          animationCurve: Curves.easeInOut,
        ).show(context);

        Navigator.of(context).pop();
      } else {
        _handleErrorResponse(context, response);
      }
    } catch (e) {
      _handleException(context, e);
    } finally {
      bloc.changeLoading(false);
    }
  }

  static void _handleErrorResponse(
      BuildContext context, http.Response response) {
    String errorMessage;
    try {
      final errorBody = jsonDecode(response.body);
      errorMessage = errorBody['msg'] ?? 'An error occurred';
    } catch (_) {
      errorMessage = 'An unexpected error occurred';
    }

    _showErrorSnackBar(context, errorMessage);
  }

  static void _handleException(BuildContext context, dynamic exception) {
    String errorMessage;
    if (exception is TimeoutException) {
      errorMessage = 'The request timed out. Please try again.';
    } else if (exception is SocketException) {
      errorMessage = 'No internet connection. Please check your network.';
    } else {
      errorMessage = 'An unexpected error occurred: ${exception.toString()}';
    }

    _showErrorSnackBar(context, errorMessage);
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

 static Stream<List<ProductStockController>> StreamGetProductStock(int? id) async* {
  final url = id != null ? "$mainUrl/stock/$id" : "$mainUrl/stock";

  try {
    final request = await http.get(Uri.parse(url));

    if (request.statusCode == 200) {
      final body = jsonDecode(request.body);
      final List ProductStock = body["stock"];

      if (ProductStock.isEmpty) {
        yield [];
      } else {
        final List<ProductStockController> productstock = ProductStock
            .map((element) => ProductStockController.fromJson(element))
            .toList();
        yield productstock;
      }
    } else {
      throw Exception("Response code error ${request.statusCode}");
    }
  } catch (e) {
    print("Error fetching productstock: $e");
    throw Exception("Error fetching productstock: $e");
  }
}




}
