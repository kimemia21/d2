import 'package:application/widgets/Inventory.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';

class MotorbikePOSHomePage extends StatelessWidget {
  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(
          'Turbo Moto POS',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue[50],
              child: Icon(Icons.person_outline, color: Colors.blue, size: 24),
            ),
          ),
          SizedBox(width: 8),
        ],
        elevation: 0,
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: EdgeInsets.all(20),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 20.0,
              child: FadeInAnimation(child: widget),
            ),
            children: [
              _buildHeader(),
              SizedBox(height: 28),
              _buildQuickActions(context),
              SizedBox(height: 28),
              _buildSalesOverview(),
              SizedBox(height: 28),
              _buildInventoryOverview(),
              SizedBox(height: 28),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add_shopping_cart, size: 28),
        label: Text(
          'New Sale',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 4,
        // padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[600]!, Colors.blue[800]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child:
                    Icon(Icons.person_outline, color: Colors.white, size: 36),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      'Alex Morgan',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //   decoration: BoxDecoration(
          //     color: Colors.white.withOpacity(0.1),
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Text(
          //         'Today\'s Revenue',
          //         style: GoogleFonts.poppins(
          //           fontSize: 16,
          //           color: Colors.white70,
          //         ),
          //       ),
          //       // Text(
          //       //   '\$4,280.50',
          //       //   style: GoogleFonts.poppins(
          //       //     fontSize: 24,
          //       //     fontWeight: FontWeight.bold,
          //       //     color: Colors.white,
          //       //   ),
          //       // ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        _buildActionItem('Sell', Icons.sell_outlined, Colors.purple, context,  InventoryPage()),
        _buildActionItem(
            'Inventory', Icons.inventory_2_outlined, Colors.orange, context, InventoryPage()),
        _buildActionItem('Reports', Icons.assessment_outlined, Colors.green, context, InventoryPage()),
      ],
    );
  }

  Widget _buildActionItem(
      String label, IconData icon, Color color, BuildContext context, Widget screen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
              Navigator.push(
            context, MaterialPageRoute(builder: (context) =>screen));
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSalesOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sales Overview',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'This Week',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSalesStat('Today', '\$1,250', 12.5, true)),
              SizedBox(width: 16),
              Expanded(child: _buildSalesStat('Week', '\$8,750', -2.3, false)),
              SizedBox(width: 16),
              Expanded(child: _buildSalesStat('Month', '\$32,500', 8.7, true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesStat(
      String period, String amount, double change, bool isPositive) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green[50] : Colors.red[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  size: 18,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                SizedBox(width: 4),
                Text(
                  '${change.abs()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isPositive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryOverview() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Overview',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInventoryStat(
                    'Bikes', '24', Icons.motorcycle_outlined, Colors.blue),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInventoryStat(
                    'Parts', '543', Icons.settings_outlined, Colors.orange),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildInventoryStat('Accessories', '128',
                    Icons.category_outlined, Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryStat(
      String category, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: color),
          SizedBox(height: 12),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 4),
          Text(
            category,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildTransactionItem(
            'John Doe',
            'Motorcycle Service',
            '\$150',
            DateTime.now(),
            Colors.orange,
            Icons.build_outlined,
          ),
          Divider(height: 32, thickness: 1),
          _buildTransactionItem(
            'Jane Smith',
            'Motorbike Sale',
            '\$2,500',
            DateTime.now().subtract(Duration(days: 1)),
            Colors.green,
            Icons.monetization_on,
          ),
          Divider(height: 32, thickness: 1),
          _buildTransactionItem(
            'Alice Johnson',
            'Accessory Sale',
            '\$45',
            DateTime.now().subtract(Duration(days: 2)),
            Colors.blue,
            Icons.category_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String customerName, String transactionType,
      String amount, DateTime date, Color color, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  transactionType,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
