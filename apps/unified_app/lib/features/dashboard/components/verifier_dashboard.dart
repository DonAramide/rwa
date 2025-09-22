import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/asset.dart';
import '../../../data/comprehensive_asset_data.dart';

class VerifierDashboard extends ConsumerStatefulWidget {
  const VerifierDashboard({super.key});

  @override
  ConsumerState<VerifierDashboard> createState() => _VerifierDashboardState();
}

class _VerifierDashboardState extends ConsumerState<VerifierDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Asset> _assets = [];
  List<VerificationTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final allAssetData = ComprehensiveAssetData.getAllAssets();
    setState(() {
      _assets = allAssetData.map((json) => Asset.fromJson(json)).toList();
      _tasks = _generateVerificationTasks();
      _isLoading = false;
    });
  }

  List<VerificationTask> _generateVerificationTasks() {
    return _assets.map((asset) => VerificationTask(
      id: 'VT${asset.id.toString().padLeft(4, '0')}',
      asset: asset,
      type: _getTaskType(asset.type),
      priority: _getTaskPriority(asset.id),
      deadline: DateTime.now().add(Duration(days: 1 + (asset.id % 7))),
      fee: 50 + (asset.id % 150),
      status: _getTaskStatus(asset.id),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifier Dashboard'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Tasks'),
            Tab(icon: Icon(Icons.camera_alt), text: 'Field Work'),
            Tab(icon: Icon(Icons.description), text: 'Reports'),
            Tab(icon: Icon(Icons.leaderboard), text: 'Leaderboard'),
            Tab(icon: Icon(Icons.account_balance_wallet), text: 'Earnings'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTasksTab(),
                _buildFieldWorkTab(),
                _buildReportsTab(),
                _buildLeaderboardTab(),
                _buildEarningsTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildTaskOverview(),
          const SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.info, AppColors.info.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Verifier Dashboard',
                style: AppTextStyles.heading2.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'On-demand verification tasks and field work opportunities.',
            style: AppTextStyles.body1.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'VERIFIED PROFESSIONAL',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'LEVEL 3',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Stats',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Available Tasks',
                '${_tasks.where((t) => t.status == 'Available').length}',
                Icons.assignment,
                AppColors.primary,
                '+5 today',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'In Progress',
                '${_tasks.where((t) => t.status == 'In Progress').length}',
                Icons.work,
                AppColors.warning,
                '2 due today',
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Completed',
                '127',
                Icons.done_all,
                AppColors.success,
                '98.5% accuracy',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'This Week',
                '\$1,240',
                Icons.attach_money,
                AppColors.investment,
                '+\$320',
                true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
    bool isPositive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(
              color: isPositive ? AppColors.success : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    final availableTasks = _tasks.where((task) => task.status == 'Available').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Available Tasks',
                style: AppTextStyles.heading2,
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Task filters coming soon')),
                  );
                },
                icon: const Icon(Icons.filter_list),
                label: const Text('Filter'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTaskFilters(),
          const SizedBox(height: 16),
          ...availableTasks.map((task) => _buildTaskCard(task)),
        ],
      ),
    );
  }

  Widget _buildTaskFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Tasks',
            style: AppTextStyles.heading4,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All Tasks', true),
              _buildFilterChip('High Priority', false),
              _buildFilterChip('Near Me', false),
              _buildFilterChip('High Pay', false),
              _buildFilterChip('Today', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Filter by $label - Coming soon')),
        );
      },
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildTaskCard(VerificationTask task) {
    final priorityColor = _getPriorityColor(task.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAssetIcon(task.asset.type),
                  color: priorityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.asset.title,
                      style: AppTextStyles.heading4,
                    ),
                    Text(
                      '${task.type} • ${task.asset.type.toUpperCase()}',
                      style: AppTextStyles.body2.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  task.priority.toUpperCase(),
                  style: AppTextStyles.caption.copyWith(
                    color: priorityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                task.asset.location?.shortAddress ?? 'Location TBD',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${_formatDeadline(task.deadline)}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Fee: \$${task.fee}',
                style: AppTextStyles.body1.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () => _showTaskDetails(task),
                child: const Text('View Details'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _acceptTask(task),
                child: const Text('Accept'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWorkTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Field Work',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildActiveAssignments(),
          const SizedBox(height: 24),
          _buildFieldWorkTools(),
        ],
      ),
    );
  }

  Widget _buildActiveAssignments() {
    final activeTasks = _tasks.where((task) => task.status == 'In Progress').take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Assignments',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        if (activeTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline.withOpacity(0.2)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.assignment, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('No active assignments', style: AppTextStyles.heading4),
                  const SizedBox(height: 8),
                  Text(
                    'Accept tasks from the Tasks tab to get started',
                    style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...activeTasks.map((task) => _buildActiveAssignmentCard(task)),
      ],
    );
  }

  Widget _buildActiveAssignmentCard(VerificationTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getAssetIcon(task.asset.type),
                  color: AppColors.warning,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.asset.title, style: AppTextStyles.heading4),
                    Text('Due: ${_formatDeadline(task.deadline)}',
                         style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Text('${task.fee}\$', style: AppTextStyles.heading4.copyWith(color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: 0.6, // Progress would be calculated based on completed steps
            backgroundColor: AppColors.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(AppColors.warning),
          ),
          const SizedBox(height: 8),
          Text('60% completed', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openCamera(task),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photos'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _submitReport(task),
                  icon: const Icon(Icons.upload),
                  label: const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldWorkTools() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Field Work Tools',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildToolCard(
                'Camera',
                'Take verification photos',
                Icons.camera_alt,
                AppColors.primary,
                () => _openCameraTool(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToolCard(
                'GPS Location',
                'Record precise location',
                Icons.location_on,
                AppColors.info,
                () => _openLocationTool(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToolCard(
                'Voice Notes',
                'Record audio notes',
                Icons.mic,
                AppColors.warning,
                () => _openVoiceRecorder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToolCard(
                'Checklist',
                'Verification checklist',
                Icons.checklist,
                AppColors.success,
                () => _openChecklist(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToolCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verification Reports',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildReportStats(),
          const SizedBox(height: 24),
          _buildRecentReports(),
        ],
      ),
    );
  }

  Widget _buildReportStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text('127', style: AppTextStyles.heading2.copyWith(color: AppColors.success)),
                    Text('Submitted', style: AppTextStyles.body2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('124', style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                    Text('Approved', style: AppTextStyles.body2),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('98.5%', style: AppTextStyles.heading2.copyWith(color: AppColors.warning)),
                    Text('Accuracy', style: AppTextStyles.body2),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReports() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Reports',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        ...List.generate(8, (index) => _buildReportCard(index)),
      ],
    );
  }

  Widget _buildReportCard(int index) {
    final asset = _assets[index % _assets.length];
    final status = ['Approved', 'Under Review', 'Needs Revision'][index % 3];
    final statusColor = status == 'Approved' ? AppColors.success :
                       status == 'Under Review' ? AppColors.warning : AppColors.error;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getAssetIcon(asset.type), color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                Text('Report #${1000 + index}', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verifier Leaderboard',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildMyRanking(),
          const SizedBox(height: 24),
          _buildTopVerifiers(),
        ],
      ),
    );
  }

  Widget _buildMyRanking() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.emoji_events, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                'Your Ranking',
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#12', style: AppTextStyles.heading1.copyWith(color: Colors.white)),
                    Text('This Month', style: AppTextStyles.body1.copyWith(color: Colors.white.withOpacity(0.9))),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1,850 pts', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
                    Text('Total Score', style: AppTextStyles.body2.copyWith(color: Colors.white.withOpacity(0.8))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopVerifiers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Verifiers This Month',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        ...List.generate(10, (index) => _buildLeaderboardCard(index + 1)),
      ],
    );
  }

  Widget _buildLeaderboardCard(int rank) {
    final names = ['Alex Chen', 'Sarah Johnson', 'Mike Rodriguez', 'Emma Wilson', 'David Kim',
                   'Lisa Zhang', 'John Smith', 'Maya Patel', 'Carlos Lopez', 'Anna Schmidt'];
    final scores = [2450, 2380, 2320, 2280, 2150, 2080, 1950, 1920, 1850, 1780];

    final isMyRank = rank == 10; // User is rank 10 in this example

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMyRank ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMyRank ? AppColors.primary : AppColors.outline.withOpacity(0.2),
          width: isMyRank ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.warning : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: AppTextStyles.body1.copyWith(
                  color: rank <= 3 ? Colors.white : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  names[rank - 1],
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isMyRank ? AppColors.primary : null,
                  ),
                ),
                Text(
                  '${127 - rank} verifications',
                  style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '${scores[rank - 1]} pts',
            style: AppTextStyles.body1.copyWith(
              fontWeight: FontWeight.w600,
              color: isMyRank ? AppColors.primary : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Dashboard',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 16),
          _buildEarningsOverview(),
          const SizedBox(height: 24),
          _buildEarningsChart(),
          const SizedBox(height: 24),
          _buildRecentPayments(),
        ],
      ),
    );
  }

  Widget _buildEarningsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Earnings',
            style: AppTextStyles.body1.copyWith(color: Colors.white.withOpacity(0.9)),
          ),
          const SizedBox(height: 8),
          Text(
            '\$3,280.00',
            style: AppTextStyles.heading1.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This Month', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                    Text('\$1,240', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                    Text('\$320', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Avg/Task', style: AppTextStyles.caption.copyWith(color: Colors.white.withOpacity(0.8))),
                    Text('\$75', style: AppTextStyles.heading4.copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart, size: 64, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Earnings Chart', style: AppTextStyles.heading4),
            const SizedBox(height: 8),
            Text(
              'Weekly and monthly earnings visualization coming soon',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Payments',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        ...List.generate(10, (index) => _buildPaymentCard(index)),
      ],
    );
  }

  Widget _buildPaymentCard(int index) {
    final amount = [125, 85, 95, 110, 75, 140, 65, 90, 105, 80][index % 10];
    final date = DateTime.now().subtract(Duration(days: index * 2));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.payment, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verification Task #VT${(1000 + index).toString().padLeft(4, '0')}',
                     style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                Text('${date.day}/${date.month}/${date.year}',
                     style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text('\$${amount}', style: AppTextStyles.heading4.copyWith(color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _buildTaskOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Overview',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard('Property Verification', '8 available', Icons.home, AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTaskTypeCard('Document Review', '3 available', Icons.description, AppColors.info),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTaskTypeCard('Site Inspection', '5 available', Icons.location_on, AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTaskTypeCard('Compliance Check', '2 available', Icons.verified, AppColors.success),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTaskTypeCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(count, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        ...List.generate(5, (index) => _buildActivityCard(index)),
      ],
    );
  }

  Widget _buildActivityCard(int index) {
    final activities = [
      'Completed verification for Premium Office Complex',
      'Submitted report for Luxury Villa in Manhattan',
      'Started inspection of Commercial Warehouse',
      'Earned \$125 for Gold Investment verification',
      'Ranked up to Level 3 Verifier'
    ];

    final icons = [Icons.done_all, Icons.upload, Icons.work, Icons.attach_money, Icons.star];
    final colors = [AppColors.success, AppColors.info, AppColors.warning, AppColors.investment, AppColors.primary];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors[index].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icons[index], color: colors[index], size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activities[index], style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
                Text('${index + 1} hour${index == 0 ? '' : 's'} ago', style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTaskType(String assetType) {
    switch (assetType) {
      case 'house':
      case 'apartment':
      case 'commercial':
      case 'hotel':
        return 'Property Verification';
      case 'car':
      case 'bus':
      case 'truck':
        return 'Vehicle Inspection';
      case 'gold':
      case 'silver':
      case 'diamond':
        return 'Asset Authentication';
      default:
        return 'Document Review';
    }
  }

  String _getTaskPriority(int id) {
    final priorities = ['High', 'Medium', 'Low'];
    return priorities[id % priorities.length];
  }

  String _getTaskStatus(int id) {
    final statuses = ['Available', 'In Progress', 'Completed'];
    return statuses[id % statuses.length];
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High': return AppColors.error;
      case 'Medium': return AppColors.warning;
      case 'Low': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  IconData _getAssetIcon(String type) {
    switch (type) {
      case 'house': return Icons.house;
      case 'apartment': return Icons.apartment;
      case 'commercial': return Icons.business;
      case 'hotel': return Icons.hotel;
      case 'warehouse': return Icons.warehouse;
      case 'car': return Icons.directions_car;
      case 'gold': return Icons.star;
      case 'shares': return Icons.trending_up;
      case 'solar': return Icons.solar_power;
      default: return Icons.business;
    }
  }

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else {
      return 'Due now';
    }
  }

  // Action methods
  void _showTaskDetails(VerificationTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Task Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Asset: ${task.asset.title}', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('Type: ${task.type}', style: AppTextStyles.body2),
              Text('Priority: ${task.priority}', style: AppTextStyles.body2),
              Text('Fee: \$${task.fee}', style: AppTextStyles.body2),
              Text('Deadline: ${_formatDeadline(task.deadline)}', style: AppTextStyles.body2),
              Text('Location: ${task.asset.location?.fullAddress ?? 'TBD'}', style: AppTextStyles.body2),
              const SizedBox(height: 16),
              Text('Required Tasks:', style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('• Physical site inspection', style: AppTextStyles.body2),
              Text('• Photo documentation (min 10 photos)', style: AppTextStyles.body2),
              Text('• GPS location verification', style: AppTextStyles.body2),
              Text('• Condition assessment report', style: AppTextStyles.body2),
              Text('• Compliance checklist completion', style: AppTextStyles.body2),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _acceptTask(task);
            },
            child: const Text('Accept Task'),
          ),
        ],
      ),
    );
  }

  void _acceptTask(VerificationTask task) {
    setState(() {
      task.status = 'In Progress';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task accepted: ${task.asset.title}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openCamera(VerificationTask task) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera integration coming soon')),
    );
  }

  void _submitReport(VerificationTask task) {
    setState(() {
      task.status = 'Completed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Report submitted for ${task.asset.title}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _openCameraTool() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera tool - Integration coming soon')),
    );
  }

  void _openLocationTool() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GPS location tool - Integration coming soon')),
    );
  }

  void _openVoiceRecorder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Voice recorder - Integration coming soon')),
    );
  }

  void _openChecklist() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verification checklist - Integration coming soon')),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Helper class for verification tasks
class VerificationTask {
  final String id;
  final Asset asset;
  final String type;
  final String priority;
  final DateTime deadline;
  final int fee;
  String status;

  VerificationTask({
    required this.id,
    required this.asset,
    required this.type,
    required this.priority,
    required this.deadline,
    required this.fee,
    required this.status,
  });
}