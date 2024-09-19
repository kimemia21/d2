import 'package:application/widgets/AddItem/CatRequest.dart';
import 'package:flutter/material.dart';


class CategoryDropdown extends StatefulWidget {
  @override
  _CategoryDropdownState createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  String? _selectedCategory;
  List<Map<String, dynamic>> _category = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategory();
  }

  // Fetch category and set state
  Future<void> _fetchCategory() async {
    try {
      List<Map<String, dynamic>> fetchedCategory = await  CategoryRequest.fetchCategory(context);
      setState(() {
        _category = fetchedCategory;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching category: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }


  Widget _buildCommodityTypeDropdown() {
    if (_isLoading) {
      return CircularProgressIndicator(); // Show loading indicator while fetching
    }

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      value: _selectedCategory,
      items: _category
          .map((commodity) => DropdownMenuItem<String>(
                value: commodity['id'].toString(),
                child: Text(commodity['category_name']),
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildCommodityTypeDropdown();
  }
}
