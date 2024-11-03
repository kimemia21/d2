import 'package:application/widgets/EditProduct/EditProduct.dart';
import 'package:application/widgets/controllers/ProductWithStock.dart';
import 'package:application/widgets/homepage.dart';
import 'package:application/widgets/nodata/nodata.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:application/widgets/AddItem/AddProduct.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  int selectedCategoryIndex = 100;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  late Stream<List<CategoryController>> categoriesStream;
  late Stream<List<ProductData>> productsStream;

  @override
  void initState() {
    super.initState();
    categoriesStream = AppRequest.getCategoriesStream();
    productsStream = AppRequest.getProductDataStream(null);
    _initAnimation();
  }

  void _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Modern Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Globals.switchScreens(
          context: context,
          screen: AddProductForm(),
        ),
        backgroundColor: Colors.blue[600],
        label: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart),
        elevation: 4,
      ),

      // Modern AppBar with search and actions
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () => Globals.switchScreens(
              context: context,
              screen: MotorbikePOSHomePage(),
            ),
            icon: const Icon(Icons.home_rounded),
            tooltip: 'Home',
          ),
        ),
        title: Text(
          'Inventory Management',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        actions: [
          // Search Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                // Implement search functionality
              },
              icon: const Icon(Icons.search_rounded),
              tooltip: 'Search Products',
            ),
          ),
          // Filter Button
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                // Implement filter functionality
              },
              icon: const Icon(Icons.filter_list_rounded),
              tooltip: 'Filter Products',
            ),
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.blue[600],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue[700]!,
                Colors.blue[500]!,
              ],
            ),
          ),
        ),
      ),

      // Modern Body with StreamBuilder
      body: Container(
        color: Colors.grey[100],
        child: StreamBuilder<List<CategoryController>>(
          stream: categoriesStream,
          builder: (BuildContext context,
              AsyncSnapshot<List<CategoryController>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
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
                      'Loading Inventory...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 48,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error Loading Data',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Implement refresh functionality
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return Column(
                children: [
                  // Stats Summary Card
                  // Container(
                  //   margin: const EdgeInsets.all(16),
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(16),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withOpacity(0.05),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       ),
                  //     ],
                  //   ),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       _buildStatItem(
                  //         icon: Icons.category_rounded,
                  //         label: 'Categories',
                  //         value: '${snapshot.data!.length}',
                  //         color: Colors.blue,
                  //       ),
                  //       _buildStatItem(
                  //         icon: Icons.inventory_2_rounded,
                  //         label: 'Total Products',
                  //         value:"23",

                  //         // value: _calculateTotalProducts(snapshot.data!),
                  //         color: Colors.green,
                  //       ),
                  //       _buildStatItem(
                  //         icon: Icons.warning_rounded,
                  //         label: 'Low Stock',
                  //         value: "23",
                  //         // _calculateLowStockItems(snapshot.data!),
                  //         color: Colors.orange,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Category List
                  Expanded(
                    child: _buildCategoryView(context, snapshot.data!),
                  ),
                ],
              );
            } else {
              return NoDataScreen();
            }
          },
        ),
      ),
    );
  }

// Helper method to build stat items
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

// Helper methods for statistics

// String _calculateTotalProducts(List<CategoryController> categories) {
//   int total = 0;
//   for (var category in categories) {
//     total += categor;
//   }
//   return total.toString();
// }

