import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Set the desired width
      height: 60, // Set the desired height
      child: ElevatedButton(
        onPressed: () {
          // Add your onPressed logic here
        },
        style: ElevatedButton.styleFrom(
          elevation: 8, // Adds elevation for shadow effect
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Responsive padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          backgroundColor: Colors.blue, // Background color of the button
          shadowColor: Colors.grey, // Shadow color for elevation
        ),
        child: Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16, // Responsive font size
            fontWeight: FontWeight.bold, // Bold text
            letterSpacing: 1.2, // Spacing between letters
          ),
        ),
      ),
    );
  }
}
