import 'package:application/widgets/DynamicForm.dart';
import 'package:application/widgets/Globals.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: InventoryPage(),
    );
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: IconButton.filled(
          onPressed: () => Globals.switchScreens(
              context: context, screen: POSDynamicWidgetForm()),
          icon: Icon(Icons.add)),
      appBar: AppBar(
        title: Text('Inventory'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
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
                          categories[index],
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
                  child: ListView.builder(
                    itemCount: items[categories[selectedCategoryIndex]]!.length,
                    itemBuilder: (context, index) {
                      var item =
                          items[categories[selectedCategoryIndex]]![index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            item['name'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Quantity: ${item['quantity']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Add edit logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Edit'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  // Add restock logic here
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text('Restock'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
