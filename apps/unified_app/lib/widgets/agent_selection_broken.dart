import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/agents_provider.dart';

class AgentSelectionDialog extends ConsumerStatefulWidget {
  final String assetId;
  final VoidCallback? onAgentSelected;
  final VoidCallback? onCancel;

  const AgentSelectionDialog({
    super.key,
    required this.assetId,
    this.onAgentSelected,
    this.onCancel,
  });

  @override
  ConsumerState<AgentSelectionDialog> createState() => _AgentSelectionDialogState();
}

class _AgentSelectionDialogState extends ConsumerState<AgentSelectionDialog> {
  final _scrollController = ScrollController();
  Agent? _selectedAgent;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentsProvider.notifier).loadAgents(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final agentsNotifier = ref.read(agentsProvider.notifier);
      final agentsState = ref.read(agentsProvider);
      
      if (!agentsState.isLoading && agentsState.hasMore) {
        agentsNotifier.loadAgents();
      }
    }
  }

  Future<void> _selectAgent(Agent agent) async {
    setState(() {
      _selectedAgent = agent;
      _isLoading = true;
      _error = null;
    });

    try {
      // Create verification job
      await ref.read(agentsProvider.notifier).createVerificationJob(
        assetId: widget.assetId,
        agentId: agent.id,
        price: 50.0, // Standard verification fee
        currency: 'USDC',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification job created with ${agent.bio.split(' ').take(3).join(' ')}'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAgentSelected?.call();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final agentsState = ref.watch(agentsProvider);
    final filteredAgents = ref.watch(filteredAgentsProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: _buildContent(agentsState, filteredAgents),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Verification Agent',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a professional agent to verify this asset',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AgentsState agentsState, List<Agent> filteredAgents) {
    if (agentsState.isLoading && agentsState.agents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (agentsState.error != null && agentsState.agents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Failed to load agents', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(agentsState.error!, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(agentsProvider.notifier).loadAgents(refresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredAgents.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No agents found', style: TextStyle(fontSize: 18)),
            SizedBox(height: 8),
            Text('Try adjusting your filters', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filters
        _buildFilters(),
        
        // Agents List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredAgents.length + (agentsState.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < filteredAgents.length) {
                return _AgentCard(
                  agent: filteredAgents[index],
                  isSelected: _selectedAgent?.id == filteredAgents[index].id,
                  isLoading: _isLoading && _selectedAgent?.id == filteredAgents[index].id,
                  onSelect: () => _selectAgent(filteredAgents[index]),
                );
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),

        // Error Message
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Agent filtering now includes Field Verifiers!')),
                );
              },
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text('Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[700],
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              ref.read(agentsProvider.notifier).loadAgents(refresh: true);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  String _getAgentType(Agent agent) {
    if (agent.skills.any((skill) => skill.toLowerCase().contains('field verification'))) {
      return 'Field Verifier';
    }
    return 'Professional Agent';
  }

  void _showFilterDialog() {
    final agentsState = ref.read(agentsProvider);
    final availableRegions = ref.read(availableRegionsProvider);
    final availableSkills = ref.read(availableSkillsProvider);

    showDialog(
      context: context,
      builder: (context) => _FilterDialog(
        selectedRegions: agentsState.selectedRegions ?? [],
        selectedSkills: agentsState.selectedSkills ?? [],
        minRating: agentsState.minRating,
        availableRegions: availableRegions,
        availableSkills: availableSkills,
        onApply: (regions, skills, rating) {
          ref.read(agentsProvider.notifier).setFilters(
            regions: regions.isEmpty ? null : regions,
            skills: skills.isEmpty ? null : skills,
            minRating: rating,
          );
          ref.read(agentsProvider.notifier).loadAgents(refresh: true);
        },
        onClear: () {
          ref.read(agentsProvider.notifier).clearFilters();
          ref.read(agentsProvider.notifier).loadAgents(refresh: true);
        },
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final Agent agent;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onSelect;

  const _AgentCard({
    required this.agent,
    required this.isSelected,
    required this.isLoading,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: InkWell(
        onTap: isLoading ? null : onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          agent.skills.any((skill) => skill.toLowerCase().contains('field verification'))
                            ? 'Field Verifier'
                            : 'Professional Agent',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          agent.bio,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  _RatingDisplay(rating: agent.ratingAvg, count: agent.ratingCount),
                  const SizedBox(width: 16),
                  _StatusChip(status: agent.status),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _RegionsDisplay(regions: agent.regions),
                  ),
                  const SizedBox(width: 16),
                  _PriceDisplay(price: 50.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _RatingDisplay extends StatelessWidget {
  final double rating;
  final int count;

  const _RatingDisplay({
    required this.rating,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: Colors.amber[600],
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($count)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'suspended':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _RegionsDisplay extends StatelessWidget {
  final List<String> regions;

  const _RegionsDisplay({required this.regions});

  @override
  Widget build(BuildContext context) {
    if (regions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: regions.take(3).map((region) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Text(
            region,
            style: TextStyle(
              color: Colors.blue[700],
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final double price;

  const _PriceDisplay({required this.price});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '\$${price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        Text(
          'Verification Fee',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

}

class _FilterDialog extends StatefulWidget {
  final List<String> selectedRegions;
  final List<String> selectedSkills;
  final double? minRating;
  final List<String> availableRegions;
  final List<String> availableSkills;
  final Function(List<String>, List<String>, double?) onApply;
  final VoidCallback onClear;

  const _FilterDialog({
    required this.selectedRegions,
    required this.selectedSkills,
    required this.minRating,
    required this.availableRegions,
    required this.availableSkills,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late List<String> _selectedRegions;
  late List<String> _selectedSkills;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _selectedRegions = List.from(widget.selectedRegions);
    _selectedSkills = List.from(widget.selectedSkills);
    _minRating = widget.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter Agents',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableRegions.map((region) {
                        final isSelected = _selectedRegions.contains(region);
                        return FilterChip(
                          label: Text(region),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedRegions.add(region);
                              } else {
                                _selectedRegions.remove(region);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Skills',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.availableSkills.map((skill) {
                        final isSelected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSkills.add(skill);
                              } else {
                                _selectedSkills.remove(skill);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: _minRating ?? 0.0,
                      min: 0.0,
                      max: 5.0,
                      divisions: 10,
                      label: _minRating?.toStringAsFixed(1) ?? '0.0',
                      onChanged: (value) {
                        setState(() {
                          _minRating = value == 0.0 ? null : value;
                        });
                      },
                    ),
                    Text(
                      _minRating != null
                        ? '${_minRating!.toStringAsFixed(1)} stars and above'
                        : 'No minimum rating',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      widget.onClear();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Clear All'),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onApply(_selectedRegions, _selectedSkills, _minRating);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

