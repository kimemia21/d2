import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({Key? key}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm> with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String? selectedBrand;

  List<String> categories = ['Food', 'Beverages', 'Snacks', 'Merchandise'];
  List<String> brands = ['Food', 'Beverages', 'Snacks', 'Merchandise'];

  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController brandController = TextEditingController();
  TextEditingController buyingPriceController = TextEditingController();
  TextEditingController quantityController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _animation;

  // POS-friendly color scheme
  final Color primaryColor = Color(0xFF2C3E50);
  final Color accentColor = Color(0xFF3498DB);
  final Color backgroundColor = Color(0xFFF5F5F5);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    sellingPriceController.dispose();
    nameController.dispose();
    buyingPriceController.dispose();
    quantityController.dispose();
    super.dispose();
  }

  void showAddDialog(String title, List<String> items, Function(String) onAdd) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(title, style: TextStyle(color: primaryColor)),
          content: TextField(
            onChanged: (value) {
              newItem = value;
            },
            decoration: InputDecoration(
              hintText: "Enter new $title",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add', style: TextStyle(color: primaryColor)),
              onPressed: () {
                setState(() {
                  onAdd(newItem);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addNewCategory() {
    showAddDialog('Category', categories, (newCategory) {
      categories.add(newCategory);
    });
  }

  void addNewBrand() {
    showAddDialog('Brand', brands, (newBrand) {
      brands.add(newBrand);
    });
  }

  void editField(String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newValue = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Edit $field', style: TextStyle(color: primaryColor)),
          content: TextField(
            onChanged: (value) {
              newValue = value;
            },
            decoration: InputDecoration(
              hintText: "Enter new $field",
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: accentColor),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save', style: TextStyle(color: primaryColor)),
              onPressed: () {
                setState(() {
                  if (field == 'Price') {
                    sellingPriceController.text = newValue;
                  } else if (field == 'Quantity') {
                    quantityController.text = newValue;
                  }
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildDropdownWithButton({
    required String text,
    required String? selectedValue,
    required List<String> items,
    required VoidCallback addNewItem,
  }) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            hint: Text(text),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
            ),
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: addNewItem,
          icon: Icon(Icons.add),
          label: Text('New'),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildProductCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Product',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
            ),
            SizedBox(height: 16),
            buildDropdownWithButton(
              text: 'Select Category',
              selectedValue: selectedCategory,
              items: categories,
              addNewItem: addNewCategory,
            ),
            SizedBox(height: 20),
            buildDropdownWithButton(
              text: 'Select Brand',
              selectedValue: selectedBrand,
              items: brands,
              addNewItem: addNewBrand,
            ),
            SizedBox(height: 20),
            buildTextField('Product Name', nameController, Icons.shopping_bag,
                type: TextInputType.text),
            SizedBox(height: 20),
            buildTextField('Buying Price', buyingPriceController, Icons.attach_money),
            SizedBox(height: 20),
            buildTextField('Selling Price', sellingPriceController, Icons.attach_money),
            SizedBox(height: 20),
            buildTextField('Quantity', quantityController, Icons.inventory),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.number}) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: TextField(
            controller: controller,
            keyboardType: type,
            inputFormatters: type == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: accentColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Management', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: 
        Container(
          width: MediaQuery.of(context).size.width*0.5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ScaleTransition(
                    scale: _animation,
                    child: buildProductCard(),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.save,color: Colors.white,),
                          label: Text('Save Product',style: GoogleFonts.poppins(color: Colors.white),),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                           width: 200,
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: Icon(Icons.delete,color: Colors.white,),
                          label: Text('Cancel',style: GoogleFonts.poppins(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
    );
  }
}
