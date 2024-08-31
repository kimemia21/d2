import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/Inventory.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class POSHomepage extends StatefulWidget {
  const POSHomepage({Key? key}) : super(key: key);

  @override
  _POSHomepageState createState() => _POSHomepageState();
}

class _POSHomepageState extends State<POSHomepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  late Animation<double> _bikeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animations = List.generate(
      5,
      (index) => Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve:
              Interval(index * 0.1, (index + 1) * 0.1, curve: Curves.easeOut),
        ),
      ),
    );

    _bikeAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedButton(
      String text, Color color, IconData icon, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: ElevatedButton.icon(
              onPressed: () {
                 Globals.switchScreens(
                            context: context,
                            screen: InventoryPage());
                // Add functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                  fontSize: 18,
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
        actions: [Icon(Icons.logout_outlined)],
        title: Text('Motorbike POS',
            style: GoogleFonts.roboto(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 28)),
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bikeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    MediaQuery.of(context).size.width * _bikeAnimation.value,
                    MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: Image.network(
                    'https://cdn-icons-png.flaticon.com/512/1986/1986937.png',
                    width: 100,
                    height: 100,
                  ),
                );
              },
            ),
          ),
          Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: [
                _buildAnimatedButton(
                    'New Sale',
                    Colors.green.shade600,
                    Icons.add_shopping_cart,
                    _animations[0]),
                _buildAnimatedButton('Inventory Management',
                    Colors.blue.shade600, Icons.inventory_2, _animations[1]),
                _buildAnimatedButton('Sales Report', Colors.orange.shade600,
                    Icons.bar_chart, _animations[2]),
                _buildAnimatedButton('Customer Management',
                    Colors.purple.shade600, Icons.people, _animations[3]),
                _buildAnimatedButton('Service Orders', Colors.teal.shade600,
                    Icons.build, _animations[4]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
