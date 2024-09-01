import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void sellAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: double.maxFinite,
          child: MotorbikePOSPage(), // Your form widget
        ),
      );
    },
  );
}

class MotorbikePOSPage extends StatefulWidget {
  @override
  _MotorbikePOSPageState createState() => _MotorbikePOSPageState();
}

class _MotorbikePOSPageState extends State<MotorbikePOSPage> {
  String? selectedCategory;
  String? selectedItem;
  TextEditingController buyingPriceController = TextEditingController();
  TextEditingController sellingPriceController = TextEditingController();
  String paymentMethod = 'cash';
  TextEditingController mpesaCodeController = TextEditingController();

  final List<String> categories = ['Sport', 'Cruiser', 'Touring', 'Off-road'];
  final Map<String, List<String>> items = {
    'Sport': ['Yamaha R1', 'Kawasaki Ninja', 'Honda CBR'],
    'Cruiser': ['Harley Davidson Street', 'Indian Scout', 'Suzuki Boulevard'],
    'Touring': ['BMW R1250RT', 'Honda Gold Wing', 'Kawasaki Versys'],
    'Off-road': ['KTM 450 EXC', 'Yamaha WR450F', 'Honda CRF450L'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Motorbike POS'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildDropdown(
                'Category',
                categories,
                selectedCategory,
                (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                    selectedItem = null;
                  });
                },
              ).animate().fadeIn(duration: 300.ms).slideX(),
              SizedBox(height: 16),
              if (selectedCategory != null)
                buildDropdown(
                  'Item',
                  items[selectedCategory]!,
                  selectedItem,
                  (String? newValue) {
                    setState(() {
                      selectedItem = newValue;
                    });
                  },
                ).animate().fadeIn(duration: 300.ms).slideX(),
              SizedBox(height: 16),
              buildTextField('Buying Price', buyingPriceController)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(),
              SizedBox(height: 16),
              buildTextField('Selling Price', sellingPriceController)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(),
              SizedBox(height: 16),
              buildPaymentMethodSelection()
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideX(),
              SizedBox(height: 16),
              if (paymentMethod == 'mpesa')
                buildTextField('M-Pesa Code', mpesaCodeController)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideX(),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => showSellConfirmation(),
                    child: Text('Sell'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ).animate().scale(duration: 300.ms),
                  ElevatedButton(
                    onPressed: () {
                      // Handle cancel action
                    },
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                  ).animate().scale(duration: 300.ms),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> items, String? value,
      void Function(String?) onChanged) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(label),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      keyboardType: TextInputType.number,
    );
  }

  Widget buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: Text('Cash'),
                value: 'cash',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: Text('M-Pesa'),
                value: 'mpesa',
                groupValue: paymentMethod,
                onChanged: (value) {
                  setState(() {
                    paymentMethod = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showSellConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Sale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: $selectedCategory'),
              Text('Item: $selectedItem'),
              Text('Buying Price: ${buyingPriceController.text}'),
              Text('Selling Price: ${sellingPriceController.text}'),
              Text('Payment Method: ${paymentMethod.toUpperCase()}'),
              if (paymentMethod == 'mpesa')
                Text('M-Pesa Code: ${mpesaCodeController.text}'),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                // Process the sale here
                Navigator.of(context).pop();
                // Show a success message or navigate to a new page
              },
            ),
          ],
        ).animate().scale();
      },
    );
  }
}
