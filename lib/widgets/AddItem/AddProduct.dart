import 'package:application/main.dart';
import 'package:application/widgets/AddItem/BrandDrop.dart';
import 'package:application/widgets/AddItem/CatDropDown.dart';
import 'package:application/widgets/controllers/BrandSerializer.dart';
import 'package:application/widgets/controllers/CategorySerializers.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AddProductForm extends StatefulWidget {
  const AddProductForm({Key? key}) : super(key: key);

  @override
  _AddProductFormState createState() => _AddProductFormState();
}

class _AddProductFormState extends State<AddProductForm>
    with SingleTickerProviderStateMixin {
  String? selectedCategory;
  String? selectedBrand;

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

  bool validateInputs() {
    if (selectedCategory == null) {
      error(title: "Please select a category");
      return false;
    }
    if (selectedBrand == null) {
      error(title: "Please select a brand");
      return false;
    }
    if (nameController.text.isEmpty) {
      error(title: "Please enter a product name");
      return false;
    }
    if (buyingPriceController.text.isEmpty) {
      error(title: "Please enter a buying price");
      return false;
    }
    if (sellingPriceController.text.isEmpty) {
      error(title: "Please enter a selling price");
      return false;
    }
    if (quantityController.text.isEmpty) {
      error(title: "Please enter a quantity");
      return false;
    }

    // Add additional validation for numeric fields
    if (double.tryParse(buyingPriceController.text) == null) {
      error(title: "Invalid buying price");
      return false;
    }
    if (double.tryParse(sellingPriceController.text) == null) {
      error(title: "Invalid selling price");
      return false;
    }
    if (int.tryParse(quantityController.text) == null) {
      error(title: "Invalid quantity");
      return false;
    }

    return true;
  }

  void saveProduct() {
    if (validateInputs()) {

      final Map<String, dynamic> body = {
        "category": int.parse(selectedCategory!),
        "brand": int.parse(selectedBrand!),
        "product_name": nameController.text,
        "buying_price": buyingPriceController.text,
        "selling_price": sellingPriceController.text,
        "quantity": quantityController.text
      };
      
      AppRequest.CreateProduct(body: body, context: context);

      CherryToast.success(
        title: Text("Product saved successfully"),
        toastDuration: Duration(seconds: 2),
        animationDuration: Duration(seconds: 2),
      ).show(context);
    }
  }

  void showAddCategoryDialog(
    BuildContext context,
    String title,
  ) {
    String newItem = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final Appbloc bloc = Provider.of<Appbloc>(context, listen: false);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 600,
                height: 400,
                // Set a fixed width for the dialog
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newItem = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter new $title",
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 14),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      style: GoogleFonts.poppins(
                          color: Colors.black87, fontSize: 14),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Existing ${title.toLowerCase()}:",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
    Container(
      width: 600,
      height: 300,
      child: StreamBuilder<List<CategoryController>>(
          stream: AppRequest.getCategoriesStream(),
          builder: (BuildContext context, AsyncSnapshot<List<CategoryController>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No categories available'));
            } else {
              final categories = snapshot.data!;
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final item = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    child: Text(
                      item.name,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
    ),
    
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: bloc.isloading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  onPressed: () async {
                    if (newItem.isNotEmpty) {
                      // onAdd(newItem);
                      await AppRequest.CreateCategory(
                        body: {"category_name": newItem.toUpperCase()},
                        context: context,
                      );
                      // Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a $title name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddBrandDialog(
    BuildContext context,
    String title,
  ) {
    String newItem = '';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            final Appbloc bloc = Provider.of<Appbloc>(context, listen: false);

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 600,
                height: 400,
                // Set a fixed width for the dialog
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newItem = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter new $title",
                        hintStyle: GoogleFonts.poppins(
                            color: Colors.grey, fontSize: 14),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.secondary,
                              width: 2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        prefixIcon: Icon(Icons.add_circle_outline,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                      style: GoogleFonts.poppins(
                          color: Colors.black87, fontSize: 14),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Existing ${title.toLowerCase()}:",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 5),
                    Container(
                        height: 200, // Reduced height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FutureBuilder<List<BrandController>>(
                            future: AppRequest.FutureGetBrands(null),
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                final categories = snapshot.data;
                                return ListView.builder(
                                  itemCount: categories!.length,
                                  itemBuilder: (context, index) {
                                    final item = categories[index];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      child: Text(
                                        item.name,
                                        style: GoogleFonts.poppins(
                                            color: Colors.black87,
                                            fontSize: 12),
                                      ),
                                    );
                                  },
                                );
                              }
                            })),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Cancel',
                    style:
                        GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                  ),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: bloc.isloading
                      ? LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.white,
                          size: 20,
                        )
                      : Text(
                          'Add',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  onPressed: () async {
                    if (newItem.isNotEmpty) {
                      // onAdd(newItem);
                      //                  {
                      //     "id": 1,
                      //     "brand_name": "Vega",
                      //     "category": 1
                      // },
                      final Map<String, dynamic> body = {
                        "brand_name": newItem.toUpperCase(),
                        "category": int.parse(selectedCategory!)
                      };
                      await AppRequest.CreateBrand(
                          body: body, context: context);

                      // Navigator.of(dialogContext).pop();
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(
                          content: Text('Please enter a $title name'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void addNewCategory() async {
    showAddCategoryDialog(context, "Category");
  }

  void addNewBrand() async {
    showAddBrandDialog(context, 'Brand');
  }

  void error({required String title}) {
    CherryToast.error(
      title: Text(title),
      toastDuration: Duration(seconds: 2),
      animationDuration: Duration(seconds: 2),
    ).show(context);
  }

  void editField(String field) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newValue = '';
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    required addNewItem,
    required Widget dropdown,
  }) {
    return Row(
      children: [
        Expanded(child: dropdown),
        SizedBox(width: 10),
        ElevatedButton.icon(
          // add an alert if selectedCategory is empty so that we can get the brand id when creating a new Brand
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
            buildDropdownWithButton(
              dropdown: CategoryDropdown(onchangeCategory: (value) {
                setState(() {
                  selectedCategory = value;
                });
              }),
              addNewItem: addNewCategory,
            ),
            SizedBox(height: 20),
            buildDropdownWithButton(dropdown: BrandDropdown(
              onbrandChange: (value) {
                setState(() {
                  selectedBrand = value;
                  print(value);
                });
              },
            ), addNewItem: () {
              try {} catch (e) {}
              selectedCategory != null
                  ? addNewBrand()
                  : error(title: "please select category");
            }),
            SizedBox(height: 20),
            buildTextField('Product Name', nameController, Icons.shopping_bag,
                type: TextInputType.text),
            SizedBox(height: 20),
            buildNumberTextField(
                'Buying Price', buyingPriceController, Icons.attach_money),
            SizedBox(height: 20),
            buildNumberTextField(
                'Selling Price', sellingPriceController, Icons.attach_money),
            SizedBox(height: 20),
            buildNumberTextField(
                'Quantity', quantityController, Icons.inventory)
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
      String label, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.text}) {
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

  Widget buildNumberTextField(
      String label, TextEditingController controller, IconData icon) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double opacity, child) {
        return Opacity(
          opacity: opacity,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Product Management', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryColor,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
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
                          onPressed: saveProduct, // Add your function here
                          icon: Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Save Product',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
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
                      Container(
                        width: 200,
                        padding: EdgeInsets.all(10),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                          label: Text('Cancel',
                              style: GoogleFonts.poppins(color: Colors.white)),
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
