import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flag.dart';
import '../providers/monitoring_provider.dart';

class FlagCard extends ConsumerWidget {
  final Flag flag;

  const FlagCard({
    super.key,
    required this.flag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showFlagDetails(context, flag),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flag.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flag.typeDisplayName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildSeverityChip(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                flag.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatusChip(),
                  const Spacer(),
                  _buildVotingButtons(context, ref),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(flag.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSeverityChip() {
    Color color;
    switch (flag.severity) {
      case FlagSeverity.low:
        color = Colors.green;
        break;
      case FlagSeverity.medium:
        color = Colors.orange;
        break;
      case FlagSeverity.high:
        color = Colors.red;
        break;
      case FlagSeverity.critical:
        color = Colors.red.shade700;
        break;
    }

    return Chip(
      label: Text(
        flag.severityDisplayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    IconData icon;

    switch (flag.status) {
      case FlagStatus.pending:
        color = Colors.grey;
        icon = Icons.schedule;
        break;
      case FlagStatus.underReview:
        color = Colors.blue;
        icon = Icons.search;
        break;
      case FlagStatus.resolved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case FlagStatus.dismissed:
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case FlagStatus.escalated:
        color = Colors.orange;
        icon = Icons.priority_high;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            flag.statusDisplayName,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVotingButtons(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVoteButton(
          context: context,
          ref: ref,
          voteType: VoteType.upvote,
          count: flag.upvotes,
          icon: Icons.thumb_up_outlined,
          activeIcon: Icons.thumb_up,
        ),
        const SizedBox(width: 12),
        _buildVoteButton(
          context: context,
          ref: ref,
          voteType: VoteType.downvote,
          count: flag.downvotes,
          icon: Icons.thumb_down_outlined,
          activeIcon: Icons.thumb_down,
        ),
      ],
    );
  }

  Widget _buildVoteButton({
    required BuildContext context,
    required WidgetRef ref,
    required VoteType voteType,
    required int count,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isUpvote = voteType == VoteType.upvote;
    final color = isUpvote
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.error;

    return InkWell(
      onTap: () => _handleVote(ref, voteType),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleVote(WidgetRef ref, VoteType voteType) async {
    try {
      final service = ref.read(monitoringServiceProvider);
      await service.voteOnFlag(flag.id, voteType);

      // Refresh the flags list
      ref.invalidate(flagsProvider);
      ref.invalidate(myFlagsProvider);
    } catch (e) {
      // Show error snackbar
      // This would need to be implemented with proper context passing
    }
  }

  void _showFlagDetails(BuildContext context, Flag flag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(flag.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', flag.typeDisplayName),
              _buildDetailRow('Severity', flag.severityDisplayName),
              _buildDetailRow('Status', flag.statusDisplayName),
              _buildDetailRow('Created', _formatDateTime(flag.createdAt)),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(flag.description),
              if (flag.evidence != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Evidence:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(flag.evidence.toString()),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.thumb_up, size: 16),
                  const SizedBox(width: 4),
                  Text('${flag.upvotes}'),
                  const SizedBox(width: 16),
                  Icon(Icons.thumb_down, size: 16),
                  const SizedBox(width: 4),
                  Text('${flag.downvotes}'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

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