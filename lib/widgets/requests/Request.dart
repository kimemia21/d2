import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/Inventory.dart';
import 'package:application/widgets/Models/BrandSerializer.dart';
import 'package:application/widgets/Models/CategorySerializers.dart';
import 'package:application/widgets/Models/ProductQuantity.dart';
import 'package:application/widgets/Models/ProductSerializer.dart';
import 'package:application/widgets/Models/ProductWithStock.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:cherry_toast/cherry_toast.dart';

class AppRequest {
  static String mainUrl = "http://127.0.0.1:8000/api";
  static Map<String, String> headers = {"Content-Type": "application/json"};

  static Stream<List<CategoryController>> getCategoriesStream() async* {
    final url = "$mainUrl/category";
    List<CategoryController> previousCategories = [];

    while (true) {
      try {
        final response = await http.get(Uri.parse(url));
        print("b14");

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
      await Future.delayed(const Duration(seconds: 10));
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

          final List<ProductController> currentProducts = productsList
              .map((element) => ProductController.fromJson(element))
              .toList();

          // Only yield new data if it has changed
          if (!_areListsEqual(previousProducts, currentProducts)) {
            previousProducts = currentProducts; // Update the cache
            yield currentProducts;
          }
        } else {
          // Log error and yield an empty list
          print("Response code error ${request.statusCode}");
          yield [];
        }
      } catch (e) {
        // Log exception and yield an empty list
        print("Error fetching products: $e");
        yield [];
      }

      // Poll every 3 seconds
      await Future.delayed(const Duration(seconds: 10));
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
      {required bool isRestock,
      required BuildContext context,
      // this is for handle the activate and deactive  status of a product
      required bool isOnSwitch,
      int? Productid,
      int? stockId,
      Map<String, dynamic>? productData,
      Map<String, dynamic>? stockData,
      VoidCallback? callback}) async {
    try {
      final Appbloc bloc = context.read<Appbloc>();
      bloc.changeLoading(true);

      if (isRestock) {
        final Uri stockUri = Uri.parse("$mainUrl/stock/$stockId");
        final http.Response stockResponse = await http.patch(stockUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(stockData));
        final stockBody = jsonDecode(stockResponse.body);
        if (stockBody["rsp"] == true) {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Stock updated successfully!',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pop(context);
        } else {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "stock error $stockBody",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          print("stock error $stockBody");
        }
      }
      if (isOnSwitch) {
        final Uri productSwitchUri = Uri.parse("$mainUrl/product/$Productid");
        final http.Response switchResponse = await http.patch(productSwitchUri,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(productData));
        final switchBody = jsonDecode(switchResponse.body);
        if (switchBody["rsp"] == true) {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Success !',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          bloc.changeLoading(false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "stock error $switchBody",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          print("stock error $switchBody");
        }
      }

      final Uri productUri = Uri.parse("$mainUrl/product/$Productid");
      final Uri stockUri = Uri.parse("$mainUrl/stock/$stockId");

      final http.Response productResponse = await http.patch(productUri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(productData));

      final http.Response stockResponse = await http.patch(stockUri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(stockData));

      final productBody = jsonDecode(productResponse.body);
      final stockBody = jsonDecode(stockResponse.body);

      if (productBody["rsp"] == true && stockBody["rsp"] == true) {
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
        isRestock
            ? Navigator.pop(context)
            : Globals.switchScreens(context: context, screen: const InventoryPage());
      } else {
        bloc.changeLoading(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "product error $productBody and stock error $stockBody",
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        print("product error $productBody and stock error $stockBody");
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

        final List<BrandController> brands =
            ProductStock.map((element) => BrandController.fromJson(element))
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
    final url = "$mainUrl/category";

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

  static Future CreateBrandOrCategory(
      {required Map<String, dynamic> body,
      required isBrand,
      required BuildContext context}) async {
    final Uri url = Uri.parse("$mainUrl/${isBrand ? "brand" : "category"}");

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Appbloc bloc = context.read<Appbloc>();
    try {
      bloc.changeLoading(true);
      final response =
          await http.post(url, headers: headers, body: jsonEncode(body));
      final resBody = jsonDecode(response.body);
      if (resBody["rsp"] == true) {
        bloc.changeLoading(false);

        Navigator.of(context).pop();
        CherryToast.success(
          title: Text("Success",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          description: Text(
              "added  ${isBrand ? "brand" : "category"} successfully",
              style: GoogleFonts.abel()),
          animationDuration: const Duration(milliseconds: 200),
          animationCurve: Curves.easeInOut,
        ).show(context);
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
      print("error on  CreateBrandOrCategory function $e");
      throw Exception(e);
    }
  }

  static Future<void> CreateProduct({
    required Map<String, dynamic> stockBody,
    required Map<String, dynamic> Productbody,
    required BuildContext context,
  }) async {
    final Uri url = Uri.parse("$mainUrl/product");
    final Uri stockurl = Uri.parse("$mainUrl/stock");

    final Map<String, String> headers = {'Content-Type': 'application/json'};
    final Appbloc bloc = context.read<Appbloc>();

    bloc.changeLoading(true);

    try {
      // Send product creation request
      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(Productbody),
          )
          .timeout(const Duration(seconds: 3)); // Add a timeout

      if (response.statusCode == 201) {
        final PB = jsonDecode(response.body);
        if (PB["rsp"]) {
          var productId = PB["product"]["id"];
          stockBody.addAll({"product": productId});
          print("---------------------$stockBody");

          // Send stock creation request
          final stockResponse = await http
              .post(
                stockurl,
                headers: headers,
                body: jsonEncode(stockBody),
              )
              .timeout(const Duration(seconds: 3));

          if (stockResponse.statusCode == 201) {
            final SB = jsonDecode(stockResponse.body);
            if (SB["rsp"] == true) {
              CherryToast.success(
                title: Text(
                  "Success",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
                description: Text(
                  "Product added successfully",
                  style: GoogleFonts.abel(),
                ),
                animationDuration: const Duration(milliseconds: 200),
                animationCurve: Curves.easeInOut,
              ).show(context);
              Navigator.of(context).pop();
            } else {
              _handleErrorResponse(context, stockResponse);
            }
          } else {
            _handleErrorResponse(context, stockResponse);
          }
        } else {
          _handleErrorResponse(context, response);
        }
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

  static Stream<List<ProductStockController>> StreamGetProductStock(
      int? id) async* {
    final url = id != null ? "$mainUrl/stock/$id" : "$mainUrl/stock";

    try {
      final request = await http.get(Uri.parse(url));

      if (request.statusCode == 200) {
        final body = jsonDecode(request.body);
        final List ProductStock = body["stock"];

        if (ProductStock.isEmpty) {
          yield [];
        } else {
          final List<ProductStockController> productstock = ProductStock.map(
              (element) => ProductStockController.fromJson(element)).toList();
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

  static Stream<List<ProductData>> getProductDataStream(
    int? categoryId,
  ) async* {
    final productUrl = categoryId == null
        ? "$mainUrl/product"
        : "$mainUrl/product/category/$categoryId";

    final stockUrl = "$mainUrl/stock";

    List<ProductData> previousData = [];

    while (true) {
      try {
        // Fetch products and stock data concurrently
        final productsFuture = http.get(Uri.parse(productUrl));

        final results = await productsFuture;

        if (results.statusCode == 200) {
          final productsBody = jsonDecode(results.body);

          final List productsList = productsBody["products"];

          // Combine product and stock data
          final List<ProductData> currentData = productsList.map((product) {
            return ProductData.fromJson(product);
          }).toList();

          // Only yield new data if it has changed
          if (!_ProductDataListsEqual(previousData, currentData)) {
            previousData = currentData;

            yield currentData;
          }
        } else {
          throw Exception(
              "Response code error - Products: ${results.statusCode},");
        }
      } catch (e) {
        print("Error fetching product data: $e");
        yield []; // Yield an empty list in case of error
      }

      // Poll every 3 seconds
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  // Helper method to compare lists
  static bool _ProductDataListsEqual(
      List<ProductData> list1, List<ProductData> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i].id != list2[i].id ||
          list1[i].quantity != list2[i].quantity ||
          list1[i].sellingPrice != list2[i].sellingPrice) {
        return false;
      }
    }
    return true;
  }

  static Future StockMovement(
      {required BuildContext context,
      required Map<String, dynamic> body}) async {
    final Uri uri = Uri.parse("$mainUrl/stock_movement");
    print(jsonEncode(body));
    final response =
        await http.post(uri, headers: headers, body: jsonEncode(body));

    final rsBody = jsonDecode(response.body);
    if (rsBody["rsp"]) {
      CherryToast.success(
        title: Text(
          "Success",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        description: Text(
          "Restocked",
          style: GoogleFonts.abel(),
        ),
        animationDuration: const Duration(milliseconds: 200),
        animationCurve: Curves.easeInOut,
      ).show(context);
    } else {
      print("------- movement stock error ${rsBody["msg"]} ");
      _showErrorSnackBar(context, rsBody["msg"]);
    }
  }
}
