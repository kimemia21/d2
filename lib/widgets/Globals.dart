import 'dart:math';

import 'package:application/widgets/Firebase/FirebaseModels/FirebaseStore.dart';
import 'package:application/widgets/requests/Request.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class Globals {
  static var uuid = Uuid();

// SnackBar for in app activities

  void snackbar(
      {required BuildContext context,
      required bool isError,
      required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // Message to user
        backgroundColor:
            isError ? Colors.red : Colors.green, // Red background for error
      ),
    );
  }

// Widget to show when data is being loaded

  static Widget buildLoadingCard() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

// Widget to show when an error occurs
  static Widget buildErrorCard(String errorMessage) {
    return Center(
      child: Text(
        "Error: $errorMessage",
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  static Widget buildEmptyCard() {
    return const Center(
      child: Text("No stock data available."),
    );
  }

  static Future<void> switchScreens(
      {required BuildContext context, required Widget screen}) {
    try {
      return Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(
                milliseconds:
                    600), // Increase duration for a smoother transition
            pageBuilder: (context, animation, secondaryAnimation) => screen,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final opacityTween = Tween(begin: 0.0, end: 1.0);
              final scaleTween = Tween(
                  begin: 0.95,
                  end: 1.0); // Slight scale transition for ambient effect
              final curvedAnimation = CurvedAnimation(
                parent: animation,
                curve:
                    Curves.easeInOut, // Use easeInOut for a smoother transition
              );

              return FadeTransition(
                opacity: opacityTween.animate(curvedAnimation),
                child: ScaleTransition(
                  scale: scaleTween.animate(curvedAnimation),
                  child: child,
                ),
              );
            },
          ));
    } catch (e) {
      throw Exception(e);
    }
  }

  static void showAddBrandOrCategoryDialog({
    required BuildContext context,
    required String title,
    required Future future,
    required bool isBrand,
    required String? selectedCategory,
  }) {
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
                        print(newItem);
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
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                      ),
                      style: GoogleFonts.poppins(
                          color: Colors.black87, fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Existing ${title.toLowerCase()}:",
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                        height: 200, // Reduced height
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FutureBuilder(
                            future: future,
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                final data = snapshot.data;
                                return ListView.builder(
                                  itemCount: data!.length,
                                  itemBuilder: (context, index) {
                                    final item = data[index];
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  ),
                  // Function to handle button press
                  onPressed: () async {
                    try {
                      // Check if the new item name is not empty
                      if (newItem.isNotEmpty) {
                        // Create a request body based on whether it's a brand or category
                        final Map<String, dynamic> body = isBrand
                            ? {
                                "name": newItem
                                    .toUpperCase(), // Convert name to uppercase
                                "category":
                                    selectedCategory, // Parse the selected category
                              }
                            : {
                                "name": newItem
                                    .toUpperCase(), // Only name for non-brand items
                              };

                        // Make the API request to create the brand or category

                        Category category = Category(
                            id: uuid.v4().toString(),
                            name: newItem,
                            createdAt: DateTime.now());

                        await FirestoreService().createCollection(
                            context: context,
                            isCategory: true,
                            isBrand: isBrand,
                            category: category);

                        // await AppRequest.CreateBrandOrCategory(
                        //   isBrand: isBrand,
                        //   body: body,
                        //   context: context,
                        // );
                      } else {
                        // Show a Snackbar if the item name is empty
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Please enter a $title name'), // Message to user
                            backgroundColor:
                                Colors.red, // Red background for error
                          ),
                        );
                      }
                    } catch (e) {
                      // Handle any exceptions that occur during the process
                      throw Exception("Error: $e");
                    }
                  },
                  child: context.watch<Appbloc>().isloading
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget buildDropdownWithButton(
      {required addNewItem,
      required Widget dropdown,
      required BuildContext context}) {
    return Row(
      children: [
        Expanded(child: dropdown),
        const SizedBox(width: 10),
        ElevatedButton.icon(
          onPressed: addNewItem,
          icon: const Icon(Icons.add),
          label: Text('New', style: GoogleFonts.poppins(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          ),
        ),
      ],
    );
  }

  static Widget ShowDropdownWithButton({
    required Widget dropdown,
    required VoidCallback addNewItem,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                TextButton.icon(
                  onPressed: addNewItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Add $label'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
          dropdown,
        ],
      ),
    );
  }
}
