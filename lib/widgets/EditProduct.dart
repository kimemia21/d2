import 'package:application/main.dart';
import 'package:application/widgets/controllers/BrandSerializer.dart';
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

  final int buyingPrice;
  final int sellingPrice;
  final int quantity;

  const EditProductPage({
    Key? key,
    required this.productName,
    required this.productId,
    required this.brand,
    required this.buyingPrice,
    required this.sellingPrice,
    required this.quantity,
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
  String? _selectedBrand;
  int? _selectedBrandId;
  final Color primaryColor = Color(0xFF3498db); // A nice blue
  final Color accentColor = Color(0xFFe74c3c); // A complementary red
  final Color backgroundColor = Color(0xFFecf0f1); // Light gray background
  final Color textColor = Color(0xFF2c3e50);

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
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animationController.forward();
  }

  Future<void> _fetchBrands() async {
    try {
      List<BrandController> brands = await AppRequest.getBrands(null);

      setState(() {
        _brands = brands;
        // Set the selected brand id based on the brand that matches the one in the widget.brand
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
        "id": widget.productId,
        "category": _selectedBrandId,
        "product_name": _productNameController.text,
        "buying_price": _buyingPriceController.text,
        "selling_price": _sellingPriceController.text,
        "quantity": _quantityController.text
      };
      AppRequest.patchProduct(
          context: context, id: widget.productId, data: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<Appbloc>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Product',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor, backgroundColor],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_animation),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Product Details',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(),
                        const SizedBox(height: 20),
                        _buildTextField(_productNameController, 'Product Name',
                            Icons.motorcycle),
                        const SizedBox(height: 16),
                        _buildBrandDropdown(),
                        const SizedBox(height: 16),
                        _buildTextField(_buyingPriceController, 'Buying Price',
                            Icons.attach_money,
                            isPrice: true),
                        const SizedBox(height: 16),
                        _buildTextField(_sellingPriceController,
                            'Selling Price', Icons.monetization_on,
                            isPrice: true),
                        const SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: _saveProductDetails,
                            child: bloc.isloading
                                ? LoadingAnimationWidget.staggeredDotsWave(
                                    color: Colors.white,
                                    size: 30,
                                  )
                                : Text(
                                    'Save Changes',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                          ).animate().scale(duration: 300.ms),
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
          child: Text(brand.brandName),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Brand',
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixIcon: Icon(Icons.branding_watermark, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPrice = false,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: primaryColor),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      keyboardType: isPrice ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: 16,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (isPrice && double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    ).animate().fadeIn(delay: 200.ms).slideX();
  }
}
