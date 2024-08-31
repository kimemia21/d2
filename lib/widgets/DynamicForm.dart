import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:application/widgets/AddButton.dart';

class POSDynamicWidgetForm extends StatefulWidget {
  const POSDynamicWidgetForm({Key? key}) : super(key: key);

  @override
  _POSDynamicWidgetFormState createState() => _POSDynamicWidgetFormState();
}

class _POSDynamicWidgetFormState extends State<POSDynamicWidgetForm>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  List<String> categories = ['Food', 'Beverages', 'Snacks', 'Merchandise'];
  TextEditingController sellingPriceController = TextEditingController();
  TextEditingController nameController = TextEditingController();
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

  void addNewCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newCategory = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add New Category', style: TextStyle(color: primaryColor)),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(
              hintText: "Enter new category",
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: accentColor)),
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
                  categories.add(newCategory);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                  borderSide: BorderSide(color: accentColor)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS System', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
        
          width: MediaQuery.of(context).size.width*0.5,
           alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
               // mainAxisAlignment: MainAxisAlignment.center,
                 crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0, -0.1),
                        end: Offset.zero,
                      ).animate(_animation),
                      child: buildProductCard(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: FadeTransition(
                      opacity: _animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_animation),
                        child: AddButton(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryColor),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: Text('Select Category'),
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
                        selectedCategory = newValue;
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: addNewCategory,
                  icon: Icon(Icons.add),
                  label: Text('New'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            buildTextField('Product Name', nameController, Icons.shopping_bag, type: TextInputType.text),
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
      duration: Duration(milliseconds: 300),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: child,
          ),
        );
      },
      child: Focus(
        onFocusChange: (hasFocus) {
          setState(() {});
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(
                color: controller.text.isNotEmpty ? accentColor : Colors.grey,
              ),
              prefixIcon: Icon(icon, color: primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: accentColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: controller.text.isNotEmpty
                  ? Colors.grey.shade50
                  : Colors.transparent,
            ),
            keyboardType: type,
            inputFormatters: type == TextInputType.number
                ? [FilteringTextInputFormatter.digitsOnly]
                : [],
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}