import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/theme/theme_service.dart';
import '../models/transaction.dart';
import '../providers/transactions_provider.dart';

/// Widget displaying recent transactions
class RecentTransactionsWidget extends ConsumerWidget {
  final bool compact;
  final int? limit;
  final VoidCallback? onViewAll;

  const RecentTransactionsWidget({
    super.key,
    this.compact = false,
    this.limit,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsState = ref.watch(transactionsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    final displayTransactions = limit != null
        ? recentTransactions.take(limit!).toList()
        : recentTransactions;

    if (compact) {
      return _buildCompactView(context, ref, displayTransactions, transactionsState);
    }

    return _buildFullView(context, ref, displayTransactions, transactionsState);
  }

  Widget _buildCompactView(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    TransactionsState state,
  ) {
    if (transactions.isEmpty && !state.isLoading) {
      return const SizedBox.shrink();
    }

    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                if (transactions.length > 3 && onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: Text('View All', style: TextStyle(fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.isLoading)
              Center(child: CircularProgressIndicator())
            else if (transactions.isEmpty)
              Text(
                'No recent transactions',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            else
              ...transactions.take(3).map((transaction) =>
                _buildCompactTransactionItem(context, transaction)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullView(
    BuildContext context,
    WidgetRef ref,
    List<Transaction> transactions,
    TransactionsState state,
  ) {
    return Card(
      color: ThemeService.getCardBackground(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Transactions',
                  style: AppTextStyles.heading3.copyWith(
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(transactionsProvider.notifier).refreshTransactions(),
                  icon: state.isLoading
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(Icons.refresh, size: 20),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('View All'),
                  ),
              ],
            ),

            if (state.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: AppTextStyles.body2.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            if (state.isLoading && transactions.isEmpty)
              Center(child: CircularProgressIndicator())
            else if (transactions.isEmpty)
              _buildEmptyState(context)
            else
              ...transactions.map((transaction) =>
                _buildFullTransactionItem(context, transaction)
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactTransactionItem(BuildContext context, Transaction transaction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: _getTransactionColor(transaction.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ThemeService.getTextPrimary(context),
                  ),
                ),
                Text(
                  transaction.assetTitle,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${transaction.type.isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
            style: AppTextStyles.body2.copyWith(
              color: transaction.type.isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTransactionItem(BuildContext context, Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ThemeService.getContainerBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ThemeService.getBorder(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getTransactionColor(transaction.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getTransactionIcon(transaction.type),
              color: _getTransactionColor(transaction.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      transaction.type.displayName,
                      style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ThemeService.getTextPrimary(context),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${transaction.type.isPositive ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.heading4.copyWith(
                        color: transaction.type.isPositive ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.assetTitle,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      transaction.description,
                      style: AppTextStyles.caption.copyWith(
                        color: ThemeService.getTextSecondary(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(transaction.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        transaction.status.displayName,
                        style: AppTextStyles.caption.copyWith(
                          color: _getStatusColor(transaction.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTimestamp(transaction.timestamp),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No Transactions Yet',
            style: AppTextStyles.heading4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.push('/marketplace'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              'Start Investing',
              style: TextStyle(color: AppColors.textOnPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return AppColors.primary;
      case TransactionType.sale:
        return AppColors.warning;
      case TransactionType.dividendReceived:
        return AppColors.success;
      case TransactionType.deposit:
        return AppColors.info;
      case TransactionType.withdrawal:
        return AppColors.warning;
      case TransactionType.fee:
        return AppColors.error;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Icons.add_shopping_cart;
      case TransactionType.sale:
        return Icons.sell;
      case TransactionType.dividendReceived:
        return Icons.payments;
      case TransactionType.deposit:
        return Icons.arrow_downward;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.fee:
        return Icons.receipt;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return AppColors.warning;
      case TransactionStatus.completed:
        return AppColors.success;
      case TransactionStatus.failed:
        return AppColors.error;
      case TransactionStatus.cancelled:
        return AppColors.textSecondary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

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