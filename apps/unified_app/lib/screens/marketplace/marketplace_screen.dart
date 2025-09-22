import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/assets_provider.dart';
import '../../widgets/asset_card.dart';
import '../../widgets/filter_chips.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  String? _selectedType;
  String? _selectedStatus;
  String? _searchQuery;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(assetsProvider.notifier).loadAssets(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query != _searchQuery) {
      setState(() {
        _searchQuery = query.isEmpty ? null : query;
      });
      _applyFilters();
    }
  }

  void _applyFilters() {
    ref.read(assetsProvider.notifier).loadAssets(
      refresh: true,
      type: _selectedType,
      status: _selectedStatus,
      search: _searchQuery?.isNotEmpty == true ? _searchQuery : null,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
      _searchQuery = null;
      _searchController.clear();
    });
    _applyFilters();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      final assetsNotifier = ref.read(assetsProvider.notifier);
      final assetsState = ref.read(assetsProvider);

      if (!assetsState.isLoading && assetsState.hasMore) {
        assetsNotifier.loadAssets();
      }
    }
  }

  String _buildActiveFiltersText() {
    final List<String> activeFilters = [];

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      activeFilters.add('Search: "$_searchQuery"');
    }
    if (_selectedType != null) {
      activeFilters.add('Type: $_selectedType');
    }
    if (_selectedStatus != null) {
      activeFilters.add('Status: $_selectedStatus');
    }

    if (activeFilters.isEmpty) return '';

    return 'Active filters: ${activeFilters.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    final assetsState = ref.watch(assetsProvider);
    final filteredAssets = ref.watch(filteredAssetsProvider);
    final assetTypes = ref.watch(assetTypesProvider);
    final assetStatuses = ref.watch(assetStatusesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Marketplace'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            tooltip: 'Toggle Filters',
          ),
          IconButton(
            onPressed: () {
              ref.read(assetsProvider.notifier).loadAssets(refresh: true);
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Search assets by name or description...',
              value: _searchQuery,
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
                _applyFilters();
              },
            ),
          ),
          
          // Filters Section
          if (_showFilters) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[200]!),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filter header
                      Row(
                        children: [
                          Icon(
                            Icons.filter_list,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter Assets',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const Spacer(),
                          if (_selectedType != null || _selectedStatus != null || _searchQuery != null)
                            TextButton.icon(
                              onPressed: _clearAllFilters,
                              icon: Icon(Icons.clear_all, size: 16, color: Colors.grey[600]),
                              label: Text(
                                'Clear All',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: const Size(0, 32),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter chips layout
                      if (isWideScreen) ...[
                        // Wide screen: side by side
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: FilterChips(
                                label: 'Asset Type',
                                options: assetTypes,
                                selectedValue: _selectedType,
                                onChanged: (type) {
                                  setState(() {
                                    _selectedType = type;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: FilterChips(
                                label: 'Status',
                                options: assetStatuses,
                                selectedValue: _selectedStatus,
                                onChanged: (status) {
                                  setState(() {
                                    _selectedStatus = status;
                                  });
                                  _applyFilters();
                                },
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // Narrow screen: stacked
                        FilterChips(
                          label: 'Asset Type',
                          options: assetTypes,
                          selectedValue: _selectedType,
                          onChanged: (type) {
                            setState(() {
                              _selectedType = type;
                            });
                            _applyFilters();
                          },
                        ),
                        const SizedBox(height: 16),
                        FilterChips(
                          label: 'Status',
                          options: assetStatuses,
                          selectedValue: _selectedStatus,
                          onChanged: (status) {
                            setState(() {
                              _selectedStatus = status;
                            });
                            _applyFilters();
                          },
                        ),
                      ],

                      // Active filters summary
                      if (_selectedType != null || _selectedStatus != null || _searchQuery != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _buildActiveFiltersText(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
          
          // Assets List
          Expanded(
            child: _buildBody(assetsState, filteredAssets),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AssetsState assetsState, List<Asset> filteredAssets) {
    if (assetsState.isLoading && assetsState.assets.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (assetsState.error != null && assetsState.assets.isEmpty) {
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
              'Failed to load assets',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              assetsState.error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(assetsProvider.notifier).loadAssets(refresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (filteredAssets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No assets found',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Try adjusting your filters or check back later',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(assetsProvider.notifier).loadAssets(refresh: true);
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(8.0),
        itemCount: filteredAssets.length + (assetsState.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < filteredAssets.length) {
            return AssetCard(asset: filteredAssets[index]);
          } else {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
    );
  }
}