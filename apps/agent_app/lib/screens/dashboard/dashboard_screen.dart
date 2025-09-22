import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/agent_provider.dart';
import '../../providers/jobs_provider.dart';
import '../../widgets/job_card.dart';
import '../../widgets/stats_card.dart';
import '../../widgets/quick_actions.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentProvider.notifier).loadProfile();
      ref.read(jobsProvider.notifier).loadAvailableJobs();
      ref.read(jobsProvider.notifier).loadMyJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final agentState = ref.watch(agentProvider);
    final jobsState = ref.watch(jobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agent Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            ref.read(agentProvider.notifier).loadProfile(),
            ref.read(jobsProvider.notifier).loadAvailableJobs(),
            ref.read(jobsProvider.notifier).loadMyJobs(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              if (agentState.agent != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: Text(
                                agentState.agent!.id.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome, Agent ${agentState.agent!.id}',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        agentState.agent!.isApproved 
                                          ? Icons.verified 
                                          : Icons.pending,
                                        size: 16,
                                        color: agentState.agent!.isApproved 
                                          ? Colors.green 
                                          : Colors.orange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        agentState.agent!.status.toUpperCase(),
                                        style: TextStyle(
                                          color: agentState.agent!.isApproved 
                                            ? Colors.green 
                                            : Colors.orange,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (agentState.agent!.ratingCount > 0) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, size: 16, color: Colors.amber),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${agentState.agent!.ratingAvg.toStringAsFixed(1)} (${agentState.agent!.ratingCount} reviews)',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Stats cards
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Active Jobs',
                      value: jobsState.activeJobs.length.toString(),
                      icon: Icons.work,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      title: 'Available',
                      value: jobsState.availableJobs.length.toString(),
                      icon: Icons.business,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'This Month',
                      value: '\$${jobsState.monthlyEarnings.toStringAsFixed(0)}',
                      icon: Icons.account_balance_wallet,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatsCard(
                      title: 'Completed',
                      value: jobsState.completedJobs.length.toString(),
                      icon: Icons.check_circle,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              const QuickActions(),
              const SizedBox(height: 24),

              // Active Jobs Section
              if (jobsState.activeJobs.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Active Jobs',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/jobs?filter=active'),
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...jobsState.activeJobs.take(3).map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(job: job),
                )),
                const SizedBox(height: 24),
              ],

              // Available Jobs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Job Marketplace',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/jobs?filter=available'),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (jobsState.isLoading && jobsState.availableJobs.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (jobsState.availableJobs.isEmpty)
                const Center(
                  child: Text(
                    'No jobs available at the moment',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...jobsState.availableJobs.take(5).map((job) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: JobCard(job: job),
                )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on dashboard
              break;
            case 1:
              context.push('/jobs');
              break;
            case 2:
              context.push('/earnings');
              break;
            case 3:
              context.push('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Earnings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}