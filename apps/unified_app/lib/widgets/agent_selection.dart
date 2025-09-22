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
      child: Column(
        children: [
          Row(
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
                      'Choose from Professional Agents and Field Verifiers',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
                tooltip: 'Filter agents',
              ),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFilterChips(),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => _FilterDialog(),
    );
  }

  void _showChatDialog(Agent agent) {
    showDialog(
      context: context,
      builder: (context) => _ChatDialog(agent: agent),
    );
  }

  Widget _buildFilterChips() {
    final agentsState = ref.watch(agentsProvider);
    final hasFilters = agentsState.selectedRegions?.isNotEmpty == true ||
        agentsState.selectedSkills?.isNotEmpty == true ||
        agentsState.minRating != null;

    if (!hasFilters) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      children: [
        if (agentsState.selectedRegions?.isNotEmpty == true)
          ...agentsState.selectedRegions!.map((region) => Chip(
                label: Text(region),
                onDeleted: () {
                  final newRegions = List<String>.from(agentsState.selectedRegions!)
                    ..remove(region);
                  ref.read(agentsProvider.notifier).setFilters(
                        regions: newRegions.isEmpty ? null : newRegions,
                        skills: agentsState.selectedSkills,
                        minRating: agentsState.minRating,
                      );
                  ref.read(agentsProvider.notifier).loadAgents(refresh: true);
                },
              )),
        if (agentsState.selectedSkills?.isNotEmpty == true)
          ...agentsState.selectedSkills!.map((skill) => Chip(
                label: Text(skill),
                onDeleted: () {
                  final newSkills = List<String>.from(agentsState.selectedSkills!)
                    ..remove(skill);
                  ref.read(agentsProvider.notifier).setFilters(
                        regions: agentsState.selectedRegions,
                        skills: newSkills.isEmpty ? null : newSkills,
                        minRating: agentsState.minRating,
                      );
                  ref.read(agentsProvider.notifier).loadAgents(refresh: true);
                },
              )),
        if (agentsState.minRating != null)
          Chip(
            label: Text('${agentsState.minRating}+ stars'),
            onDeleted: () {
              ref.read(agentsProvider.notifier).setFilters(
                    regions: agentsState.selectedRegions,
                    skills: agentsState.selectedSkills,
                    minRating: null,
                  );
              ref.read(agentsProvider.notifier).loadAgents(refresh: true);
            },
          ),
      ],
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
            Text('Both Professional Agents and Field Verifiers are now available!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
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
                  onChat: (agent) => _showChatDialog(agent),
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
}

class _AgentCard extends StatelessWidget {
  final Agent agent;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onSelect;
  final Function(Agent) onChat;

  const _AgentCard({
    required this.agent,
    required this.isSelected,
    required this.isLoading,
    required this.onSelect,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final agentType = agent.skills.any((skill) => skill.toLowerCase().contains('field verification'))
        ? 'Field Verifier'
        : 'Professional Agent';

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
                        Row(
                          children: [
                            Text(
                              agent.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: agent.isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: agent.isOnline ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: agent.isOnline ? Colors.green : Colors.grey,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                agent.isOnline ? 'ONLINE' : 'OFFLINE',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: agent.isOnline ? Colors.green : Colors.grey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          agentType,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (agent.isOnline)
                        IconButton(
                          onPressed: () => onChat(agent),
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          tooltip: 'Chat with ${agent.name}',
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        ),
                      const SizedBox(width: 8),
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

class _FilterDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends ConsumerState<_FilterDialog> {
  late List<String> _selectedRegions;
  late List<String> _selectedSkills;
  late double _minRating;
  bool _showProfessionalAgents = true;
  bool _showFieldVerifiers = true;

  @override
  void initState() {
    super.initState();
    final agentsState = ref.read(agentsProvider);
    _selectedRegions = List.from(agentsState.selectedRegions ?? []);
    _selectedSkills = List.from(agentsState.selectedSkills ?? []);
    _minRating = agentsState.minRating ?? 0.0;
  }

  void _applyFilters() {
    final List<String> skillsFilter = [];

    if (_showProfessionalAgents && !_showFieldVerifiers) {
      skillsFilter.addAll(['Real Estate', 'Automotive', 'Land', 'Industrial', 'Luxury Assets']);
    } else if (_showFieldVerifiers && !_showProfessionalAgents) {
      skillsFilter.add('Field Verification');
    }

    skillsFilter.addAll(_selectedSkills);

    ref.read(agentsProvider.notifier).setFilters(
      regions: _selectedRegions.isEmpty ? null : _selectedRegions,
      skills: skillsFilter.isEmpty ? null : skillsFilter,
      minRating: _minRating > 0 ? _minRating : null,
    );
    ref.read(agentsProvider.notifier).loadAgents(refresh: true);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final availableRegions = ref.watch(availableRegionsProvider);
    final availableSkills = ref.watch(availableSkillsProvider);

    return AlertDialog(
      title: const Text('Filter Agents'),
      content: SizedBox(
        width: 400,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agent Type:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('Professional Agents'),
                value: _showProfessionalAgents,
                onChanged: (value) => setState(() => _showProfessionalAgents = value ?? true),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
              CheckboxListTile(
                title: const Text('Field Verifiers'),
                value: _showFieldVerifiers,
                onChanged: (value) => setState(() => _showFieldVerifiers = value ?? true),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: 16),
              const Text('Regions:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: availableRegions.map((region) {
                    return CheckboxListTile(
                      title: Text(region),
                      value: _selectedRegions.contains(region),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedRegions.add(region);
                          } else {
                            _selectedRegions.remove(region);
                          }
                        });
                      },
                      dense: true,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Skills:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView(
                  children: availableSkills.where((skill) => skill != 'Field Verification').map((skill) {
                    return CheckboxListTile(
                      title: Text(skill),
                      value: _selectedSkills.contains(skill),
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedSkills.add(skill);
                          } else {
                            _selectedSkills.remove(skill);
                          }
                        });
                      },
                      dense: true,
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),
              const Text('Minimum Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Slider(
                value: _minRating,
                min: 0.0,
                max: 5.0,
                divisions: 50,
                label: _minRating > 0 ? '${_minRating.toStringAsFixed(1)} stars' : 'Any rating',
                onChanged: (value) => setState(() => _minRating = value),
              ),
              Text(
                _minRating > 0 ? '${_minRating.toStringAsFixed(1)} stars and above' : 'Any rating',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              _selectedRegions.clear();
              _selectedSkills.clear();
              _minRating = 0.0;
              _showProfessionalAgents = true;
              _showFieldVerifiers = true;
            });
          },
          child: const Text('Clear All'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _applyFilters,
          child: const Text('Apply'),
        ),
      ],
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _FilterOption({
    required this.title,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(title),
      value: isSelected,
      onChanged: (value) => onChanged(value ?? false),
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _ChatDialog extends StatefulWidget {
  final Agent agent;

  const _ChatDialog({required this.agent});

  @override
  State<_ChatDialog> createState() => _ChatDialogState();
}

class _ChatDialogState extends State<_ChatDialog> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: 'Hi! I\'m ${widget.agent.name}. How can I help you with your asset verification needs?',
      isFromAgent: true,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: _messageController.text.trim(),
      isFromAgent: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
    });

    // Simulate agent response
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _getAgentResponse(userMessage.text),
            isFromAgent: true,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });

    _messageController.clear();
    _scrollToBottom();
  }

  String _getAgentResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    if (message.contains('price') || message.contains('cost')) {
      return 'Standard verification starts at \$50 USDC. The exact price depends on asset complexity and location.';
    } else if (message.contains('time') || message.contains('how long')) {
      return 'Most verifications are completed within 24-48 hours. Urgent requests can be prioritized.';
    } else if (message.contains('experience') || message.contains('qualification')) {
      return '${widget.agent.bio} I have ${widget.agent.ratingCount} successful verifications with a ${widget.agent.ratingAvg}/5 rating.';
    } else if (message.contains('location') || message.contains('area')) {
      return 'I operate in: ${widget.agent.regions.join(', ')}. Let me know your asset location!';
    } else {
      return 'Thanks for your question! I specialize in ${widget.agent.skills.take(2).join(' and ')}. Feel free to ask about pricing, timelines, or my experience.';
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
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
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Chat with ${widget.agent.name}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return _MessageBubble(message: message);
                },
              ),
            ),
            // Input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
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

class ChatMessage {
  final String text;
  final bool isFromAgent;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isFromAgent,
    required this.timestamp,
  });
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: message.isFromAgent ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isFromAgent) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isFromAgent ? Colors.grey[100] : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isFromAgent ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
          if (!message.isFromAgent) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_circle, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}