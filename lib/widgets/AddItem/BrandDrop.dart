import 'package:application/widgets/AddItem/BrandReq.dart';
import 'package:application/widgets/AddItem/CatRequest.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BrandDropdown extends StatefulWidget {
  final Function(String) onbrandChange;

  const BrandDropdown({Key? key, required this.onbrandChange}) : super(key: key);

  @override
  _BrandDropdownState createState() => _BrandDropdownState();
}

class _BrandDropdownState extends State<BrandDropdown> {
  String? _selectedBrand;
  late Stream<List<Map<String, dynamic>>> _brandsStream;

  @override
  void initState() {
    super.initState();
    _brandsStream = _createBrandsStream();
  }

  Stream<List<Map<String, dynamic>>> _createBrandsStream() async* {
    while (true) {
      try {
        List<Map<String, dynamic>> fetchedBrands = await BrandRequest.fetchBrand(context);
        yield fetchedBrands.reversed.toList();
      } catch (e) {
        print('Error fetching brands: $e');
        yield [];
      }
      await Future.delayed(Duration(seconds: 1)); // Poll every 5 seconds
    }
  }

  Widget _buildBrandDropdown(List<Map<String, dynamic>> brands) {
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
          labelText: 'Brand',
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
        items: brands
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
          widget.onbrandChange(value!);
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
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _brandsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No brands available'));
        } else {
          return _buildBrandDropdown(snapshot.data!);
        }
      },
    );
  }
}