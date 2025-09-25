import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/portfolio_provider.dart';

class PortfolioScreen extends ConsumerStatefulWidget {
  const PortfolioScreen({super.key});

  @override
  ConsumerState<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends ConsumerState<PortfolioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(portfolioProvider.notifier).loadPortfolio(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final portfolioState = ref.watch(portfolioProvider);
    final summary = ref.watch(portfolioSummaryProvider);
    final holdings = ref.watch(holdingsProvider);
    final distributions = ref.watch(distributionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/investment-history');
            },
            icon: const Icon(Icons.history),
            tooltip: 'Investment History',
          ),
          IconButton(
            onPressed: () {
              ref.read(portfolioProvider.notifier).refreshPortfolio();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(portfolioState, summary, holdings, distributions),
    );
  }

  Widget _buildBody(
    PortfolioState portfolioState,
    PortfolioSummary? summary,
    List<Holding> holdings,
    List<Distribution> distributions,
  ) {
    if (portfolioState.isLoading && summary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (portfolioState.error != null && summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load portfolio',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              portfolioState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(portfolioProvider.notifier).refreshPortfolio();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(portfolioProvider.notifier).refreshPortfolio();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (summary != null) ...[
              _PortfolioSummary(
                totalValue: summary.totalValue,
                totalReturn: summary.totalReturn,
                monthlyIncome: summary.monthlyIncome,
              ),
              const SizedBox(height: 24),
            ],
            _SectionHeader(
              title: 'Holdings',
              subtitle: 'Your asset investments',
            ),
            const SizedBox(height: 16),
            _HoldingsList(holdings: holdings),
            const SizedBox(height: 24),
            _SectionHeader(
              title: 'Recent Distributions',
              subtitle: 'Latest income payments',
            ),
            const SizedBox(height: 16),
            _DistributionsList(distributions: distributions),
          ],
        ),
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  final double totalValue;
  final double totalReturn;
  final double monthlyIncome;

  const _PortfolioSummary({
    required this.totalValue,
    required this.totalReturn,
    required this.monthlyIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Portfolio Value',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${totalValue.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryItem(
                    label: 'Total Return',
                    value: '${totalReturn.toStringAsFixed(1)}%',
                    color: totalReturn >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                Expanded(
                  child: _SummaryItem(
                    label: 'Monthly Income',
                    value: '\$${monthlyIncome.toStringAsFixed(0)}',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _HoldingsList extends StatelessWidget {
  final List<Holding> holdings;

  const _HoldingsList({required this.holdings});

  @override
  Widget build(BuildContext context) {
    if (holdings.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.account_balance,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No holdings yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Start investing in real-world assets to build your portfolio',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: holdings.map((holding) => _HoldingCard(
        assetName: holding.assetTitle,
        assetType: holding.assetType,
        shares: holding.balance.toInt(),
        value: holding.value,
        returnPercent: holding.returnPercent,
        monthlyIncome: holding.monthlyIncome,
      )).toList(),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  final String assetName;
  final String assetType;
  final int shares;
  final double value;
  final double returnPercent;
  final double monthlyIncome;

  const _HoldingCard({
    required this.assetName,
    required this.assetType,
    required this.shares,
    required this.value,
    required this.returnPercent,
    required this.monthlyIncome,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    assetName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assetType,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _HoldingMetric(
                    label: 'Shares',
                    value: '$shares',
                  ),
                ),
                Expanded(
                  child: _HoldingMetric(
                    label: 'Value',
                    value: '\$${value.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _HoldingMetric(
                    label: 'Return',
                    value: '${returnPercent.toStringAsFixed(1)}%',
                    color: returnPercent >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  size: 16,
                  color: Colors.green[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Monthly Income: \$${monthlyIncome.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoldingMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _HoldingMetric({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DistributionsList extends StatelessWidget {
  final List<Distribution> distributions;

  const _DistributionsList({required this.distributions});

  @override
  Widget build(BuildContext context) {
    if (distributions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.payments,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No distributions yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Income distributions will appear here once you have investments',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: distributions.map((distribution) => _DistributionCard(
        assetName: distribution.assetTitle,
        amount: distribution.amount,
        date: distribution.date,
        status: distribution.status,
      )).toList(),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  final String assetName;
  final double amount;
  final DateTime date;
  final String status;

  const _DistributionCard({
    required this.assetName,
    required this.amount,
    required this.date,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(
            Icons.attach_money,
            color: Colors.green[700],
          ),
        ),
        title: Text(assetName),
        subtitle: Text(
          '${_formatDate(date)} • $status',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          '\$${amount.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}