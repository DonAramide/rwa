import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_service.dart';
import '../../models/rofr_models.dart';
import '../../providers/rofr_provider.dart';

class ShareholderDirectoryScreen extends ConsumerStatefulWidget {
  final String assetId;
  final String assetTitle;

  const ShareholderDirectoryScreen({
    super.key,
    required this.assetId,
    required this.assetTitle,
  });

  @override
  ConsumerState<ShareholderDirectoryScreen> createState() => _ShareholderDirectoryScreenState();
}

class _ShareholderDirectoryScreenState extends ConsumerState<ShareholderDirectoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _sortBy = 'ownership'; // ownership, shares, name, date
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load shareholder data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(shareholderDirectoryProvider.notifier).loadAssetShareholders(widget.assetId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shareholderState = ref.watch(shareholderDirectoryProvider);

    return Scaffold(
      backgroundColor: ThemeService.getScaffoldBackground(context),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shareholders',
              style: AppTextStyles.heading3.copyWith(
                color: ThemeService.getTextPrimary(context),
              ),
            ),
            Text(
              widget.assetTitle,
              style: AppTextStyles.caption.copyWith(
                color: ThemeService.getTextSecondary(context),
              ),
            ),
          ],
        ),
        backgroundColor: ThemeService.getAppBarBackground(context),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.sort, color: ThemeService.getTextSecondary(context)),
            onSelected: (value) => _updateSort(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'ownership',
                child: Row(
                  children: [
                    Icon(Icons.pie_chart, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Sort by Ownership'),
                    if (_sortBy == 'ownership') ...[
                      const Spacer(),
                      Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'shares',
                child: Row(
                  children: [
                    Icon(Icons.confirmation_number, size: 20, color: AppColors.info),
                    const SizedBox(width: 8),
                    const Text('Sort by Shares'),
                    if (_sortBy == 'shares') ...[
                      const Spacer(),
                      Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text('Sort by Name'),
                    if (_sortBy == 'name') ...[
                      const Spacer(),
                      Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 20, color: AppColors.warning),
                    const SizedBox(width: 8),
                    const Text('Sort by Join Date'),
                    if (_sortBy == 'date') ...[
                      const Spacer(),
                      Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward, size: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => ref.read(shareholderDirectoryProvider.notifier).refreshShareholders(widget.assetId),
            icon: shareholderState.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.refresh, color: ThemeService.getTextSecondary(context)),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: ThemeService.getTextSecondary(context),
          tabs: const [
            Tab(text: 'Active Shareholders'),
            Tab(text: 'Ownership Analytics'),
          ],
        ),
      ),
      body: shareholderState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shareholderState.error != null
              ? _buildErrorState(shareholderState.error!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildShareholdersTab(shareholderState),
                    _buildAnalyticsTab(shareholderState),
                  ],
                ),
    );
  }

  Widget _buildShareholdersTab(ShareholderDirectoryState state) {
    final shareholders = _getSortedShareholders(state.shareholders);

    if (shareholders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(shareholderDirectoryProvider.notifier).refreshShareholders(widget.assetId),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: shareholders.length + 1, // +1 for summary header
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildSummaryCard(shareholders);
          }
          return _buildShareholderCard(context, shareholders[index - 1], index);
        },
      ),
    );
  }

  Widget _buildAnalyticsTab(ShareholderDirectoryState state) {
    final shareholders = state.shareholders;
    final analytics = _calculateAnalytics(shareholders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOwnershipDistributionCard(context, analytics),
          const SizedBox(height: 20),
          _buildInvestorMetricsCard(context, analytics),
          const SizedBox(height: 20),
          _buildRofrEligibilityCard(context, shareholders),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(List<ShareholderInfo> shareholders) {
    final totalShares = shareholders.fold(0, (sum, s) => sum + s.sharesOwned);
    final totalOwnership = shareholders.fold(0.0, (sum, s) => sum + s.ownershipPercentage);
    final eligibleCount = shareholders.where((s) => s.isEligibleForRofr).length;

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Ownership Summary',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem('Total Shareholders', shareholders.length.toString()),
                ),
                Expanded(
                  child: _buildSummaryItem('Total Shares Held', totalShares.toString()),
                ),
                Expanded(
                  child: _buildSummaryItem('Total Ownership', '${totalOwnership.toStringAsFixed(1)}%'),
                ),
                Expanded(
                  child: _buildSummaryItem('ROFR Eligible', eligibleCount.toString()),
                ),
              ],
            ),
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
            color: ThemeService.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildShareholderCard(BuildContext context, ShareholderInfo shareholder, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _getRankColor(rank).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _getRankColor(rank)),
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: AppTextStyles.caption.copyWith(
                        color: _getRankColor(rank),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Shareholder info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            shareholder.name,
                            style: AppTextStyles.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ThemeService.getTextPrimary(context),
                            ),
                          ),
                          if (!shareholder.isEligibleForRofr) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Restricted',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        shareholder.email,
                        style: AppTextStyles.body2.copyWith(
                          color: ThemeService.getTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ownership visualization
                Container(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: shareholder.ownershipPercentage / 100,
                          backgroundColor: ThemeService.getBorder(context),
                          valueColor: AlwaysStoppedAnimation(_getRankColor(rank)),
                          strokeWidth: 6,
                        ),
                      ),
                      Center(
                        child: Text(
                          '${shareholder.ownershipPercentage.toStringAsFixed(1)}%',
                          style: AppTextStyles.caption.copyWith(
                            fontWeight: FontWeight.bold,
                            color: ThemeService.getTextPrimary(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Details row
            Row(
              children: [
                Expanded(
                  child: _buildDetailColumn('Shares Owned', shareholder.sharesOwned.toString()),
                ),
                Expanded(
                  child: _buildDetailColumn('Investment Date', _formatDate(shareholder.purchaseDate)),
                ),
                Expanded(
                  child: _buildDetailColumn(
                    'Days Held',
                    DateTime.now().difference(shareholder.purchaseDate).inDays.toString(),
                  ),
                ),
                Expanded(
                  child: _buildDetailColumn(
                    'ROFR Status',
                    shareholder.isEligibleForRofr ? 'Eligible' : 'Restricted',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: ThemeService.getTextSecondary(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w600,
            color: ThemeService.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  Widget _buildOwnershipDistributionCard(BuildContext context, ShareholderAnalytics analytics) {
    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pie_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Ownership Distribution',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            ...analytics.ownershipTiers.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getTierColor(entry.key),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getTierLabel(entry.key),
                        style: AppTextStyles.body2.copyWith(
                          color: ThemeService.getTextPrimary(context),
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value} shareholders',
                      style: AppTextStyles.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeService.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvestorMetricsCard(BuildContext context, ShareholderAnalytics analytics) {
    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppColors.success, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Investor Metrics',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Average Ownership', '${analytics.averageOwnership.toStringAsFixed(2)}%'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard('Average Shares', analytics.averageShares.toStringAsFixed(0)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard('Average Hold Time', '${analytics.averageHoldDays} days'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMetricCard('Concentration Risk', _getConcentrationRisk(analytics.concentrationIndex)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRofrEligibilityCard(BuildContext context, List<ShareholderInfo> shareholders) {
    final eligible = shareholders.where((s) => s.isEligibleForRofr).length;
    final total = shareholders.length;
    final restricted = total - eligible;

    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, color: AppColors.info, size: 24),
                const SizedBox(width: 12),
                Text(
                  'ROFR Eligibility',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.success.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          eligible.toString(),
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Eligible',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          restricted.toString(),
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Restricted',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'ROFR eligibility is typically based on holding period, share count minimums, and regulatory compliance. Restricted shareholders cannot participate in right of first refusal offers.',
              style: AppTextStyles.body2.copyWith(
                color: ThemeService.getTextSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: ThemeService.getTextSecondary(context).withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'No Shareholders Found',
            style: AppTextStyles.heading3.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'This asset doesn\'t have any shareholders yet.',
            style: AppTextStyles.body2.copyWith(
              color: ThemeService.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text('Error Loading Shareholders', style: AppTextStyles.heading3),
          const SizedBox(height: 8),
          Text(error, style: AppTextStyles.body2),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(shareholderDirectoryProvider.notifier).refreshShareholders(widget.assetId),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<ShareholderInfo> _getSortedShareholders(List<ShareholderInfo> shareholders) {
    final sortedList = [...shareholders];

    sortedList.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'ownership':
          comparison = a.ownershipPercentage.compareTo(b.ownershipPercentage);
          break;
        case 'shares':
          comparison = a.sharesOwned.compareTo(b.sharesOwned);
          break;
        case 'name':
          comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
          break;
        case 'date':
          comparison = a.purchaseDate.compareTo(b.purchaseDate);
          break;
        default:
          comparison = 0;
      }

      return _sortAscending ? comparison : -comparison;
    });

    return sortedList;
  }

  void _updateSort(String sortBy) {
    setState(() {
      if (_sortBy == sortBy) {
        _sortAscending = !_sortAscending;
      } else {
        _sortBy = sortBy;
        _sortAscending = sortBy == 'name' || sortBy == 'date';
      }
    });
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return AppColors.portfolio; // Top 3
    if (rank <= 10) return AppColors.primary; // Top 10
    return AppColors.textSecondary; // Others
  }

  Color _getTierColor(String tier) {
    switch (tier) {
      case 'major': return AppColors.error;
      case 'significant': return AppColors.warning;
      case 'moderate': return AppColors.primary;
      case 'minor': return AppColors.info;
      default: return AppColors.textSecondary;
    }
  }

  String _getTierLabel(String tier) {
    switch (tier) {
      case 'major': return 'Major Shareholders (>25%)';
      case 'significant': return 'Significant Shareholders (10-25%)';
      case 'moderate': return 'Moderate Shareholders (5-10%)';
      case 'minor': return 'Minor Shareholders (<5%)';
      default: return 'Other';
    }
  }

  String _getConcentrationRisk(double index) {
    if (index > 0.8) return 'Very High';
    if (index > 0.6) return 'High';
    if (index > 0.4) return 'Moderate';
    if (index > 0.2) return 'Low';
    return 'Very Low';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  ShareholderAnalytics _calculateAnalytics(List<ShareholderInfo> shareholders) {
    if (shareholders.isEmpty) {
      return ShareholderAnalytics(
        ownershipTiers: {},
        averageOwnership: 0,
        averageShares: 0,
        averageHoldDays: 0,
        concentrationIndex: 0,
      );
    }

    final tiers = <String, int>{};
    double totalOwnership = 0;
    int totalShares = 0;
    int totalHoldDays = 0;
    double concentrationSum = 0;

    final now = DateTime.now();

    for (final shareholder in shareholders) {
      // Categorize by ownership tier
      final ownership = shareholder.ownershipPercentage;
      String tier;
      if (ownership >= 25) tier = 'major';
      else if (ownership >= 10) tier = 'significant';
      else if (ownership >= 5) tier = 'moderate';
      else tier = 'minor';

      tiers[tier] = (tiers[tier] ?? 0) + 1;

      // Calculate averages
      totalOwnership += ownership;
      totalShares += shareholder.sharesOwned;
      totalHoldDays += now.difference(shareholder.purchaseDate).inDays;

      // Concentration index (Herfindahl)
      concentrationSum += (ownership / 100) * (ownership / 100);
    }

    return ShareholderAnalytics(
      ownershipTiers: tiers,
      averageOwnership: totalOwnership / shareholders.length,
      averageShares: totalShares / shareholders.length,
      averageHoldDays: (totalHoldDays / shareholders.length).round(),
      concentrationIndex: concentrationSum,
    );
  }
}

// Analytics model
class ShareholderAnalytics {
  final Map<String, int> ownershipTiers;
  final double averageOwnership;
  final double averageShares;
  final int averageHoldDays;
  final double concentrationIndex;

  ShareholderAnalytics({
    required this.ownershipTiers,
    required this.averageOwnership,
    required this.averageShares,
    required this.averageHoldDays,
    required this.concentrationIndex,
  });
}

// State classes for shareholder directory
class ShareholderDirectoryState {
  final List<ShareholderInfo> shareholders;
  final bool isLoading;
  final String? error;

  const ShareholderDirectoryState({
    this.shareholders = const [],
    this.isLoading = false,
    this.error,
  });

  ShareholderDirectoryState copyWith({
    List<ShareholderInfo>? shareholders,
    bool? isLoading,
    String? error,
  }) {
    return ShareholderDirectoryState(
      shareholders: shareholders ?? this.shareholders,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Notifier for shareholder directory
class ShareholderDirectoryNotifier extends StateNotifier<ShareholderDirectoryState> {
  ShareholderDirectoryNotifier() : super(const ShareholderDirectoryState());

  Future<void> loadAssetShareholders(String assetId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // In a real app, this would call an API
      await Future.delayed(const Duration(seconds: 1));
      final shareholders = _generateMockShareholders(assetId);
      state = state.copyWith(shareholders: shareholders, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refreshShareholders(String assetId) async {
    await loadAssetShareholders(assetId);
  }

  List<ShareholderInfo> _generateMockShareholders(String assetId) {
    return [
      ShareholderInfo(
        userId: 'user_1',
        email: 'alice.wilson@example.com',
        name: 'Alice Wilson',
        sharesOwned: 1250,
        ownershipPercentage: 31.25,
        purchaseDate: DateTime.now().subtract(const Duration(days: 400)),
      ),
      ShareholderInfo(
        userId: 'user_2',
        email: 'bob.chen@example.com',
        name: 'Bob Chen',
        sharesOwned: 800,
        ownershipPercentage: 20.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 320)),
      ),
      ShareholderInfo(
        userId: 'user_3',
        email: 'carol.davis@example.com',
        name: 'Carol Davis',
        sharesOwned: 600,
        ownershipPercentage: 15.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 280)),
      ),
      ShareholderInfo(
        userId: 'user_4',
        email: 'david.smith@example.com',
        name: 'David Smith',
        sharesOwned: 400,
        ownershipPercentage: 10.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 200)),
      ),
      ShareholderInfo(
        userId: 'user_5',
        email: 'emily.johnson@example.com',
        name: 'Emily Johnson',
        sharesOwned: 350,
        ownershipPercentage: 8.75,
        purchaseDate: DateTime.now().subtract(const Duration(days: 150)),
      ),
      ShareholderInfo(
        userId: 'user_6',
        email: 'frank.brown@example.com',
        name: 'Frank Brown',
        sharesOwned: 300,
        ownershipPercentage: 7.5,
        purchaseDate: DateTime.now().subtract(const Duration(days: 120)),
      ),
      ShareholderInfo(
        userId: 'user_7',
        email: 'grace.lee@example.com',
        name: 'Grace Lee',
        sharesOwned: 200,
        ownershipPercentage: 5.0,
        purchaseDate: DateTime.now().subtract(const Duration(days: 90)),
        isEligibleForRofr: false, // Example of restricted shareholder
      ),
      ShareholderInfo(
        userId: 'user_8',
        email: 'henry.taylor@example.com',
        name: 'Henry Taylor',
        sharesOwned: 100,
        ownershipPercentage: 2.5,
        purchaseDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }
}

// Provider
final shareholderDirectoryProvider = StateNotifierProvider<ShareholderDirectoryNotifier, ShareholderDirectoryState>((ref) {
  return ShareholderDirectoryNotifier();
});