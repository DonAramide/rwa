import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/investment_history_provider.dart';

class InvestmentHistoryScreen extends ConsumerStatefulWidget {
  const InvestmentHistoryScreen({super.key});

  @override
  ConsumerState<InvestmentHistoryScreen> createState() => _InvestmentHistoryScreenState();
}

class _InvestmentHistoryScreenState extends ConsumerState<InvestmentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(investmentHistoryProvider.notifier).loadInvestmentHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(investmentHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment History'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(investmentHistoryProvider.notifier).refreshHistory();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(historyState),
    );
  }

  Widget _buildBody(InvestmentHistoryState state) {
    if (state.isLoading && state.investments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.investments.isEmpty) {
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
              'Failed to load investment history',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(investmentHistoryProvider.notifier).refreshHistory();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.investments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Investment History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your investment transactions will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(investmentHistoryProvider.notifier).refreshHistory();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: state.investments.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.investments.length) {
            if (state.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            } else {
              ref.read(investmentHistoryProvider.notifier).loadMoreHistory();
              return const SizedBox.shrink();
            }
          }

          final investment = state.investments[index];
          return _InvestmentCard(investment: investment);
        },
      ),
    );
  }
}

class _InvestmentCard extends StatelessWidget {
  final Investment investment;

  const _InvestmentCard({required this.investment});

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
                    investment.assetTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _StatusChip(status: investment.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InvestmentMetric(
                    label: 'Amount',
                    value: '\$${investment.amount.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _InvestmentMetric(
                    label: 'Shares',
                    value: investment.shares?.toStringAsFixed(2) ?? 'Pending',
                  ),
                ),
                Expanded(
                  child: _InvestmentMetric(
                    label: 'Price per Share',
                    value: investment.pricePerShare != null
                        ? '\$${investment.pricePerShare!.toStringAsFixed(2)}'
                        : 'Pending',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(investment.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (investment.transactionHash != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Transaction Hash: ${investment.transactionHash}'),
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () {
                              // TODO: Implement clipboard copy
                            },
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View TX',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
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
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'completed':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green[700]!;
        break;
      case 'pending':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange[700]!;
        break;
      case 'failed':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red[700]!;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InvestmentMetric extends StatelessWidget {
  final String label;
  final String value;

  const _InvestmentMetric({
    required this.label,
    required this.value,
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
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}