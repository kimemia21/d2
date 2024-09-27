class ProductController {
  final String name;
  final int product_id;
  final int brand;
  final int category;
  final double buying_price;
  final double selling_price;


  ProductController({
    required this.category,
    required this.  name,
    required this.product_id,
    required this.brand,
    required this.buying_price,
    required this.selling_price,

  });

  factory ProductController.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing ProductController from JSON: $json");

      final keys = [
        "category",
        "brand",
        "name",
        "buying_price",
        "selling_price",

        "id"
      ];

      for (var key in keys) {
        if (!json.containsKey(key)) {
          print("Missing key in ProductController JSON: $key");
          throw Exception("Missing key: $key");
        }
      }

      return ProductController(
        category: json["category"] as int,
        name: json["name"] as String,
        product_id: json["id"] as int,
        brand: json["brand"] as int,
        buying_price: double.parse(json["buying_price"] as String), // Parse from string to double
        selling_price: double.parse(json["selling_price"] as String), // Parse from string to double
      
      );
    } catch (e) {
      print("Error in ProductController.fromJson: $e");
      rethrow;
    }
  }

 
}
