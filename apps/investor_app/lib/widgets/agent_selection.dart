import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AgentSelectionDialog extends ConsumerStatefulWidget {
  final String assetId;
  final VoidCallback onAgentSelected;
  final VoidCallback onCancel;

  const AgentSelectionDialog({
    super.key,
    required this.assetId,
    required this.onAgentSelected,
    required this.onCancel,
  });

  @override
  ConsumerState<AgentSelectionDialog> createState() => _AgentSelectionDialogState();
}

class _AgentSelectionDialogState extends ConsumerState<AgentSelectionDialog> {
  String? _selectedAgentId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Verification Agent'),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose an agent to verify this asset investment:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildAgentTile(
                    'agent_1',
                    'John Smith',
                    'Certified Real Estate Agent',
                    '4.8 P (127 reviews)',
                    '\$50/verification',
                  ),
                  _buildAgentTile(
                    'agent_2',
                    'Sarah Johnson',
                    'Property Investment Specialist',
                    '4.9 P (95 reviews)',
                    '\$75/verification',
                  ),
                  _buildAgentTile(
                    'agent_3',
                    'Mike Chen',
                    'Commercial Property Expert',
                    '4.7 P (203 reviews)',
                    '\$60/verification',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.onCancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedAgentId != null ? () {
            widget.onAgentSelected();
          } : null,
          child: const Text('Select Agent'),
        ),
      ],
    );
  }

  Widget _buildAgentTile(String agentId, String name, String title, String rating, String price) {
    final isSelected = _selectedAgentId == agentId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<String>(
        value: agentId,
        groupValue: _selectedAgentId,
        onChanged: (value) {
          setState(() {
            _selectedAgentId = value;
          });
        },
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  rating,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        selected: isSelected,
        activeColor: Theme.of(context).primaryColor,
      ),
    );
  }
}