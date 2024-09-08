import 'package:application/widgets/DynamicForm.dart';
import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/controllers/Serializers.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage>
    with SingleTickerProviderStateMixin {
  int selectedCategoryIndex = 0;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  final List<String> categories = ['Helmets', 'Jackets', 'Gloves', 'Boots'];
  final Map<String, List<Map<String, dynamic>>> items = {
    'Helmets': [
      {'name': 'Helmet A', 'quantity': 10},
      {'name': 'Helmet B', 'quantity': 5},
    ],
    'Jackets': [
      {'name': 'Jacket A', 'quantity': 7},
      {'name': 'Jacket B', 'quantity': 2},
    ],
    'Gloves': [
      {'name': 'Glove A', 'quantity': 20},
      {'name': 'Glove B', 'quantity': 15},
    ],
    'Boots': [
      {'name': 'Boot A', 'quantity': 8},
      {'name': 'Boot B', 'quantity': 3},
    ],
  };

  @override
  void initState() {
    super.initState();
    makerequest();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void makerequest() async {
    print("working on the data");
    AppRequest.getCategorites();
  }

  Future<List<CategoryController>> brands = AppRequest.getCategorites();

  void _showRestockDialog(BuildContext context, Map<String, dynamic> item) {
    int currentQuantity = item['quantity'];
    TextEditingController _quantityController =
        TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            width: MediaQuery.of(context).size.width * 0.4,
            height: MediaQuery.of(context).size.height *
                0.7, // Set the width to half the screen
            child: StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Row(
                    children: [
                      Icon(Icons.motorcycle, color: Colors.blue[800]),
                      SizedBox(width: 10),
                      Text('Restock ${item['name']}',
                          style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Container(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red[700], size: 30),
                                onPressed: () {
                                  setState(() {
                                    if (currentQuantity > 0) currentQuantity--;
                                    _quantityController.text =
                                        currentQuantity.toString();
                                  });
                                },
                              ),
                              Text(
                                '$currentQuantity',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[800]),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle,
                                    color: Colors.green[700], size: 30),
                                onPressed: () {
                                  setState(() {
                                    currentQuantity++;
                                    _quantityController.text =
                                        currentQuantity.toString();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Enter Quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.blue[800]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Colors.blue[800]!, width: 2),
                            ),
                            prefixIcon:
                                Icon(Icons.inventory, color: Colors.blue[800]),
                          ),
                          onChanged: (value) {
                            setState(() {
                              currentQuantity =
                                  int.tryParse(value) ?? currentQuantity;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton.icon(
                      icon: Icon(Icons.update),
                      label: Text(
                        'Update Stock',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        // Update the item quantity in the original list
                        setState(() {
                          item['quantity'] = currentQuantity;
                        });
                        // Close the dialog and pass the updated quantity back to the parent
                        Navigator.of(context).pop(currentQuantity);
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.red[600], // Set the background color to red
                        borderRadius: BorderRadius.circular(
                            10), // Optional: Add some border radius
                      ),
                      child: TextButton.icon(
                        icon: Icon(Icons.cancel,
                            color: Colors.white), // Icon color white
                        label: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(
                            color: Colors.white, // Text color white
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20), // Adjust padding as needed
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Match border radius with the container
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    ).then((updatedQuantity) {
      if (updatedQuantity != null) {
        // Update the item quantity in the parent widget
        setState(() {
          item['quantity'] = updatedQuantity;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: IconButton.filled(
            onPressed: () => Globals.switchScreens(
                context: context, screen: AddProductForm()),
            icon: Icon(Icons.add)),
        appBar: AppBar(
          title: Text('Inventory'),
          backgroundColor: Colors.blueGrey,
        ),
        body:
            //    FutureBuilder<List<CategoryController>>(
            //   future: AppRequest.getCategorites(), // Calls the method
            //   builder: (context, snapshot) {
            //     // Check for error
            //     if (snapshot.hasError) {
            //       return Center(child: Text('Error: ${snapshot.error}'));
            //     }

            //     // Check for data
            //     if (snapshot.connectionState == ConnectionState.done) {
            //       final categories = snapshot.data;

            //       // Check if data is not empty
            //       if (categories == null || categories.isEmpty) {
            //         return Center(child: Text('No categories found.'));
            //       }

            //       // Build the list view of categories
            //       return ListView.builder(
            //         itemCount: categories.length,
            //         itemBuilder: (context, index) {
            //           final category = categories[index];
            //           return ListTile(
            //             title: Text(category.categoryName),
            //             subtitle: Text('ID: ${category.id}'),
            //           );
            //         },
            //       );
            //     }

            //     // Display loading indicator while fetching data
            //     return Center(child: CircularProgressIndicator());
            //   },
            // ),

            FutureBuilder<List<CategoryController>>(
          future: AppRequest.getCategorites(),
          //  initialData: InitialData,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData) {
              final data = snapshot.data;
              print("THIS IS inventory data $data");

              return Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.75,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            final mapped = data[index];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCategoryIndex = index;
                                });
                                _controller.reset();
                                _controller.forward();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selectedCategoryIndex == index
                                      ? Colors.blueGrey
                                      : Colors.grey,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  mapped.categoryName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: SlideTransition(
                          position: _offsetAnimation,
                          child: FutureBuilder<List<ProductController>>(
                              future: AppRequest.getProducts(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("${snapshot.error}"),
                                  );
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                } else if (snapshot.hasData) {
                                  final map = snapshot.data;
                                  print(map);
                                  return ListView.builder(
                                    itemCount:map.length, 
                                    itemBuilder: (context, index) {
                                      var item = items[categories[
                                          selectedCategoryIndex]]![index];
                                      return Card(
                                        elevation: 4,
                                        margin:
                                            EdgeInsets.symmetric(vertical: 8),
                                        child: ListTile(
                                          title: Text(
                                            item['name'],
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(
                                              'Quantity: ${item['quantity']}'),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  // Add edit logic here
                                                  Globals.switchScreens(
                                                      context: context,
                                                      screen: AddProductForm());
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.orange,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('Edit'),
                                              ),
                                              SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  _showRestockDialog(
                                                      context, item);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Text('Restock'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                                return Text("unknow error");
                              }),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ));
  }
}
