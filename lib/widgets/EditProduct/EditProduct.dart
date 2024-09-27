import 'package:application/main.dart';
import 'package:application/widgets/controllers/BrandSerializer.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class EditProductPage extends StatefulWidget {
  final String productName;
  final int productId;
  final int brand;
  final double  buyingPrice;
  final double  sellingPrice;
  final int quantity;
  final int categoryId;

  const EditProductPage({
    Key? key,
    required this.productName,
    required this.productId,
    required this.brand,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.categoryId,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _productNameController;
  late TextEditingController _buyingPriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _quantityController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  List<BrandController> _brands = [];
  List<CategoryController> _category = [];
  String? _selectedBrand;
  int? _selectedBrandId;

  String? _selectedCategory;
  int? _selectedCategoryId;

  // POS-friendly color scheme from AddProductForm
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();

    _productNameController = TextEditingController(text: widget.productName);
    _buyingPriceController =
        TextEditingController(text: widget.buyingPrice.toString());
    _sellingPriceController =
        TextEditingController(text: widget.sellingPrice.toString());
    _quantityController =
        TextEditingController(text: widget.quantity.toString());

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

  Future<void> _fetchBrands() async {
    try {
      List<BrandController> brands = await AppRequest.FutureGetBrands(null);

      setState(() {
        _brands = brands;
        _selectedBrandId = brands
            .firstWhere((brand) => brand.id == widget.brand,
                orElse: () => brands.first)
            .id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching brands: $e')),
      );
    }
  }

  Future<void> _fetchCategory() async {
    try {
      List<CategoryController> category =
          await AppRequest.FutureGetCategories();

      setState(() {
        _category = category;
        _selectedCategoryId = category
            .firstWhere((element) => element.id == widget.categoryId,
                orElse: () => category.first)
            .id;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching category: $e')),
      );
    }
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

  Future<void> _saveProductDetails() async {
    if (_formKey.currentState!.validate()) {
      final Map<String, dynamic> data = {
        "brand": _selectedBrandId,
        "id": widget.productId,
        "category": _selectedCategoryId,
        "product_name": _productNameController.text,
        "buying_price": _buyingPriceController.text,
        "selling_price": _sellingPriceController.text,
        "quantity": _quantityController.text
      };
      AppRequest.patchProduct(
        isRestock: false,
          context: context, id: widget.productId, data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<Appbloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ScaleTransition(
                scale: _animation,
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  color: cardColor,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Edit Product',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          SizedBox(height: 16),
                          _buildTextField(_productNameController,
                              'Product Name', Icons.shopping_bag),
                          SizedBox(height: 20),
                          _buildBrandDropdown(),
                          SizedBox(height: 20),
                          _buildCategoryDropdown(),
                          SizedBox(height: 20),
                          _buildTextField(_buyingPriceController,
                              'Buying Price', Icons.attach_money,
                              isPrice: true),
                          SizedBox(height: 20),
                          _buildTextField(_sellingPriceController,
                              'Selling Price', Icons.attach_money,
                              isPrice: true),
                          SizedBox(height: 20),
                          _buildTextField(
                              _quantityController, 'Quantity', Icons.inventory,
                              isPrice: true),
                          SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _saveProductDetails,
                                  icon: Icon(Icons.save, color: Colors.white),
                                  label: bloc.isloading
                                      ? LoadingAnimationWidget
                                          .staggeredDotsWave(
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : Text('Save Changes',
                                          style: GoogleFonts.poppins(
                                              color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.cancel, color: Colors.white),
                                  label: Text('Cancel',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedBrandId,
      onChanged: (newValue) {
        setState(() {
          _selectedBrandId = newValue;
        });
      },
      items: _brands.map<DropdownMenuItem<int>>((BrandController brand) {
        return DropdownMenuItem<int>(
          value: brand.id,
          child: Text(brand.name),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Brand',
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(Icons.branding_watermark,
            color: Theme.of(context).colorScheme.secondary, size: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      onChanged: (newValue) {
        setState(() {
          _selectedCategoryId = newValue;
        });
      },
      items:
          _category.map<DropdownMenuItem<int>>((CategoryController category) {
        return DropdownMenuItem<int>(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Category',
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.secondary, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(15),
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(Icons.branding_watermark,
            color: Theme.of(context).colorScheme.secondary, size: 20),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {bool isPrice = false}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: TextField(
            controller: controller,
            keyboardType: isPrice ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              labelText: label,
              hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
              prefixIcon: Icon(icon,
                  color: Theme.of(context).colorScheme.secondary, size: 20),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            ),
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
          ),
        );
      },
    );
  }
}
