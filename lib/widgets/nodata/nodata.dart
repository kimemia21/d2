import 'package:application/widgets/AddItem/AddProduct.dart';
import 'package:application/widgets/Globals.dart';
import 'package:flutter/material.dart';

class NoDataScreen extends StatelessWidget {
  // final VoidCallback onRefresh;

  const NoDataScreen({Key? key,
  //  required this.onRefresh
   }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:()=> Globals.switchScreens(context: context,screen: AddProductForm()) ,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add Product',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
