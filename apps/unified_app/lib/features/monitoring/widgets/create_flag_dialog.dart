import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/flag.dart';
import '../providers/monitoring_provider.dart';

class CreateFlagDialog extends ConsumerStatefulWidget {
  final int? assetId;

  const CreateFlagDialog({
    super.key,
    this.assetId,
  });

  @override
  ConsumerState<CreateFlagDialog> createState() => _CreateFlagDialogState();
}

class _CreateFlagDialogState extends ConsumerState<CreateFlagDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _assetIdController = TextEditingController();

  FlagType _selectedType = FlagType.other;
  FlagSeverity _selectedSeverity = FlagSeverity.medium;
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    if (widget.assetId != null) {
      _assetIdController.text = widget.assetId.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _assetIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(createFlagProvider, (previous, next) {
      next.whenOrNull(
        data: (flag) {
          if (flag != null) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Flag created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            ref.read(createFlagProvider.notifier).reset();
            // Refresh flags list
            ref.invalidate(flagsProvider);
            ref.invalidate(myFlagsProvider);
          }
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating flag: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    final createFlagState = ref.watch(createFlagProvider);

    return AlertDialog(
      title: const Text('Report an Issue'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _assetIdController,
                  decoration: const InputDecoration(
                    labelText: 'Asset ID',
                    hintText: 'Enter the asset ID you want to flag',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an asset ID';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid asset ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FlagType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Issue Type',
                    border: OutlineInputBorder(),
                  ),
                  items: FlagType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getTypeDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<FlagSeverity>(
                  value: _selectedSeverity,
                  decoration: const InputDecoration(
                    labelText: 'Severity',
                    border: OutlineInputBorder(),
                  ),
                  items: FlagSeverity.values.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getSeverityColor(severity),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(_getSeverityDisplayName(severity)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedSeverity = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Brief description of the issue',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.length < 5) {
                      return 'Title must be at least 5 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Detailed description of the issue',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    if (value.length < 20) {
                      return 'Description must be at least 20 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: _isAnonymous,
                  onChanged: (value) {
                    setState(() => _isAnonymous = value ?? false);
                  },
                  title: const Text('Submit anonymously'),
                  subtitle: const Text('Your identity will not be revealed'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your flag will be reviewed by other investor-agents and platform administrators.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: createFlagState.isLoading
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: createFlagState.isLoading ? null : _submitFlag,
          child: createFlagState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Flag'),
        ),
      ],
    );
  }

  void _submitFlag() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final request = CreateFlagRequest(
      assetId: int.parse(_assetIdController.text),
      type: _selectedType,
      severity: _selectedSeverity,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isAnonymous: _isAnonymous,
    );

    ref.read(createFlagProvider.notifier).createFlag(request);
  }

  String _getTypeDisplayName(FlagType type) {
    switch (type) {
      case FlagType.suspiciousActivity:
        return 'Suspicious Activity';
      case FlagType.documentDiscrepancy:
        return 'Document Issue';
      case FlagType.financialIrregularity:
        return 'Financial Issue';
      case FlagType.milestoneDelay:
        return 'Milestone Delay';
      case FlagType.communicationIssue:
        return 'Communication Problem';
      case FlagType.legalConcern:
        return 'Legal Concern';
      case FlagType.other:
        return 'Other';
    }
  }

  String _getSeverityDisplayName(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return 'Low Priority';
      case FlagSeverity.medium:
        return 'Medium Priority';
      case FlagSeverity.high:
        return 'High Priority';
      case FlagSeverity.critical:
        return 'Critical';
    }
  }

  Color _getSeverityColor(FlagSeverity severity) {
    switch (severity) {
      case FlagSeverity.low:
        return Colors.green;
      case FlagSeverity.medium:
        return Colors.orange;
      case FlagSeverity.high:
        return Colors.red;
      case FlagSeverity.critical:
        return Colors.red.shade700;
    }
  }
}