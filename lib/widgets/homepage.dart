import 'package:application/widgets/Globals.dart';
import 'package:application/widgets/SellPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

class MotorbikePOSHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Turbo Moto POS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue[800],
        actions: [
          IconButton(icon: Icon(Icons.person), onPressed: () {}),
          IconButton(icon: Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: AnimationLimiter(
        child: ListView(
          padding: EdgeInsets.all(16),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 375),
            childAnimationBuilder: (widget) => SlideAnimation(
              horizontalOffset: 50.0,
              child: FadeInAnimation(
                child: widget,
              ),
            ),
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildQuickActions(context),
              SizedBox(height: 20),
              _buildSalesOverview(),
              SizedBox(height: 20),
              _buildInventoryOverview(),
              SizedBox(height: 20),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: Icon(Icons.add_shopping_cart),
        label: Text('New Sale'),
        backgroundColor: Colors.blue[800],
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage('/api/placeholder/100/100'),
            ),
            SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome back, Alex!',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Turbo Moto Shop',
                    style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: [
        _buildActionItem(context, Icons.sell, 'Sell', Colors.red,),

        _buildActionItem(context, Icons.build, 'Inventory', Colors.blue),
        _buildActionItem(context, Icons.inventory, 'Report', Colors.green),
        // _buildActionItem(Icons.attach_money, 'Payments', Colors.orange),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context,  IconData icon, String label, Color color) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          print("pressed");
          sellAlert(context);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: color),
            SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sales Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSalesStat(
                    'Today', '\$1,250', Icons.trending_up, Colors.green),
                _buildSalesStat(
                    'This Week', '\$8,750', Icons.trending_down, Colors.red),
                _buildSalesStat(
                    'This Month', '\$32,500', Icons.trending_up, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesStat(
      String period, String amount, IconData trendIcon, Color trendColor) {
    return Column(
      children: [
        Text(period, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(amount,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Icon(trendIcon, color: trendColor),
      ],
    );
  }

  Widget _buildInventoryOverview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInventoryStat('Bikes', '24', Icons.motorcycle),
                _buildInventoryStat('Parts', '543', Icons.settings),
                _buildInventoryStat('Accessories', '128', Icons.category),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStat(String category, String count, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue[800]),
        SizedBox(height: 8),
        Text(category, style: TextStyle(color: Colors.grey[600])),
        Text(count,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Transactions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildTransactionItem('John Doe', 'Motorcycle Service', '\$150'),
            _buildTransactionItem(
                'Jane Smith', 'New Bike Purchase', '\$12,000'),
            _buildTransactionItem('Mike Johnson', 'Parts Purchase', '\$350'),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
      String customer, String description, String amount) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.person),
      ),
      title: Text(customer),
      subtitle: Text(description),
      trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
