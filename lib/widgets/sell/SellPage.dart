import 'package:application/widgets/Firebase/FirebaseModels/FirebaseStore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalePage extends StatefulWidget {
  const SalePage({Key? key}) : super(key: key);

  @override
  _SalePageState createState() => _SalePageState();
}

class _SalePageState extends State<SalePage> {
  final formatter = NumberFormat("#,##0.00", "en_US");
  int selectedCategoryIndex = 0;
  List<Map<String, dynamic>> cart = [];
  late Future<List<Category>> _categories;
  late Future<List<Stock>> _stock;
  int isSelected = 0;

  @override
  void initState() {
    super.initState();
    getter();
  }

  void getter() {
    getCategories();
    getProducts();
  }

  void getCategories() {
    _categories = FirestoreService().getCategories(isFiltered: false);
  }

  void getProducts() {
    _stock = FirestoreService().getStock(isFiltered: false);
  }

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
                  // Product Cards
                  _buildProductView()
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
    return FutureBuilder<List<Category>>(
      future: FirestoreService().getCategories(isFiltered: false),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // All Bikes button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Material(
                  color: isSelected == 100 ? Colors.blue[600] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() => isSelected = 100),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.pedal_bike,
                            color: isSelected == 100
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "All Bikes",
                            style: TextStyle(
                              color: isSelected == 100
                                  ? Colors.white
                                  : Colors.grey[800],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Category buttons
              ...snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Material(
                    color:
                        isSelected == index ? Colors.blue[600] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        print(index);
                        setState(() {
                          isSelected = index;

                          // _categories =FirestoreService().getCategories(isFiltered: true,filterName: "",filterValue: "")
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected == index
                                ? Colors.white
                                : Colors.grey[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductView() {
  return FutureBuilder(
    future: _stock,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: snapshot.data!.map((stock) {
            return SizedBox(
              width: 300, // Give a fixed width to the card
              child: _buildProductCard(context, stock),
            );
          }).toList(),
        ),
      );
    },
  );
}

Widget _buildProductCard(BuildContext context, Stock stock) {
  final formatter = NumberFormat("#,##0.00", "en_US");
  final bool isOutOfStock = stock.quantity <= 0;

  return Card(
    margin: const EdgeInsets.all(6),
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: isOutOfStock ? Colors.red.shade50 : Colors.white,
    child: InkWell(
      onTap: isOutOfStock ? null : () {
        // Handle add to cart or quick sale
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.grey,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 12),
                // Product Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stock.product.categoryName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Price and Stock
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${formatter.format(stock.product.sellingPrice)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isOutOfStock ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isOutOfStock ? 'Out of Stock' : 'In Stock: ${stock.quantity}',
                        style: TextStyle(
                          color: isOutOfStock ? Colors.red : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!isOutOfStock) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle quick sale
                    },
                    icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                    label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
      final existingIndex =
          cart.indexWhere((item) => item['id'] == product['id']);
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