// String _calculateLowStockItems(List<CategoryController> categories) {
//   int lowStock = 0;
//   for (var category in categories) {
//     for (var product in category.products) {
//       if (product.quantity <= product.reorderLevel) {
//         lowStock++;
//       }
//     }
//   }
//   return lowStock.toString();
  // }
  Widget _buildCategoryView(
      BuildContext context, List<CategoryController> categories) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCategorySelector(categories),
            const SizedBox(height: 20),
            Expanded(child: _buildProductList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(List<CategoryController> categories) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // All Categories Button
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selectedCategoryIndex == 100 ? 1.05 : 1.0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategoryIndex = 100;
                    productsStream = AppRequest.getProductDataStream(null);
                  });
                  _controller.reset();
                  _controller.forward();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 45,
                  decoration: BoxDecoration(
                    color: selectedCategoryIndex == 100
                        ? Colors.blue.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: selectedCategoryIndex == 100
                        ? [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.category_rounded,
                        size: 20,
                        color: selectedCategoryIndex == 100
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "All",
                        style: TextStyle(
                          color: selectedCategoryIndex == 100
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Category List
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategoryIndex == index;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: isSelected ? 1.05 : 1.0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategoryIndex = index;
                          productsStream =
                              AppRequest.getProductDataStream(category.id);
                        });
                        _controller.reset();
                        _controller.forward();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.blue.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          category.name,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: StreamBuilder<List<ProductData>>(
        stream: productsStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ProductData>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return _buildNoDataView();
            } else {
              return _buildProductListView(snapshot.data!);
            }
          } else {
            return Center(child: const Text('No products available.'));
          }
        },
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.info_outline,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'No products available.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Globals.switchScreens(context: context, screen: AddProductForm());
            },
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListView(List<ProductData> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return _buildProductCard(context, product);
      },
    );
  }

 Widget _buildProductCard(BuildContext context, ProductData product) {
  final bool isLowStock = product.quantity <= product.reorderLevel;
  final formatter = NumberFormat("#,##0.00", "en_US");

  return Container(
    margin: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle card tap
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image and ID Section
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.grey,
                            size: 32,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '#${product.id}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Product Details Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: product.isActive,
                                onChanged: (value) {
                                  // Handle status change
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          // Categories and Brand Row
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.category_outlined,
                                      size: 14,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Category ${product.category}',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.purple[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.business_outlined,
                                      size: 14,
                                      color: Colors.purple,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      'Brand ${product.brand}',
                                      style: const TextStyle(
                                        color: Colors.purple,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stock Information
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Current Stock
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.inventory,
                                size: 14,
                                color: isLowStock ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Current Stock',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.quantity}',
                            style: TextStyle(
                              color: isLowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Reorder Level
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.warning_amber_outlined,
                                size: 14,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Reorder Level',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.reorderLevel}',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      // Last Restocked
                      Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.update,
                                size: 14,
                                color: Colors.blue[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Last Restocked',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MM/dd/yy').format(product.lastRestocked),
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Pricing Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Buying Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Buying Price',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${formatter.format(product.buyingPrice)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    // Selling Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.sell_outlined,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              'Selling Price',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '\$${formatter.format(product.sellingPrice)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => Globals.switchScreens(
                        context: context,
                        screen: EditProductPage(product: product,isCreate: false,),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _buildRestockButton(
                        context: context,
                        product: product,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Restock', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  void _showRestockAlert(
      {required BuildContext context, required ProductData product}) {
    TextEditingController restockController = TextEditingController();

    final Appbloc bloc = Provider.of<Appbloc>(context, listen: false);
    String last_restock =
        DateFormat('EEEE, MMMM d, yyyy, hh:mm a').format(product.lastRestocked);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(20),
          title: Text(
            'Restock ${product.name}',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 28, // Adjusted font size
            ),
          ),
          content: Container(
            width: MediaQuery.of(context).size.width *
                0.35, // Custom width (80% of the screen width)
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item ID: ${product.id}', // Placeholder for item number
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Current quantity: ${product.quantity}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 18, // Increased font size
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .1,
                  child: TextField(
                    controller: restockController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Restock Quantity',
                      hintText: 'Enter new quantity',
                      hintStyle:
                          GoogleFonts.poppins(color: Colors.grey, fontSize: 10),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      prefixIcon: Icon(Icons.add_shopping_cart,
                          color: Colors.black, size: 20),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    ),
                    style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 18), // Increased font size
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Last Restocked: $last_restock', // Placeholder for last restock date
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Restocked By: John Doe', // Placeholder for restocked by
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey, fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: bloc.isloading
                  ? LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 20,
                    )
                  : Text(
                      'Restock',
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18), // Increased font size
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                int currentQuantity = product.quantity;
                int newQuantity = int.parse(restockController.text);
                final _quantity = product.quantity + newQuantity;

                final body = {"quantity": _quantity};
                AppRequest.patchProduct(
                    isRestock: true,
                    context: context,
                    id: product.id,
                    data: body);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton({
    required BuildContext context,
    required ProductData product,
  }) {
    return ElevatedButton(
      onPressed: () {
        print("pressed");
        try {
          Globals.switchScreens(
            context: context,
            screen: EditProductPage(product: product, isCreate: false,),
          );
        } catch (e) {
          print("Got this error when switching screens $e");
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Edit'),
    );
  }

  Widget _buildRestockButton(
      {required BuildContext context, required ProductData product}) {
    return ElevatedButton(
      onPressed: () {
        _showRestockAlert(context: context, product: product);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text('Restock'),
    );
  }
}
