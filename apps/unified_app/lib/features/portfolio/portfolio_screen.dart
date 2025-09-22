import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/asset.dart';
import '../../providers/rofr_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Portfolio',
          style: AppTextStyles.heading2.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portfolio Summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Portfolio Value',
                    style: AppTextStyles.body1.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$24,750.00',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem('Assets Owned', '3'),
                      ),
                      Expanded(
                        child: _buildSummaryItem('Total Shares', '275'),
                      ),
                      Expanded(
                        child: _buildSummaryItem('Monthly Income', '\$1,250'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Holdings Section
            Text(
              'Your Holdings',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            ..._getMockHoldings().map((holding) => _buildHoldingCard(holding)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHoldingCard(PortfolioHolding holding) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getAssetIcon(holding.asset.type),
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        holding.asset.title,
                        style: AppTextStyles.heading4.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        holding.asset.location?.shortAddress ?? 'Location not available',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'sell',
                      child: Row(
                        children: [
                          Icon(Icons.sell, size: 20, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text('Sell Shares'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'details',
                      child: Row(
                        children: [
                          Icon(Icons.info, size: 20, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'sell') {
                      _showSellSharesDialog(holding);
                    } else if (value == 'details') {
                      // Navigate to asset details
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Holdings details
            Row(
              children: [
                Expanded(
                  child: _buildDetailColumn('Shares Owned', holding.sharesOwned.toString()),
                ),
                Expanded(
                  child: _buildDetailColumn('Purchase Price', '\$${holding.avgPurchasePrice.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildDetailColumn('Current Value', '\$${holding.currentValue.toStringAsFixed(2)}'),
                ),
                Expanded(
                  child: _buildDetailColumn(
                    'P&L',
                    '${holding.profitLoss >= 0 ? '+' : ''}\$${holding.profitLoss.toStringAsFixed(2)}',
                    textColor: holding.profitLoss >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Ownership percentage bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ownership',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${holding.ownershipPercentage.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: holding.ownershipPercentage / 100,
                  backgroundColor: AppColors.background,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value, {Color? textColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showSellSharesDialog(PortfolioHolding holding) {
    int sharesToSell = 1;
    double pricePerShare = holding.avgPurchasePrice;
    String notes = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            'Sell Shares',
            style: AppTextStyles.heading3,
          ),
          content: Container(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  holding.asset.title,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'You own ${holding.sharesOwned} shares',
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Number of shares to sell
                Text(
                  'Shares to sell:',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: sharesToSell.toDouble(),
                        min: 1,
                        max: holding.sharesOwned.toDouble(),
                        divisions: holding.sharesOwned - 1,
                        label: sharesToSell.toString(),
                        onChanged: (value) {
                          setState(() {
                            sharesToSell = value.round();
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 60,
                      child: Text(
                        sharesToSell.toString(),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price per share
                Text(
                  'Price per share (\$):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Enter price per share',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) {
                    pricePerShare = double.tryParse(value) ?? pricePerShare;
                  },
                  controller: TextEditingController(
                    text: pricePerShare.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Total value
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Value:',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(sharesToSell * pricePerShare).toStringAsFixed(2)}',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Notes
                Text(
                  'Notes (optional):',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (value) => notes = value,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add a note for potential buyers...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ROFR explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Right of First Refusal: Existing shareholders will have 48 hours to purchase your shares before they\'re offered to the public market.',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _initiateSale(holding, sharesToSell, pricePerShare, notes),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
              child: const Text(
                'Initiate Sale',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initiateSale(
    PortfolioHolding holding,
    int sharesToSell,
    double pricePerShare,
    String notes,
  ) async {
    Navigator.of(context).pop();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('Initiating ROFR process...'),
              ],
            ),
          ),
        ),
      ),
    );

    // Create ROFR offer
    final offerId = await ref.read(rofrProvider.notifier).createRofrOffer(
      assetId: holding.asset.id.toString(),
      assetTitle: holding.asset.title,
      sharesOffered: sharesToSell,
      pricePerShare: pricePerShare,
      notes: notes.isNotEmpty ? notes : null,
    );

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            offerId != null
                ? 'ROFR offer created! Existing shareholders have been notified.'
                : 'No existing shareholders found. Your shares will be listed on the market.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'house':
        return Icons.home;
      case 'hotel':
        return Icons.hotel;
      case 'truck':
        return Icons.local_shipping;
      case 'land':
        return Icons.landscape;
      default:
        return Icons.business;
    }
  }

  List<PortfolioHolding> _getMockHoldings() {
    return [
      PortfolioHolding(
        asset: Asset(
          id: 1,
          title: 'Premium Office Complex Downtown',
          description: 'Prime commercial real estate in downtown business district',
          type: 'house',
          spvId: 'SPV001',
          status: 'active',
          nav: '850000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 180)),
          images: [],
          location: AssetLocation(
            latitude: 40.7128,
            longitude: -74.0060,
            address: '123 Business Ave',
            city: 'New York',
            state: 'NY',
            country: 'USA',
          ),
        ),
        sharesOwned: 100,
        avgPurchasePrice: 120.0,
        currentValue: 12500.0,
        ownershipPercentage: 10.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 180)),
      ),
      PortfolioHolding(
        asset: Asset(
          id: 2,
          title: 'Luxury Residential Apartments',
          description: 'High-end residential complex with modern amenities',
          type: 'hotel',
          spvId: 'SPV002',
          status: 'active',
          nav: '1200000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 120)),
          images: [],
          location: AssetLocation(
            latitude: 34.0522,
            longitude: -118.2437,
            address: '456 Luxury Blvd',
            city: 'Los Angeles',
            state: 'CA',
            country: 'USA',
          ),
        ),
        sharesOwned: 75,
        avgPurchasePrice: 195.0,
        currentValue: 15000.0,
        ownershipPercentage: 5.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 120)),
      ),
      PortfolioHolding(
        asset: Asset(
          id: 3,
          title: 'Commercial Vehicle Fleet',
          description: 'Fleet of delivery trucks for logistics operations',
          type: 'truck',
          spvId: 'SPV003',
          status: 'active',
          nav: '500000',
          verificationRequired: false,
          createdAt: DateTime.now().subtract(Duration(days: 90)),
          images: [],
          location: AssetLocation(
            latitude: 41.8781,
            longitude: -87.6298,
            address: '789 Transport St',
            city: 'Chicago',
            state: 'IL',
            country: 'USA',
          ),
        ),
        sharesOwned: 100,
        avgPurchasePrice: 98.0,
        currentValue: 10000.0,
        ownershipPercentage: 20.0,
        purchaseDate: DateTime.now().subtract(Duration(days: 90)),
      ),
    ];
  }
}

class PortfolioHolding {
  final Asset asset;
  final int sharesOwned;
  final double avgPurchasePrice;
  final double currentValue;
  final double ownershipPercentage;
  final DateTime purchaseDate;

  double get profitLoss => currentValue - (sharesOwned * avgPurchasePrice);

  PortfolioHolding({
    required this.asset,
    required this.sharesOwned,
    required this.avgPurchasePrice,
    required this.currentValue,
    required this.ownershipPercentage,
    required this.purchaseDate,
  });
}