import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class POSHomepage extends StatefulWidget {
  const POSHomepage({Key? key}) : super(key: key);

  @override
  _POSHomepageState createState() => _POSHomepageState();
}

class _POSHomepageState extends State<POSHomepage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animations = List.generate(
      3,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(index * 0.2, (index + 1) * 0.2, curve: Curves.easeOut),
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedButton(String text, Color color, IconData icon, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: ElevatedButton.icon(
              
              onPressed: () {
                // Add functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
              label: Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS Homepage', style: GoogleFonts.roboto(fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: Wrap(
          spacing: 30,
          runSpacing: 30,
          alignment: WrapAlignment.center,
          children: [
            _buildAnimatedButton('Sales', Colors.green.shade600, Icons.attach_money, _animations[0]),
            _buildAnimatedButton('Sell', Colors.blue.shade600, Icons.shopping_cart, _animations[1]),
            _buildAnimatedButton('Inventory Report', Colors.orange.shade600, Icons.inventory, _animations[2]),
          ],
        ),
      ),
    );
  }
}
