import 'package:application/widgets/controllers/ProductWithStock.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProductPage extends StatefulWidget {
  final ProductData product;
  // final Function(BuildContext, ProductData) onRestock;
  // final Function(BuildContext, ProductData) onEdit;

  const EditProductPage({
    Key? key,
    required this.product,
  //  required this.onRestock,
  //   required this.onE dit,
  }) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final formatter = NumberFormat("#,##0.00", "en_US");

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = widget.product.quantity <= widget.product.reorderLevel;
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(theme),
                      const SizedBox(height: 16),
                      _buildCategories(theme),
                      const SizedBox(height: 16),
                      _buildStockInfo(isLowStock, theme),
                      const SizedBox(height: 16),
                      _buildPricingInfo(theme),
                      const SizedBox(height: 16),
                      _buildActions(context, theme),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image Container
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 36,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(height: 4),
              Text(
                '#${widget.product.id}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: widget.product.isActive,
                    onChanged: (value) {
                      // Handle status change
                    },
                    activeColor: theme.colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(ThemeData theme) {
    return Row(
      children: [
        _buildCategoryChip(
          icon: Icons.category_outlined,
          label: 'Category ${widget.product.category}',
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          textColor: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        _buildCategoryChip(
          icon: Icons.business_outlined,
          label: 'Brand ${widget.product.brand}',
          backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
          textColor: theme.colorScheme.secondary,
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfo(bool isLowStock, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStockInfoItem(
            icon: Icons.inventory,
            label: 'Current Stock',
            value: '${widget.product.quantity}',
            valueColor: isLowStock ? Colors.red : Colors.green,
            theme: theme,
          ),
          _buildStockInfoItem(
            icon: Icons.warning_amber_outlined,
            label: 'Reorder Level',
            value: '${widget.product.reorderLevel}',
            valueColor: theme.colorScheme.onSurface,
            theme: theme,
          ),
          _buildStockInfoItem(
            icon: Icons.update,
            label: 'Last Restocked',
            value: DateFormat('MM/dd/yy').format(widget.product.lastRestocked),
            valueColor: theme.colorScheme.onSurface,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStockInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.secondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingInfo(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriceItem(
          icon: Icons.shopping_bag_outlined,
          label: 'Buying Price',
          value: '\$${formatter.format(widget.product.buyingPrice)}',
          theme: theme,
        ),
        _buildPriceItem(
          icon: Icons.sell_outlined,
          label: 'Selling Price',
          value: '\$${formatter.format(widget.product.sellingPrice)}',
          valueColor: Colors.green,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildPriceItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    required ThemeData theme,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          //  widget.onEdit(context, widget.product),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: Text('Edit', style: GoogleFonts.inter(fontSize: 14)),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            side: BorderSide(color: theme.colorScheme.primary),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: (){},
          //  => widget.onRestock(context, widget.product),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Restock', style: GoogleFonts.inter(fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}