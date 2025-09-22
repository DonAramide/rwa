import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../providers/trading_provider.dart';

class TradingErrorWidget extends StatefulWidget {
  final TradingError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showDetails;

  const TradingErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showDetails = false,
  });

  @override
  State<TradingErrorWidget> createState() => _TradingErrorWidgetState();
}

class _TradingErrorWidgetState extends State<TradingErrorWidget> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getErrorColor(widget.error.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getErrorColor(widget.error.type).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Error Header
          Row(
            children: [
              Icon(
                _getErrorIcon(widget.error.type),
                color: _getErrorColor(widget.error.type),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getErrorTitle(widget.error.type),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: _getErrorColor(widget.error.type),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.error.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.onDismiss != null)
                IconButton(
                  onPressed: widget.onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
            ],
          ),

          // Error Details (if shown)
          if (widget.showDetails && widget.error.details != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Technical Details',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.error.details!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Timestamp
          const SizedBox(height: 12),
          Text(
            'Occurred at ${_formatTimestamp(widget.error.timestamp)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),

          // Action Buttons
          if (widget.error.isRetryable || _getErrorActions(widget.error.type).isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Retry Button
                if (widget.error.isRetryable && widget.onRetry != null)
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onRetry!();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getErrorColor(widget.error.type),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),

                // Context-specific action buttons
                ..._getErrorActions(widget.error.type).map((action) =>
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      action['onPressed']();
                    },
                    icon: Icon(action['icon'], size: 18),
                    label: Text(action['label']),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _getErrorColor(widget.error.type),
                      side: BorderSide(color: _getErrorColor(widget.error.type)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getErrorColor(TradingErrorType type) {
    switch (type) {
      case TradingErrorType.network:
        return Colors.orange;
      case TradingErrorType.validation:
        return Colors.amber;
      case TradingErrorType.insufficientFunds:
        return Colors.red;
      case TradingErrorType.marketClosed:
        return Colors.blue;
      case TradingErrorType.invalidOrder:
        return Colors.purple;
      case TradingErrorType.unauthorized:
        return Colors.red[700]!;
      case TradingErrorType.serverError:
        return Colors.deepOrange;
      case TradingErrorType.timeout:
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getErrorIcon(TradingErrorType type) {
    switch (type) {
      case TradingErrorType.network:
        return Icons.wifi_off;
      case TradingErrorType.validation:
        return Icons.warning;
      case TradingErrorType.insufficientFunds:
        return Icons.account_balance_wallet;
      case TradingErrorType.marketClosed:
        return Icons.access_time;
      case TradingErrorType.invalidOrder:
        return Icons.error_outline;
      case TradingErrorType.unauthorized:
        return Icons.lock;
      case TradingErrorType.serverError:
        return Icons.dns;
      case TradingErrorType.timeout:
        return Icons.timer;
      default:
        return Icons.error;
    }
  }

  String _getErrorTitle(TradingErrorType type) {
    switch (type) {
      case TradingErrorType.network:
        return 'Connection Problem';
      case TradingErrorType.validation:
        return 'Input Validation Error';
      case TradingErrorType.insufficientFunds:
        return 'Insufficient Funds';
      case TradingErrorType.marketClosed:
        return 'Market Closed';
      case TradingErrorType.invalidOrder:
        return 'Invalid Order';
      case TradingErrorType.unauthorized:
        return 'Authentication Required';
      case TradingErrorType.serverError:
        return 'Server Error';
      case TradingErrorType.timeout:
        return 'Request Timeout';
      default:
        return 'Error';
    }
  }

  List<Map<String, dynamic>> _getErrorActions(TradingErrorType type) {
    switch (type) {
      case TradingErrorType.insufficientFunds:
        return [
          {
            'label': 'Add Funds',
            'icon': Icons.add,
            'onPressed': () {
              _showInfoDialog(
                'Add Funds',
                'To add funds to your account, please:\n\n• Navigate to Portfolio\n• Click on "Deposit Funds"\n• Choose your preferred payment method\n• Enter the amount to deposit',
                Icons.account_balance_wallet,
              );
            },
          },
        ];
      case TradingErrorType.marketClosed:
        return [
          {
            'label': 'Market Hours',
            'icon': Icons.schedule,
            'onPressed': () {
              _showInfoDialog(
                'Market Hours',
                'Trading Hours:\n\n• Monday - Friday: 9:30 AM - 4:00 PM EST\n• Markets are closed on weekends and holidays\n• Pre-market: 4:00 AM - 9:30 AM EST\n• After-hours: 4:00 PM - 8:00 PM EST',
                Icons.access_time,
              );
            },
          },
        ];
      case TradingErrorType.unauthorized:
        return [
          {
            'label': 'Login',
            'icon': Icons.login,
            'onPressed': () {
              _showInfoDialog(
                'Authentication Required',
                'Your session has expired. Please:\n\n• Log out and log back in\n• Check your internet connection\n• Ensure your account is active\n• Contact support if the issue persists',
                Icons.lock,
              );
            },
          },
        ];
      default:
        return [];
    }
  }

  void _showInfoDialog(String title, String content, IconData icon) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}

// Compact error banner for showing at the top of trading screens
class TradingErrorBanner extends StatelessWidget {
  final TradingError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const TradingErrorBanner({
    super.key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border(
          bottom: BorderSide(color: Colors.red[200]!),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (error.isRetryable && onRetry != null) ...[
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(color: Colors.red[700]),
              ),
            ),
          ],
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: Colors.red[700], size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
            ),
        ],
      ),
    );
  }
}