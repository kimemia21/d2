import 'package:application/widgets/EditProduct.dart';
import 'package:application/widgets/controllers/ProductSerializer.dart';
import 'package:application/widgets/homepage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:application/widgets/AddProduct.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/requests/Request.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  // this number is only for displaying all category
  int selectedCategoryIndex = 100;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Future<List<ProductController>> products;
  late Future<List<CategoryController>> categories; // Cache the Future

  @override
  void initState() {
    super.initState();
    categories = _fetchCategories(); // Only fetch once
    products = _fetchProducts(null); // Cache initial product list
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

  Future<List<CategoryController>> _fetchCategories() async {
    return await AppRequest.getCategorites();
  }

  Future<List<ProductController>> _fetchProducts(categoryId) async {
    return await AppRequest.getProducts(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton.filled(
        onPressed: () => Globals.switchScreens(
          context: context,
          screen: AddProductForm(),
        ),
        icon: const Icon(Icons.add),
      ),
      appBar: AppBar(
        leading: IconButton.filled(
            onPressed: () => Globals.switchScreens(
                context: context, screen: MotorbikePOSHomePage()),
            icon: Icon(Icons.home)),
        title: Text(
          'Inventory',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List<CategoryController>>(
        future: categories, // Use cached future
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final categories = snapshot.data;
            return _buildCategoryView(context, categories);
          }
        },
      ),
    );
  }

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
      height: 50,
      child: Row(
        children: [
          // "All" Button
          GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = 100;
                products = _fetchProducts(null);
              });
              _controller.reset();
              _controller.forward();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selectedCategoryIndex == 100
                    ? Colors.blueGrey
                    : Colors.grey,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                "All",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Category Buttons
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategoryIndex = index;
                      products = _fetchProducts(category.id);
                    });
                    _controller.reset();
                    _controller.forward();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selectedCategoryIndex == index
                          ? Colors.blueGrey
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      category.categoryName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
      child: FutureBuilder<List<ProductController>>(
        future: products, // Use cached future
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductController>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              // Display a message when no products are available
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
              // Action to add new products
              Globals.switchScreens(context: context, screen: AddProductForm());
            },
            child: Text('Add Product'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductListView(List<ProductController> products) {
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCard(product);
      },
    );
  }

  Widget _buildProductCard(ProductController product) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          product.product_name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Quantity: ${product.quantity}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildEditButton(
                productName: product.product_name,
                productId: product.product_id,
                brand: product.brand,
                buyingPrice: product.buying_price,
                sellingPrice: product.selling_price,
                quantity: product.quantity),
            const SizedBox(width: 8),
            _buildRestockButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required String productName,
    required int productId,
    required int brand,
    required int buyingPrice,
    required int sellingPrice,
    required int quantity,
  }) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to EditProductPage with the required parameters
        Globals.switchScreens(
          context: context,
          screen: EditProductPage(
            productName: productName,
            productId: productId,
            brand: brand,
            buyingPrice: buyingPrice,
            sellingPrice: sellingPrice,
            quantity: quantity,
          ),
        );
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

  Widget _buildRestockButton() {
    return ElevatedButton(
      onPressed: () {
        // Restock functionality here
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
