import 'package:application/widgets/Firebase/FirebaseModels/FirebaseStore.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/Models/BrandSerializer.dart';
import 'package:application/widgets/Models/CategorySerializers.dart';
import 'package:application/widgets/Models/ProductWithStock.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/foundation.dart' as debug;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

class ProductPage extends StatefulWidget {
  final ProductData? product;
  final bool isCreate;

  const ProductPage({super.key, this.product, required this.isCreate});

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final formatter = NumberFormat("#,##0.00", "en_US");

  TextEditingController _productNameController = TextEditingController();
  TextEditingController _buyingPriceController = TextEditingController();
  TextEditingController _sellingPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  TextEditingController _restockController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  List<Brand> _brands = [];
  // django  List<CategoryController> _category = [];
  List<Category> _category = [];
  String? _selectedBrand;
  String? _selectedBrandId;

  String? _selectedCategory;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (!widget.isCreate) {
      _productNameController =
          TextEditingController(text: widget.product!.name);
      _buyingPriceController =
          TextEditingController(text: widget.product!.buyingPrice.toString());
      _sellingPriceController =
          TextEditingController(text: widget.product!.sellingPrice.toString());
      _quantityController =
          TextEditingController(text: widget.product!.quantity.toString());
      _restockController =
          TextEditingController(text: widget.product!.reorderLevel.toString());
    }

    _fetchBrands();
    _fetchCategory();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  // Existing fetch methods remain the same
  Future<void> _fetchBrands() async {
    print("invoked brands");
    try {
      // List<Brand> brands = await AppRequest.FutureGetBrands(null);
      // setState(() {
      //   _brands = brands;
      //   _selectedBrandId = widget.isCreate
      //       ? null
      //       : brands
      //           .firstWhere((brand) => brand.id == widget.product!.brand_id,
      //               orElse: () => brands.first)
      //           .id;
      // });

      List<Brand> brands = await FirestoreService().getAllBrands();
      setState(() {
        _brands = brands;
        _selectedBrandId = widget.isCreate
            ? null
            : brands
                .firstWhere((brand) => brand.id == widget.product!.brand_id,
                    orElse: () => brands.first)
                .id;
      });
      print("brand id is $_selectedBrandId");
    } catch (e) {
      _showError('Error fetching brands: $e');
    }
  }

