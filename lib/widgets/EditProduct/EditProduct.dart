import 'package:application/widgets/controllers/BrandSerializer.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/controllers/ProductWithStock.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditProductPage extends StatefulWidget {
  final ProductData product;
  final bool isCreate;

  const EditProductPage(
      {Key? key, required this.product, required this.isCreate})
      : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final formatter = NumberFormat("#,##0.00", "en_US");

  TextEditingController _productNameController = TextEditingController();
  TextEditingController _buyingPriceController = TextEditingController();
  TextEditingController _sellingPriceController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();

  TextEditingController _restockController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  List<BrandController> _brands = [];
  List<CategoryController> _category = [];
  String? _selectedBrand;
  int? _selectedBrandId;

  String? _selectedCategory;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (!widget.isCreate) {
      _productNameController = TextEditingController(text: widget.product.name);
      _buyingPriceController =
          TextEditingController(text: widget.product.buyingPrice.toString());
      _sellingPriceController =
          TextEditingController(text: widget.product.sellingPrice.toString());
      _quantityController =
          TextEditingController(text: widget.product.quantity.toString());
      _restockController =
          TextEditingController(text: widget.product.reorderLevel.toString());
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
    try {
      List<BrandController> brands = await AppRequest.FutureGetBrands(null);
      setState(() {
        _brands = brands;
        _selectedBrandId = brands
            .firstWhere((brand) => brand.id == widget.product.brand_id,
                orElse: () => brands.first)
            .id;
      });
    } catch (e) {
      _showError('Error fetching brands: $e');
    }
  }

  Future<void> _fetchCategory() async {
    try {
      List<CategoryController> category =
          await AppRequest.FutureGetCategories();
      setState(() {
        _category = category;
        _selectedCategoryId = category
            .firstWhere((element) => element.id == widget.product.category_id,
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
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<Appbloc>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.isCreate ? Colors.green : Colors.blue,
        title: Text(
          widget.isCreate
              ? 'Add Product'
              : 'Edit Product #${widget.product.id}',
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
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: ScaleTransition(
              scale: _animation,
              child: Column(
                children: [
                  _buildProductInfoCard(),
                  SizedBox(height: 16),
                  _buildPricingCard(),
                  SizedBox(height: 16),
                  _buildStockCard(),
                  SizedBox(height: 16),
                  _buildActionCard(bloc),
                ],
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
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
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
                    SizedBox(height: 4),
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
          SizedBox(height: 24),
          _buildTextField(
            _productNameController,
            'Product Name',
            Icons.shopping_bag_outlined,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBrandDropdown()),
              SizedBox(width: 16),
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
              Icon(
                Icons.payments_outlined,
                size: 24,
                color: Colors.blue,
              ),
              SizedBox(width: 12),
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
          SizedBox(height: 24),
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
              SizedBox(width: 16),
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
              Icon(
                Icons.inventory,
                size: 24,
                color: Colors.green,
              ),
              SizedBox(width: 12),
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
          SizedBox(height: 24),
          _buildTextField(
            _quantityController,
            'Quantity in Stock',
            Icons.inventory_2_outlined,
            isNumber: true,
          ),
          SizedBox(height: 24),
          _buildTextField(
            _restockController,
            'Restock Level',
            Icons.warning_amber_outlined,
            isNumber: true,
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
            icon: Icon(Icons.close, size: 16),
            label: Text('Cancel', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final Map<String, dynamic> data = {
                  "brand": _selectedBrandId,
                  "id": widget.product.id,
                  "category": _selectedCategoryId,
                  "product_name": _productNameController.text,
                  "buying_price": _buyingPriceController.text,
                  "selling_price": _sellingPriceController.text,
                  "quantity": _quantityController.text
                };
                AppRequest.patchProduct(
                  isRestock: false,
                  context: context,
                  id: widget.product.id,
                  data: data,
                );
              }
            },
            icon: bloc.isloading
                ? LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 16,
                  )
                : Icon(Icons.save, size: 16),

            label: Text(  widget.isCreate?"Create":
              
              'Save Changes', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return _buildDropdown(
      value: _selectedBrandId,
      items: _brands.map((brand) {
        return DropdownMenuItem(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBrandId = value as int?;
        });
      },
      label: 'Brand',
      icon: Icons.business_outlined,
    );
  }

  Widget _buildCategoryDropdown() {
    return _buildDropdown(
      value: _selectedCategoryId,
      items: _category.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value as int?;
        });
      },
      label: 'Category',
      icon: Icons.category_outlined,
    );
  }


    Widget buildDropdownWithButton({
   required addNewItem,
    required Widget dropdown,
     }) {
    return Row(
      children: [
        Expanded(child: dropdown),
        SizedBox(width: 10),
        ElevatedButton.icon(
       
          onPressed: addNewItem,
          icon: Icon(Icons.add),
          label: Text('New', style: GoogleFonts.poppins(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          ),
        ),
      ],
    );
  }






  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<int>> items,
    required void Function(Object?) onChanged,
    required int? value,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
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
          borderSide: BorderSide(color: Colors.blue, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
