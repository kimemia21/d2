import 'package:application/widgets/Firebase/FirebaseModels/FirebaseStore.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/nodata/nodata.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Cart {
  String productId;
  Stock stock;
  int quantity;
  Cart({required this.productId, required this.stock, required this.quantity});
}

void addToCart(List<Cart> sale, Cart instance) {
 
  final existingCart = sale.firstWhere(
    (cart) => cart.productId == instance.productId,
    orElse: () => instance,
  );

  if (existingCart == instance) {
   
    sale.add(instance);
  } else {
   
    existingCart.quantity += 1;
  }
}

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
  late Future<List<Brand>> _brand;
  List<Cart> sale = [];
  int isSelected = 0;

  @override
  void initState() {
    super.initState();
    getter();
  }

  void getter() {
    getCategories();
    getProducts();
    getBrands();
  }

  void getCategories() {
    _categories = FirestoreService().getCategories(isFiltered: false);
  }

  void getProducts() {
    _stock = FirestoreService().getStock(isFiltered: false);
  }

  void getBrands() {
    _brand = FirestoreService().getAllBrands();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Bar
                  _buildTopBar(),
                  // Category Selector
                  _buildBrandSelector(),
                  _buildCategoryDropDown(),
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
                'D2 POS',
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
          // Container(
          //   width: 300,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: Colors.grey[100],
          //     borderRadius: BorderRadius.circular(8),
          //   ),
          //   child: TextField(
          //     decoration: InputDecoration(
          //       hintText: 'Search products...',
          //       prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          //       border: InputBorder.none,
          //       contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          //     ),
          //   ),
          // ),
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

  Widget _buildBrandSelector() {
    return FutureBuilder<List<Brand>>(
      future: _brand,
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
                final brand = entry.value;

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
                          _stock = FirestoreService().getStock(
                              isFiltered: true,
                              filterName: "brandId",
                              filterValue: brand.id);

                          // _categories =FirestoreService().getCategories(isFiltered: true,filterName: "",filterValue: "")
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        child: Text(
                          brand.name,
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

  Widget _buildCategoryDropDown() {
    return Row(
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Select Category:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder<List<Category>>(
              future: _categories,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return DropdownButton<String>(
                  value: snapshot.data![selectedCategoryIndex].id,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategoryIndex = snapshot.data!
                          .indexWhere((category) => category.id == newValue);
                      _stock = FirestoreService().getStock(
                          isFiltered: true,
                          filterName: "categoryId",
                          filterValue: newValue);
                    });
                  },
                  items: snapshot.data!
                      .map<DropdownMenuItem<String>>((Category category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                );
              }),
        ),
      ],
    );
  }

  Widget _buildProductView() {
    return FutureBuilder(
      future: _stock,
      builder: (context, snapshot) {
        if (snapshot.data!.length < 1) {
          return NoDataScreen();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("Connection state: : ${snapshot.connectionState}");

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Products...',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: snapshot.data!.asMap().entries.map((entry) {
              int index = entry.key; // Get the index
              var stock = entry.value; // Get the value (stock)
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: _buildProductCard(context, stock, index),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Stock stock, int index) {
    final formatter = NumberFormat("#,##0.00", "en_US");
    final bool isOutOfStock = stock.quantity <= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOutOfStock ? Colors.red.shade200 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isOutOfStock ? Colors.red.shade50 : Colors.white,
      child: InkWell(
        onTap: isOutOfStock
            ? null
            : () {
                _showProductDetails(context, stock);
                // Handle add to cart or quick sale
              },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image with enhanced container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Details with enhanced typography
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.product.brandName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stock.product.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stock.product.categoryName,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price and Stock with enhanced styling
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '\$${formatter.format(stock.product.sellingPrice)}',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isOutOfStock ? Colors.red[50] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isOutOfStock
                                ? Colors.red.shade200
                                : Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isOutOfStock
                                  ? Icons.error_outline
                                  : Icons.check_circle_outline,
                              size: 14,
                              color: isOutOfStock ? Colors.red : Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isOutOfStock
                                  ? 'Out of Stock'
                                  : 'In Stock: ${stock.quantity}',
                              style: TextStyle(
                                color: isOutOfStock ? Colors.red : Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (!isOutOfStock) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          final Cart instance = Cart(
                              productId: stock.productId,
                              stock: stock,
                              quantity: 1);
                          addToCart(sale, instance);
                          print(sale);
                        });
                        // Handle quick sale
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text(
                        'Quick Sell',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
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

  void _showProductDetails(BuildContext context, Stock stock) {
    final formatter = NumberFormat("#,##0.00", "en_US");

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: double.minPositive,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Product basic info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Colors.grey,
                      size: 48,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.product.brandName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            stock.product.categoryName,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          stock.product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Price and stock info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoItem(
                    'Price',
                    '\$${formatter.format(stock.product.sellingPrice)}',
                    Colors.green,
                  ),
                  _buildInfoItem(
                    'Stock',
                    '${stock.quantity} units',
                    Colors.blue,
                  ),
                  // _buildInfoItem(
                  //   'SKU',
                  //   stock.product.sku ?? 'N/A',
                  //   Colors.grey,
                  // ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 8),
                  if (stock.quantity > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle quick sale
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                      label: const Text('Quick Sell'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color[700],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color[700],
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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
            itemCount: sale.length,
            itemBuilder: (context, index) {
              final item = sale[index];
              print(sale);
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(item.stock.product.name),
                  subtitle: Text(
                      '\$${formatter.format(item.stock.product.sellingPrice)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => _updateQuantity(index, -1),
                      ),
                      Text('${item.stock.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => _updateQuantity(index, 1),
                      ),
                      IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              sale.removeAt(index);
                            });
                          }),
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