  Future<void> _fetchCategory() async {
    print("invoked fetch category");
    try {
      //  django implementation
      // List<CategoryController> category =
      //     await AppRequest.FutureGetCategories();
      // setState(() {
      //   _category = category;
      //   _selectedCategoryId = widget.isCreate
      //       ? null
      //       : category
      //           .firstWhere(
      //               (element) => element.id == widget.product!.category_id,
      //               orElse: () => category.first)
      //           .id;
      // });
      // firebase implementation
      List<Category> category =
          await FirestoreService().getCategories(isFiltered: false);
      setState(() {
        _category = category;
        _selectedCategoryId = widget.isCreate
            ? null
            : category
                .firstWhere(
                    (element) => element.id == widget.product!.category_id,
                    orElse: () => category.first)
                .id;
      });
    } catch (e) {
      _showError('Error fetching categories: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void addNewCategory({required VoidCallback onInvoked}) async {
    Globals.showAddBrandOrCategoryDialog(
      context: context,
      title: "Category",
      future: FirestoreService().getCategories(isFiltered: false),
      isBrand: false,
      selectedCategory: _selectedCategoryId,
    );
  }

  Future<void> addNewBrand({required VoidCallback onInvoked}) async {
    Globals.showAddBrandOrCategoryDialog(
      context: context,
      title: "Brand",
      future: FirestoreService().getAllBrands(),
      isBrand: true,
      selectedCategory: _selectedCategoryId,
    );
    print("Calling onInvoked callback");
    onInvoked;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<Appbloc>();

    if (debug.kDebugMode) {
      _quantityController.text = "15";
      _productNameController.text = "restock color";
      _restockController.text = "10";
      _buyingPriceController.text = "100";
      _sellingPriceController.text = "140";
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.isCreate ? Colors.green : Colors.blue,
        title: Text(
          widget.isCreate
              ? 'Add Product'
              : 'Edit Product #${widget.product!.id}',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ScaleTransition(
                scale: _animation,
                child: Column(
                  children: [
                    _buildProductInfoCard(),
                    const SizedBox(height: 16),
                    _buildPricingCard(),
                    const SizedBox(height: 16),
                    _buildStockCard(),
                    const SizedBox(height: 16),
                    _buildActionCard(bloc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
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
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Basic details about the product',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildTextField(
            _productNameController,
            'Product Name',
            Icons.shopping_bag_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBrandDropdown()),
              const SizedBox(width: 16),
              Expanded(child: _buildCategoryDropdown()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.payments_outlined,
                size: 24,
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              Text(
                'Pricing Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  _buyingPriceController,
                  'Buying Price',
                  Icons.shopping_bag_outlined,
                  prefix: '\$',
                  isNumber: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  _sellingPriceController,
                  'Selling Price',
                  Icons.sell_outlined,
                  prefix: '\$',
                  isNumber: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory,
                size: 24,
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                'Stock Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          Visibility(
            visible: widget.isCreate,
            child: Column(
              children: [
                const SizedBox(height: 24),
                _buildTextField(
                  _quantityController,
                  'Quantity in Stock',
                  Icons.inventory_2_outlined,
                  isNumber: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            _restockController,
            'Restock Level',
            Icons.warning_amber_outlined,
            isNumber: true,
            isRestock: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(Appbloc bloc) {
    return _buildCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Cancel', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () async {
              if (widget.isCreate && _formKey.currentState!.validate()) {
                try {
                  var uuid = Uuid();
                  String id = uuid.v4();

                  final Product product = Product(
                    id: id,
                    name: _productNameController.text,
                    categoryId: _selectedCategoryId!,
                    categoryName: _selectedCategory,
                    brandId: _selectedBrandId!,
                    brandName: _selectedBrand!,
                    buyingPrice:
                        double.parse(_buyingPriceController.text.trim()),
                    sellingPrice:
                        double.parse(_sellingPriceController.text.trim()),
                    isActive: true,
                    lastUpdated: DateTime.now(),
                  );

                  StockMovement stockMovement = StockMovement(
                      type: "Create",
                      quantityChange:
                          int.parse(_quantityController.text.trim()),
                      createdAt: DateTime.now());

                  Stock stock = Stock(
                      productId: id,
                      quantity: int.parse(_quantityController.text.trim()),
                      reorderLevel: int.parse(_restockController.text.trim()),
                      lastRestocked: DateTime.now(),
                      product: product,
                      movements: [stockMovement]);

                  await FirestoreService().createCollection(
                      context: context,
                      isBrand: false,
                      isProduct: true,
                      stock: stock,
                      product: product);
                } catch (e) {
                  Globals().snackbar(
                      context: context, isError: true, message: e.toString());
                  context.read<Appbloc>().changeLoading(false);
                  throw Exception("error on create product $e");
                }

                // -----------------commented code is the django setup --------------------------------------

                // final Map<String, dynamic> productbody = {
                //   "brand_id": _selectedBrandId,
                //   "category_id": _selectedCategoryId,
                //   "name": _productNameController.text,
                //   "buying_price": _buyingPriceController.text,
                //   "selling_price": _sellingPriceController.text,
                //   "barcode": "",
                //   "is_active": true,
                // };

                // final Map<String, dynamic> stockBody = {
                //   "quantity": _quantityController.text,
                //   "reorder_level": _restockController.text,
                // };

                //   AppRequest.CreateProduct(
                //       stockBody: stockBody,
                //       Productbody: productbody,
                //       context: context);
                // }

                // final Map<String, dynamic> PatchProductdata = {
                //   "brand_id": _selectedBrandId,
                //   "id": widget.product!.id,
                //   "category_id": _selectedCategoryId,
                //   "name": _productNameController.text,
                //   "buying_price": _buyingPriceController.text,
                //   "selling_price": _sellingPriceController.text,
                //   // "quantity": _quantityController.text
                // };
                // final Map<String, dynamic> Patchstockdata = {
                //   "id": widget.product!.stockId,
                //   "reorder_level": _restockController.text,
                // };

                // for (var entry in PatchProductdata.entries) {
                //   if (entry.value == null ||
                //       entry.value == '' ||
                //       entry.value == 0) {
                //     print(
                //         'Field ${entry.key} contains a null/empty value: ${entry.value}');
                //   }
                // }

                // for (var entry in Patchstockdata.entries) {
                //   if (entry.value == null ||
                //       entry.value == '' ||
                //       entry.value == 0) {
                //     print(
                //         'Field ${entry.key} contains a null/empty value: ${entry.value}');
                //   }
                // }

                // AppRequest.patchProduct(
                //     productData: PatchProductdata,
                //     stockData: Patchstockdata,
                //     isRestock: false,
                //     context: context,
                //     Productid: widget.product!.id,
                //     stockId: widget.product!.stockId,
                //     isOnSwitch: false);
              }
            },
            icon: bloc.isloading
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 16,
                  )
                : const Icon(Icons.save, size: 16),
            label: Text(widget.isCreate ? "Create" : 'Save Changes',
                style: const TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumber = false,
    String? prefix,
    bool isRestock = false, // Default to false to avoid null issues
  }) {
    return TextFormField(
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$label can't be empty";
        }

        if (isRestock) {
          // Ensure quantityController is not null and parse it safely
          int? stockQuantity = int.tryParse(_quantityController.text);
          int? inputQuantity = int.tryParse(value);

          if (stockQuantity != null && inputQuantity != null) {
            if (inputQuantity > stockQuantity) {
              return "$label can't be greater than stock quantity";
            }
          }
        }
        return null;
      },
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: [
        isNumber
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.singleLineFormatter
      ],
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
        prefixText: prefix,
        prefixStyle: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              // Remove the async from here since we're not awaiting anything directly
              addNewBrand(
                onInvoked: () async {
                  try {
                    // Await the _fetchBrands call
                    await _fetchBrands();
                  } catch (e) {
                    print("Error fetching brands: $e");
                    // Handle the error appropriately, maybe show a snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to fetch brands: $e')),
                    );
                  }
                },
              );
            },
            icon: const Icon(
              Icons.add_outlined,
              color: Colors.green,
            ),
          ),
          Expanded(
            child: _buildDropdown(
              value: _selectedBrandId,
              items: _brands.map((brand) {
                return DropdownMenuItem(
                  value: brand.id,
                  child: Text(brand.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  final sB = _brands.firstWhere(
                    (brand) => brand.id == value,
                    orElse: () => _brands.first,
                  );
                  setState(() {
                    _selectedBrandId = value as String?;
                    _selectedBrand = sB.name;
                    print("################## sB $_selectedBrand");
                  });
                }
              },
              label: 'Brand',
              icon: Icons.business_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedCategoryId,
            items: _category.map((category) {
              return DropdownMenuItem(
                value: category.id,
                child: Text(category.name),
              );
            }).toList(),
            onChanged: (value) {
              final sC = _category.firstWhere(
                (category) => category.id == value,
                orElse: () => _category.first,
              );

              setState(() {
                _selectedCategoryId = value as String;
                _selectedCategory = sC.name;
                print("################## sC $_selectedCategory");
              });
            },
            label: 'Category',
            icon: Icons.category_outlined,
          ),
        ),
        IconButton(
            onPressed: () {
              addNewCategory(onInvoked: () async {
                try {
                  print("invoked by mems");
                  await _fetchCategory();
                } catch (e) {
                  throw Exception("invoked by mems $e");
                }
              });
            },
            icon: const Icon(
              Icons.add_outlined,
              color: Colors.green,
            )),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<String>> items,
    required void Function(Object?) onChanged,
    required String? value,
  }) {
    return DropdownButtonFormField<String>(
      value: widget.isCreate ? null : value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
      ),
      dropdownColor: Colors.white,
      icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
      isExpanded: true,
      hint: Text(
        'Select $label',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _buyingPriceController.dispose();
    _sellingPriceController.dispose();
    _quantityController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
