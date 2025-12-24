import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/leave_provider.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/router/app_router.dart';
import 'widgets/dashboard_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/leave_summary_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateNotifierProvider);
    final user = authState.valueOrNull?.user;
    final employee = user?.employee;

    // Watch notification count for badge
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh all data providers
            await Future.wait([
              ref.read(authStateNotifierProvider.notifier).build(),
              ref.read(leaveNotifierProvider.notifier).refresh(),
              ref.read(notificationNotifierProvider.notifier).refresh(),
            ]);
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                pinned: false,
                backgroundColor: Colors.transparent,
                elevation: 0,
                flexibleSpace: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      // Profile avatar - accessible
                      Semantics(
                        label: 'Profile picture. Tap to view profile',
                        button: true,
                        child: Tooltip(
                          message: 'View Profile',
                          child: InkWell(
                            onTap: () => context.push(AppRoutes.profile),
                            borderRadius: BorderRadius.circular(24),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primary,
                              backgroundImage: employee?.photoUrl != null
                                  ? NetworkImage(employee!.photoUrl!)
                                  : null,
                              child: employee?.photoUrl == null
                                  ? Text(
                                      _getInitials(employee?.fullName ?? 'U'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Greeting
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            Text(
                              employee?.fullName ?? 'User',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Notifications - accessible with dynamic count
                      Semantics(
                        label: unreadCount.when(
                          data: (count) => count > 0
                              ? '$count unread notifications'
                              : 'No unread notifications',
                          loading: () => 'Notifications',
                          error: (_, __) => 'Notifications',
                        ),
                        button: true,
                        child: Tooltip(
                          message: 'View Notifications',
                          child: IconButton(
                            onPressed: () => context.push(AppRoutes.notifications),
                            icon: Badge(
                              isLabelVisible: unreadCount.maybeWhen(
                                data: (count) => count > 0,
                                orElse: () => false,
                              ),
                              label: Text(
                                unreadCount.maybeWhen(
                                  data: (count) => count > 99 ? '99+' : count.toString(),
                                  orElse: () => '0',
                                ),
                              ),
                              child: const Icon(Icons.notifications_outlined),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Quick Actions
                    const QuickActionsWidget(),

                    const SizedBox(height: AppSpacing.xl),

                    // Leave Summary Card
                    const LeaveSummaryCard(),

                    const SizedBox(height: AppSpacing.lg),

                    // Dashboard Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: DashboardCard(
                            title: 'Payslips',
                            icon: Icons.receipt_long_outlined,
                            color: AppColors.success,
                            onTap: () => context.push(AppRoutes.payslipList),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DashboardCard(
                            title: 'Documents',
                            icon: Icons.folder_outlined,
                            color: AppColors.info,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Documents feature coming soon')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Upcoming section
                    Text(
                      'Upcoming',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Upcoming events list
                    _buildUpcomingItem(
                      context,
                      icon: Icons.beach_access,
                      color: AppColors.primary,
                      title: 'Annual Leave',
                      subtitle: 'Dec 28 - Dec 31, 2025',
                      status: 'Approved',
                      statusColor: AppColors.success,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    _buildUpcomingItem(
                      context,
                      icon: Icons.celebration,
                      color: AppColors.warning,
                      title: 'New Year\'s Day',
                      subtitle: 'January 1, 2026',
                      status: 'Public Holiday',
                      statusColor: AppColors.info,
                    ),

                    const SizedBox(height: AppSpacing.xxxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.push(AppRoutes.leaveBalance);
              break;
            case 2:
              context.push(AppRoutes.payslipList);
              break;
            case 3:
              context.push(AppRoutes.profile);
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Leave',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Payslips',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Widget _buildUpcomingItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
