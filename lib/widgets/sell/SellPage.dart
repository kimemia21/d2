import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BikePOSPage extends StatefulWidget {
  const BikePOSPage({Key? key}) : super(key: key);

  @override
  _BikePOSPageState createState() => _BikePOSPageState();
}

class _BikePOSPageState extends State<BikePOSPage> {
  final formatter = NumberFormat("#,##0.00", "en_US");
  int selectedCategoryIndex = 0;
  List<Map<String, dynamic>> cart = [];

  // Sample data
  final List<Map<String, dynamic>> categories = [
    {'id': 'all', 'name': 'All Bikes', 'icon': Icons.pedal_bike},
    {'id': 'mountain', 'name': 'Mountain', 'icon': Icons.landscape},
    {'id': 'road', 'name': 'Road', 'icon': Icons.route},
    {'id': 'electric', 'name': 'Electric', 'icon': Icons.electric_bike},
    {'id': 'accessories', 'name': 'Accessories', 'icon': Icons.shopping_bag},
  ];

  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'name': 'Mountain Pro X1',
      'category': 'mountain',
      'price': 899.99,
      'stock': 5,
      'description': 'Professional mountain bike with advanced features'
    },
    {
      'id': '2',
      'name': 'Road Elite R2',
      'category': 'road',
      'price': 1299.99,
      'stock': 3,
      'description': 'High-performance road bike for serious cyclists'
    },
    {
      'id': '3',
      'name': 'E-Bike City',
      'category': 'electric',
      'price': 1899.99,
      'stock': 4,
      'description': 'Urban electric bike with long-range battery'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left side - Products
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(),
                  // Category Selector
                  _buildCategorySelector(),
                  // Products Grid
                  _buildProductsGrid(),
                ],
              ),
            ),
          ),
          // Right side - Cart
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            color: Colors.white,
            child: _buildCart(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and Title
          Row(
            children: [
              Icon(Icons.pedal_bike, size: 32, color: Colors.blue[600]),
              const SizedBox(width: 12),
              Text(
                'Bike POS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const Spacer(),
          // Search Bar
          Container(
            width: 300,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Settings Button
          IconButton(
            icon: Icon(Icons.settings, color: Colors.grey[600]),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryIndex == index;
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Material(
              color: isSelected ? Colors.blue[600] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => setState(() => selectedCategoryIndex = index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      Icon(
                        category['icon'],
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['name'],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _addToCart(product),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.pedal_bike,
                            color: Colors.blue[600],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      product['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${formatter.format(product['price'])}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Stock: ${product['stock']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCart() {
    final total = cart.fold<double>(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );

    return Column(
      children: [
        // Cart Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.shopping_cart, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text(
                'Current Sale',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Cart Items
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cart.length,
            itemBuilder: (context, index) {
              final item = cart[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text('\$${formatter.format(item['price'])}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateQuantity(index, -1),
                      ),
                      Text('${item['quantity']}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateQuantity(index, 1),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Cart Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${formatter.format(total)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _processPayment(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment),
                      SizedBox(width: 8),
                      Text(
                        'Process Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final existingIndex = cart.indexWhere((item) => item['id'] == product['id']);
      if (existingIndex >= 0) {
        cart[existingIndex]['quantity']++;
      } else {
        cart.add({...product, 'quantity': 1});
      }
    });
  }

  void _updateQuantity(int index, int change) {
    setState(() {
      final newQuantity = cart[index]['quantity'] + change;
      if (newQuantity > 0) {
        cart[index]['quantity'] = newQuantity;
      } else {
        cart.removeAt(index);
      }
    });
  }

  void _processPayment() {
    // Implement payment processing logic
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: const Text('Implement payment processing here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}