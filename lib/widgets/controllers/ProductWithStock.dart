// {
//     "products": [
//         {
//             "id": 1,
//             "product": {
//                 "id": 1,
//                 "name": "TVS Star LX",
//                 "category": 1,
//                 "brand": 1,
//                 "barcode": "",
//                 "buying_price": "120.00",
//                 "selling_price": "150.00",
//                 "is_active": true
//             },
//             "quantity": 10,
//             "reorder_level": 5,
//             "last_restocked": "2024-11-02T05:49:35.160816Z"
//         }
//     ]
// }

class ProductData {
  final int id;
  final String name;
  final String brand;
  final String category;
  final int brand_id;
  final int category_id;
  final double buyingPrice;
  final double sellingPrice;
  final bool isActive;
  final  int quantity;
  final int reorderLevel;
  final DateTime lastRestocked;
  final int stockId;

  ProductData({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.category_id,
    required this.brand_id,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.isActive,
    required this.reorderLevel,
    required this.lastRestocked,
    required this.stockId
  });

  factory ProductData.fromJson(Map<String, dynamic> product) {
    final data = ProductData(

      id: product["product"]['id'],
      name: product["product"]['name'],
      brand: product["product"]['brand'],
      brand_id: product["product"]['brand_id'],
      category_id: product["product"]['category_id'],
      category: product["product"]['category'],
      isActive: product["product"]["is_active"],
      buyingPrice: double.parse(product["product"]['buying_price']),
      sellingPrice: double.parse(product["product"]['selling_price']),
      quantity: product['quantity'] ?? 0,
      reorderLevel: product['reorder_level'] ?? 0,
      lastRestocked: product['last_restocked'] != null
          ? DateTime.parse(product['last_restocked'])
          : DateTime.now(),
      stockId: product["id"]    
    );

    // Check if any fields are null and print the values
    Map<String, dynamic> values = {
      'id': data.id,
      'name': data.name,
      'brand': data.brand,
      'category': data.category,
      'buyingPrice': data.buyingPrice,
      'sellingPrice': data.sellingPrice,
      'quantity': data.quantity,
      'reorderLevel': data.reorderLevel,
      'lastRestocked': data.lastRestocked,
    };

   
    for (var entry in values.entries) {
      if (entry.value == null || entry.value == '' || entry.value == 0) {
        print('Field ${entry.key} contains a null/empty value: ${entry.value}');
      }
    }

    return data;
  }
}
