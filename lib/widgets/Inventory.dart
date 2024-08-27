import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InventoryManagementPage extends StatefulWidget {
  const InventoryManagementPage({Key? key}) : super(key: key);

  @override
  _InventoryManagementPageState createState() => _InventoryManagementPageState();
}

class _InventoryManagementPageState extends State<InventoryManagementPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _inventoryItems = [
    {'name': 'Tires', 'icon': Icons.tire_repair, 'quantity': 50},
    {'name': 'Helmets', 'icon': Icons.sports_motorsports, 'quantity': 30},
    {'name': 'Engine Oil', 'icon': Icons.oil_barrel, 'quantity': 100},
    {'name': 'Brake Pads', 'icon': Icons.build, 'quantity': 80},
    {'name': 'Chain', 'icon': Icons.link, 'quantity': 40},
    {'name': 'Spark Plugs', 'icon': Icons.electric_bolt, 'quantity': 120},
    {'name': 'Air Filters', 'icon': Icons.air, 'quantity': 60},
    {'name': 'Batteries', 'icon': Icons.battery_full, 'quantity': 25},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

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
      appBar: AppBar(
        title: Text('Inventory Management',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView.builder(
            itemCount: _inventoryItems.length,
            itemBuilder: (context, index) {
              final item = _inventoryItems[index];
              return Card(
                elevation: 4,
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(item['icon'], size: 40, color: Colors.red.shade800),
                  title: Text(item['name'],
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Quantity: ${item['quantity']}',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          // Decrease quantity
                          setState(() {
                            if (item['quantity'] > 0) item['quantity']--;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.green),
                        onPressed: () {
                          // Increase quantity
                          setState(() {
                            item['quantity']++;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new item functionality
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red.shade800,
      ),
    );
  }
}