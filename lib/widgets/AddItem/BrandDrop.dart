import 'package:application/widgets/AddItem/BrandReq.dart';
import 'package:application/widgets/AddItem/CatRequest.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandDropdown extends StatefulWidget {
  @override
  _BrandDropdownState createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  String? _selectedBrand;
  List<Map<String, dynamic>> _brands = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBrands();
  }

  Future<void> _fetchBrands() async {
    try {
      List<Map<String, dynamic>> fetchedbrand = await BrandRequest.fetchBrand(context);
      setState(() {
        _brands = fetchedbrand;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching brand: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildBrandDropdown() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'brand',
          labelStyle: GoogleFonts.poppins(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(Icons.branding_watermark, color: Colors.green.shade600),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: _selectedBrand,
        items: _brands
            .map((brand) => DropdownMenuItem<String>(
                  value: brand['id'].toString(),
                  child: Text(
                    brand['brand_name'],
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedBrand = value;
          });
        },
        icon: Icon(Icons.arrow_drop_down, color: Colors.green.shade600),
        iconSize: 24,
        isExpanded: true,
        dropdownColor: Colors.white,
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildBrandDropdown();
  }
}