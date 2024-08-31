import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  final productName;
  final productData;
  const ProductPage({required this.productName, required this.productData});
  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Product> products;
  //   Product("Helmet", 10, 5),
  //   Product("Gloves", 20, 8),
  //   Product("Jacket", 15, 3),
  //   Product("Boots", 12, 6),
  //   Product("Knee Guards", 25, 10),
  //   Product("Goggles", 30, 15),
  //   Product("Back Protector", 18, 7),
  //   Product("Riding Pants", 22, 9),
  //   Product("Chain Lube", 40, 20),
  //   Product("Bike Cover", 35, 12),
  // ];

  @override
  void initState() {
    super.initState();
      products = [
      for (var data in widget.productData)
        Product(data["name"], data["total"], data["sold"])
    ];
    _tabController = TabController(length: products.length, vsync: this);
  
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: products.map((product) => Tab(text: product.name)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: products
            .map((product) => ProductDisplay(product: product))
            .toList(),
      ),
    );
  }
}

class Product {
  final String name;
  final int total;
  final int sold;

  Product(this.name, this.total, this.sold);

  int get remaining => total - sold;
}

class ProductDisplay extends StatelessWidget {
  final Product product;

  const ProductDisplay({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            product.name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Total: ${product.total}'),
          Text('Sold: ${product.sold}'),
          Text('Remaining: ${product.remaining}'),
          SizedBox(height: 20),
          CircularProgressIndicator(
            value: product.sold / product.total,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          SizedBox(height: 10),
          Text(
              '${(product.sold / product.total * 100).toStringAsFixed(1)}% Sold'),
        ],
      ),
    );
  }
}
