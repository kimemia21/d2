import 'package:application/widgets/AddItem/CatRequest.dart';
import 'package:application/widgets/Models/CategorySerializers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDropdown extends StatefulWidget {
  final Function(String?) onchangeCategory;

  const CategoryDropdown({
    super.key,
    required this.onchangeCategory,
  });

  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? _selectedCategory;
  late Stream< List<CategoryController>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = _createCategoriesStream();
  }

  Stream< List<CategoryController>> _createCategoriesStream() async* {
    while (true) {
      try {
        
      List<CategoryController> fetchedCategories = await CategoryRequest.fetchCategory(context);
        yield fetchedCategories.reversed.toList();
      } catch (e) {
        print('Error fetching categories: $e');
        yield [];
      }
      await Future.delayed(const Duration(seconds:5)); // Poll every 5 seconds
    }
  }

  Widget _buildCategoryDropdown( List<CategoryController> categories) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Category',
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
          prefixIcon: Icon(Icons.category, color: Colors.green.shade600),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        value: _selectedCategory,
        items: categories
            .map((category) => DropdownMenuItem<String>(
                  value: category.id.toString(),
                  child: Text(
                    category.name,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ))
            .toList(),
        onChanged: (value) {
          setState(() {
            _selectedCategory = value;
          });
          widget.onchangeCategory(value);
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
    return StreamBuilder< List<CategoryController>>(
      stream: _categoriesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No categories available'));
        } else {
          return _buildCategoryDropdown(snapshot.data!);
        }
      },
    );
  }
}