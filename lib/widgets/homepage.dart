import 'package:application/widgets/Inventory.dart';
import 'package:application/widgets/commsRepo/commsRepo.dart';
import 'package:application/widgets/sell/SellPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:application/widgets/Firebase/FirebaseModels/FirebaseStore.dart';
import 'package:application/widgets/Product/ProductForm.dart';
import 'package:application/widgets/Models/ProductWithStock.dart';
import 'package:application/widgets/state/AppBloc.dart';
import 'package:provider/provider.dart';
import 'package:application/widgets/Globals.dart';

class POSHomePage extends StatefulWidget {
  const POSHomePage({Key? key}) : super(key: key);

  @override
  _POSHomePageState createState() => _POSHomePageState();
}

class _POSHomePageState extends State<POSHomePage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Future<List<Stock>> stockFuture;
  late Future<List<Transaction>> recentTransactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    stockFuture = _firestoreService.getStock(isFiltered: false);
    // Add your transaction loading logic here
    // recentTransactionsFuture = _firestoreService.getRecentTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final appBloc = Provider.of<Appbloc>(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Container(
                color: Colors.grey[100],
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      _buildDashboardCards(),
                      const SizedBox(height: 24),
                      _buildRecentActivity(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[600],
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome Back',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser!.email.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.blue[50],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // Add settings navigation
            },
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {
        'title': 'New Sale',
        'icon': Icons.point_of_sale,
        'onTap': () {
          Globals.switchScreens(context: context, screen: SalePage());
          // Navigate to New Sale
        },
        'color': Colors.blue[600]!,
      },
      {
        'title': 'Inventory',
        'icon': Icons.inventory_2_outlined,
        'onTap': () {
             Globals.switchScreens(context: context, screen: InventoryPage());
          // Navigate to Inventory
        },
        'color': Colors.green[600]!,
      },
      {
        'title': 'Reports',
        'icon': Icons.bar_chart,
        'onTap': () {
          // Navigate to Reports
        },
        'color': Colors.orange[600]!,
      },
      {
        'title': 'Customers',
        'icon': Icons.people_outline,
        'onTap': () {
          // Navigate to Customers
        },
        'color': Colors.purple[600]!,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: action['onTap'] as Function(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action['icon'] as IconData,
                        size: 32,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCards() {
    return FutureBuilder<List<Stock>>(
      future: stockFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final stocks = snapshot.data ?? [];
        final totalValue = stocks.fold<double>(
          0,
          (sum, stock) => sum + (stock.quantity * stock.product.sellingPrice),
        );

        final cards = [
          {
            'title': 'Total Inventory Value',
            'value': '\$${NumberFormat('#,##0.00').format(totalValue)}',
            'icon': Icons.inventory_2,
            'color': Colors.blue[600]!,
          },
          {
            'title': 'Low Stock Items',
            'value': stocks
                .where((stock) => stock.quantity <= stock.reorderLevel)
                .length
                .toString(),
            'icon': Icons.warning_amber,
            'color': Colors.orange[600]!,
          },
          {
            'title': 'Total Products',
            'value': stocks.length.toString(),
            'icon': Icons.category,
            'color': Colors.green[600]!,
          },
        ];

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          card['icon'] as IconData,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          card['title'] as String,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    card['value'] as String,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    // Replace with actual transaction data
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart,
                        color: Colors.blue[600],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sale #${1001 + index}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '2 items',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${99.99 + index}',
                          style: TextStyle(
                            color: Colors.green[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '2 mins ago',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
