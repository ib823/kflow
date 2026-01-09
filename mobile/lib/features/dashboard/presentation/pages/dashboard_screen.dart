import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Main dashboard/home screen
class DashboardScreen extends StatefulWidget {
  final VoidCallback? onPayslipTap;
  final VoidCallback? onLeaveTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const DashboardScreen({
    super.key,
    this.onPayslipTap,
    this.onLeaveTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  // Mock data
  final String _userName = 'Ahmad Bin Mohd';
  final int _leaveBalance = 12;
  final int _notificationCount = 3;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingState() : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return KFAppBar(
      title: 'KerjaFlow',
      showLogo: true,
      actions: [
        // Notification badge
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: widget.onNotificationTap,
            ),
            if (_notificationCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: KFBadge(
                  count: _notificationCount,
                  size: BadgeSize.small,
                ),
              ),
          ],
        ),
        // Profile avatar
        Padding(
          padding: const EdgeInsets.only(right: KFSpacing.space2),
          child: GestureDetector(
            onTap: widget.onProfileTap,
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: KFColors.primary100,
              child: Icon(
                Icons.person,
                size: 20,
                color: KFColors.primary600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting skeleton
          const KFSkeleton(width: 200, height: 32),
          const SizedBox(height: KFSpacing.space2),
          const KFSkeleton(width: 160, height: 20),
          const SizedBox(height: KFSpacing.space6),
          // Leave balance skeleton
          const KFSkeletonCard(),
          const SizedBox(height: KFSpacing.space4),
          // Payslip card skeleton
          const KFSkeletonCard(height: 100),
          const SizedBox(height: KFSpacing.space6),
          // Section header skeleton
          const KFSkeleton(width: 120, height: 24),
          const SizedBox(height: KFSpacing.space3),
          const KFSkeletonListItem(),
          const KFSkeletonListItem(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return KFErrorState(
        message: _errorMessage!,
        onRetry: _loadData,
      );
    }

    return KFRefreshable(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreeting(),
            const SizedBox(height: KFSpacing.space6),
            _buildLeaveBalanceCard(),
            const SizedBox(height: KFSpacing.space4),
            _buildLatestPayslipCard(),
            const SizedBox(height: KFSpacing.space6),
            _buildRecentLeaveSection(),
            const SizedBox(height: KFSpacing.space6),
            _buildUpcomingHolidaySection(),
            const SizedBox(height: KFSpacing.space6),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()},',
                    style: const TextStyle(
                      fontSize: KFTypography.fontSize2xl,
                      fontWeight: KFTypography.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          '$_userName ',
                          style: const TextStyle(
                            fontSize: KFTypography.fontSize2xl,
                            fontWeight: KFTypography.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text('👋', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KFSpacing.space1),
        Text(
          '${dayNames[now.weekday - 1]}, ${now.day} ${monthNames[now.month - 1]} ${now.year}',
          style: const TextStyle(
            fontSize: KFTypography.fontSizeBase,
            color: KFColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveBalanceCard() {
    return KFLeaveBalanceCard(
      title: 'Leave Balance',
      balance: _leaveBalance,
      unit: 'days',
      onTap: widget.onLeaveTap,
      color: KFColors.primary600,
    );
  }

  Widget _buildLatestPayslipCard() {
    return KFPayslipCard(
      month: 'December',
      year: 2025,
      netAmount: 4422.00,
      currency: 'RM',
      isNew: true,
      onTap: widget.onPayslipTap,
    );
  }

  Widget _buildRecentLeaveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KFSectionHeader(
          title: 'Recent Leave',
          actionLabel: 'View All',
          onAction: widget.onLeaveTap,
        ),
        const SizedBox(height: KFSpacing.space3),
        _buildLeaveItem(
          icon: Icons.beach_access,
          iconColor: KFColors.success600,
          type: 'Annual',
          dateRange: '2-3 Jan',
          status: StatusType.approved,
        ),
        const SizedBox(height: KFSpacing.space2),
        _buildLeaveItem(
          icon: Icons.local_hospital,
          iconColor: KFColors.error500,
          type: 'Medical',
          dateRange: '27 Dec',
          status: StatusType.approved,
        ),
      ],
    );
  }

  Widget _buildLeaveItem({
    required IconData icon,
    required Color iconColor,
    required String type,
    required String dateRange,
    required StatusType status,
  }) {
    return KFListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: KFRadius.radiusMd,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: type,
      subtitle: dateRange,
      trailing: KFStatusChip(
        label: status.name,
        type: status,
        size: ChipSize.small,
      ),
      onTap: widget.onLeaveTap,
    );
  }

  Widget _buildUpcomingHolidaySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KFSectionHeader(title: 'Upcoming Holiday'),
        const SizedBox(height: KFSpacing.space3),
        KFCard(
          child: Padding(
            padding: const EdgeInsets.all(KFSpacing.space4),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: KFColors.secondary100,
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.celebration,
                    color: KFColors.secondary600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: KFSpacing.space4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Thaipusam',
                        style: TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          fontWeight: KFTypography.semiBold,
                        ),
                      ),
                      SizedBox(height: KFSpacing.space1),
                      Text(
                        '29 January 2026',
                        style: TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          color: KFColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KFSpacing.space3,
                    vertical: KFSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: KFColors.info100,
                    borderRadius: KFRadius.radiusFull,
                  ),
                  child: const Text(
                    '20 days',
                    style: TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.info700,
                      fontWeight: KFTypography.medium,
                    ),
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
