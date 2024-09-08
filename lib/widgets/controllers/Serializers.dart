// class CategoryController {
//   final String categoryName;
//   final int id;

//   CategoryController({required this.categoryName, required this.id});

//   // Factory method to handle a single JSON object
//   factory CategoryController.fromJson(Map<String, dynamic> json) {
//     print(json);
//     final requiredKeys = ["category", "brand_name"];
//     if (requiredKeys.every(json.containsKey)) {
//       return CategoryController(
//         categoryName: json["category"]["category_name"],
//         id: json["category"]["id"],
//       );
//     } else {
//       throw FormatException("Missing required keys for CategoryController");
//     }
//   }

//   // Factory method to handle a list of JSON objects
//   static List<CategoryController> fromJsonList(List<dynamic> jsonList) {
//     print(jsonList);
//     return jsonList.map((json) {
//       return CategoryController.fromJson(json);
//     }).toList();
//   }
// }

class CategoryController {
  final String categoryName;
  final int id;

  CategoryController({required this.categoryName, required this.id});

  // Factory method to handle a single JSON object
  factory CategoryController.fromJson(Map<String, dynamic> json) {
    print(json);
    final requiredKeys = ["category_name", "id"];
    if (requiredKeys.every(json.containsKey)) {
      return CategoryController(
        categoryName: json["category_name"],
        id: json["id"],
      );
    } else {
      throw FormatException("Missing required keys for CategoryController");
    }
  }

  // Factory method to handle a list of JSON objects
  static List<CategoryController> fromJsonList(List<dynamic> jsonList) {
    print(jsonList);
    return jsonList.map((json) {
      return CategoryController.fromJson(json);
    }).toList();
  }
}

class ProductController {
  final String product_name;
  final String product_id;
  final String brand;
  final String buying_price;
  final String selling_price;
  final int quantity;
  ProductController(
      {required this.product_name,
      required this.product_id,
      required this.brand,
      required this.buying_price,
      required this.selling_price,
      required this.quantity});

  factory ProductController.fromJson(Map json) {
    final keys = [
      "category",
      "brand",
      "product_name",
      "buying_price",
      "selling_price",
      "quantity"
    ];
    if (keys.every(json.containsKey)) {
      return ProductController(
          product_name: json["product_name"],
          product_id: json["product_id"],
          brand: json["brand"],
          buying_price: json["buying_price"],
          selling_price: json["selling_price"],
          quantity: json["quantity"]);
    } else {
      throw Exception("Missing required keys for ProductController");
    }
  }

  static List<ProductController> fromJsonList(List<dynamic> jsonList) {
    print(jsonList);
    return jsonList.map((json) {
      return ProductController.fromJson(json);
    }).toList();
  }

}
