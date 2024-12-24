class ProductStockController {
  final int id;
  final int product;
  final int quantity;
  final int reorderLevel;
  final DateTime lastRestocked;

  ProductStockController({
    required this.id,
    required this.product,
    required this.quantity,
    required this.reorderLevel,
    required this.lastRestocked,
  });

  // Factory constructor to create a ProductStockController instance from JSON with key presence checks
  factory ProductStockController.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('id') ||
        !json.containsKey('product') ||
        !json.containsKey('quantity') ||
        !json.containsKey('reorder_level') ||
        !json.containsKey('last_restocked')) {
      throw Exception("Missing required fields in JSON data");
    }

    return ProductStockController(
      id: json['id'],
      product: json['product'],
      quantity: json['quantity'],
      reorderLevel: json['reorder_level'],
      lastRestocked: DateTime.parse(json['last_restocked']),
    );
  }
}
