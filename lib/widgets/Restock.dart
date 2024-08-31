import 'package:flutter/material.dart';

class MyWidget extends StatefulWidget {
  final Map<String, dynamic> item;

MyWidget({required this.item});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  void _showRestockDialog(Map<String, dynamic> item) {
    int currentQuantity = item['quantity'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Restock ${item['name']}'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    if (currentQuantity > 0) currentQuantity--;
                  });
                },
              ),
              Text(
                '$currentQuantity',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: Icon(Icons.add_circle, color: Colors.green),
                onPressed: () {
                  setState(() {
                    currentQuantity++;
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item['quantity'] = currentQuantity;
                });
                Navigator.of(context).pop();
              },
              child: Text('Update'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
