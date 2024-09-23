import 'package:application/main.dart';
import 'package:application/widgets/EditProduct/EditProduct.dart';
import 'package:application/widgets/controllers/ProductSerializer.dart';
import 'package:application/widgets/homepage.dart';
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
  late Stream<List<ProductController>> productsStream;

  @override
  void initState() {
    super.initState();
    categoriesStream = AppRequest.getCategoriesStream();
    productsStream = AppRequest.getProductsStream(null);
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
      body: StreamBuilder<List<CategoryController>>(
        stream: categoriesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<CategoryController>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return _buildCategoryView(context, snapshot.data!);
          } else {
            return Center(child: Text('No categories available.'));
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
          GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = 100;
                productsStream = AppRequest.getProductsStream(null);
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
                      productsStream =
                          AppRequest.getProductsStream(category.id);
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
      child: StreamBuilder<List<ProductController>>(
        stream: productsStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<ProductController>> snapshot) {
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
                category: product.category,
                productName: product.product_name,
                productId: product.product_id,
                brand: product.brand,
                buyingPrice: product.buying_price,
                sellingPrice: product.selling_price,
                quantity: product.quantity),
            const SizedBox(width: 8),
            _buildRestockButton(
                name: product.product_name,
                quantity: product.quantity,
                id: product.product_id),
          ],
        ),
      ),
    );
  }

  // RESTOCK
  void _showRestockAlert(
      {required String name, required int quantity, required int id}) {
    TextEditingController restockController = TextEditingController();
   final Appbloc bloc = Provider.of<Appbloc>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: EdgeInsets.all(20),
          title: Text(
            'Restock $name',
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
                  'Item ID: XXXXX', // Placeholder for item number
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Current quantity: $quantity',
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
                  'Last Restocked: DD/MM/YYYY', // Placeholder for last restock date
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
                int currentQuantity = quantity;
                int newQuantity = int.parse(restockController.text);
                final _quantity = quantity + newQuantity;

                final body = {"quantity": _quantity};
                AppRequest.patchProduct(
                    isRestock: true, context: context, id: id, data: body);

                // Future.delayed(Duration(seconds: 4))
                //     .then((_) => Navigator.pop(context));

                // if (newQuantity > currentQuantity) {
                //   setState(() {
                //     // quantity = newQuantity.toString();
                //   });
                //   Navigator.of(context).pop();
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(
                //       content: Text(
                //           'New quantity must be greater than current quantity'),
                //       backgroundColor: Colors.red,
                //     ),
                //   );
                // }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton({
    required String productName,
    required int productId,
    required int brand,
    required int buyingPrice,
    required int sellingPrice,
    required int quantity,
    required int category,
  }) {
    return ElevatedButton(
      onPressed: () {
        Globals.switchScreens(
          context: context,
          screen: EditProductPage(
            categoryId: category,
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

  Widget _buildRestockButton(
      {required String name, required int quantity, required int id}) {
    return ElevatedButton(
      onPressed: () {
        // Restock functionality here
        _showRestockAlert(name: name, quantity: quantity, id: id);
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
