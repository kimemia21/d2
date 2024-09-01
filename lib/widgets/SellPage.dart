import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void sellAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.grey[200],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          child: MotorbikePOSPage(),
        ),
      ).animate().scale(duration: 300.ms);
    },
  );
}

class MotorbikePOSPage extends StatefulWidget {
  @override
  _MotorbikePOSPageState createState() => _MotorbikePOSPageState();
}

class _MotorbikePOSPageState extends State<MotorbikePOSPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController buyingPriceController = TextEditingController();
  final TextEditingController clientNameController = TextEditingController();
  final TextEditingController mpesaCodeController = TextEditingController();

  // Variables
  String? selectedCategory;
  String? selectedItem;
  String paymentMethod = 'cash';

  // Data
  final List<String> categories = ['Sport', 'Cruiser', 'Touring', 'Off-road'];
  final Map<String, List<String>> items = {
    'Sport': ['Yamaha R1', 'Kawasaki Ninja', 'Honda CBR'],
    'Cruiser': ['Harley Davidson Street', 'Indian Scout', 'Suzuki Boulevard'],
    'Touring': ['BMW R1250RT', 'Honda Gold Wing', 'Kawasaki Versys'],
    'Off-road': ['KTM 450 EXC', 'Yamaha WR450F', 'Honda CRF450L'],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[300]!, Colors.grey[200]!],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.blue[700],
          elevation: 0,
          title: Text(
            'New Sale',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ).animate().fade(duration: 500.ms),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildDropdown(
                  label: 'Category',
                  items: categories,
                  value: selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedCategory = newValue;
                      selectedItem = null;
                    });
                  },
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                if (selectedCategory != null)
                  buildDropdown(
                    label: 'Item',
                    items: items[selectedCategory]!,
                    value: selectedItem,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedItem = newValue;
                      });
                    },
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Buying Price',
                  controller: buyingPriceController,
                  icon: Icons.attach_money,
                  readOnly: true,
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Selling Price',
                  controller: sellingPriceController,
                  icon: Icons.monetization_on,
                  inputType: TextInputType.number,
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Quantity',
                  controller: quantityController,
                  icon: Icons.format_list_numbered,
                  inputType: TextInputType.number,
                ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                const SizedBox(height: 16),
                buildTextField(
                  label: 'Client Name',
                  controller: clientNameController,
                  icon: Icons.person,
                  inputType: TextInputType.name,
                ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),
                buildPaymentMethodSelection().animate().fadeIn(duration: 300.ms).slideX(begin: 0.1),
                if (paymentMethod == 'mpesa')
                  const SizedBox(height: 16),
                if (paymentMethod == 'mpesa')
                  buildTextField(
                    label: 'M-Pesa Code',
                    controller: mpesaCodeController,
                    icon: Icons.confirmation_number,
                  ).animate().fadeIn(duration: 300.ms).slideX(begin: -0.1),
                const SizedBox(height: 24),
                buildActionButtons().animate().scale(duration: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[700]!),
        color: Colors.white,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(label, style: TextStyle(color: Colors.blue[700])),
        isExpanded: true,
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87),
        icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.blue[700]),
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: inputType,
      readOnly: readOnly,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        if (inputType == TextInputType.number && int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget buildPaymentMethodSelection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[700]!),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Cash', style: TextStyle(color: Colors.black87)),
                  value: 'cash',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                  activeColor: Colors.blue[700],
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('M-Pesa', style: TextStyle(color: Colors.black87)),
                  value: 'mpesa',
                  groupValue: paymentMethod,
                  onChanged: (value) {
                    setState(() {
                      paymentMethod = value!;
                    });
                  },
                  activeColor: Colors.blue[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ).animate().scale(duration: 300.ms),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Perform the sale action
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ).animate().scale(duration: 300.ms),
        ),
      ],
    );
  }
}
