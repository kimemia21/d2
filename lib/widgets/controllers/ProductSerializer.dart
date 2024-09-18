class ProductController {
  final String product_name;
  final int product_id;
  final int brand;
  final int buying_price;
  final int selling_price;
  final int quantity;

  ProductController(
      {required this.product_name,
      required this.product_id,
      required this.brand,
      required this.buying_price,
      required this.selling_price,
      required this.quantity});

  factory ProductController.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing ProductController from JSON: $json");

      final keys = [
        "category",
        "brand",
        "product_name",
        "buying_price",
        "selling_price",
        "quantity",
        "id"
      ];

      for (var key in keys) {
        if (!json.containsKey(key)) {
          print("Missing key in ProductController JSON: $key");
          throw Exception("Missing key: $key");
        }
      }

      // final brandValue = json["brand"];
      // final brandId = brandValue is Map ? brandValue["id"] : brandValue;

      // if (brandId is! int) {
      //   print("Invalid brand ID type: ${brandId.runtimeType}");
      //   throw Exception("Brand ID must be an integer");
      // }

      return ProductController(
          product_name: json["product_name"] as String,
          product_id: json["id"] as int,
          brand: json["brand"] as int,
          buying_price: json["buying_price"] as int,
          selling_price: json["selling_price"] as int,
          quantity: json["quantity"] as int);
    } catch (e) {
      print("Error in ProductController.fromJson: $e");
      rethrow;
    }
  }
}
