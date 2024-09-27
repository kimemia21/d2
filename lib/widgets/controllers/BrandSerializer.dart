class BrandController {
  final String name;
  final int id;
  final int category;

  const BrandController({
    required this.name,
    required this.id,
    required this.category,
  });

  factory BrandController.fromJson(Map<String, dynamic> json) {
    try {
      print("Parsing BrandController from JSON: $json");

      const requiredKeys = ["brand_name", "id", "category"];

      for (var key in requiredKeys) {
        if (!json.containsKey(key)) {
          print("Missing key in BrandController JSON: $key");
          throw Exception("Missing key: $key");
        }
      }

      return BrandController(
        name: json["brand_name"] as String,
        id: json["id"] as int,
        category: json["category"] as int,
      );
    } catch (e) {
      print("Error in BrandController.fromJson: $e");
      rethrow;
    }
  }
}