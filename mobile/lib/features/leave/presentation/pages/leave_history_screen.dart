import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Leave history screen showing all past leave applications
class LeaveHistoryScreen extends StatefulWidget {
  final void Function(String leaveId)? onLeaveTap;

  const LeaveHistoryScreen({
    super.key,
    this.onLeaveTap,
  });

  @override
  State<LeaveHistoryScreen> createState() => _LeaveHistoryScreenState();
}

class _LeaveHistoryScreenState extends State<LeaveHistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_LeaveHistoryItem> _leaveHistory = [];
  String _selectedFilter = 'all';

  final List<_FilterOption> _filters = [
    _FilterOption('all', 'All'),
    _FilterOption('pending', 'Pending'),
    _FilterOption('approved', 'Approved'),
    _FilterOption('rejected', 'Rejected'),
  ];

  @override
  void initState() {
    super.initState();
    _loadLeaveHistory();
  }

  Future<void> _loadLeaveHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _leaveHistory = _getMockLeaveHistory();
      });
    }
  }

  List<_LeaveHistoryItem> _getMockLeaveHistory() {
    final allItems = [
      _LeaveHistoryItem(
        id: 'leave-001',
        type: 'Annual Leave',
        typeIcon: Icons.beach_access,
        typeColor: KFColors.primary600,
        startDate: DateTime(2026, 1, 2),
        endDate: DateTime(2026, 1, 3),
        days: 2,
        status: StatusType.approved,
        appliedDate: DateTime(2025, 12, 20),
        approver: 'Mohd Razak',
      ),
      _LeaveHistoryItem(
        id: 'leave-002',
        type: 'Medical Leave',
        typeIcon: Icons.local_hospital,
        typeColor: KFColors.error500,
        startDate: DateTime(2025, 12, 27),
        endDate: DateTime(2025, 12, 27),
        days: 1,
        status: StatusType.approved,
        appliedDate: DateTime(2025, 12, 27),
        approver: 'Mohd Razak',
      ),
      _LeaveHistoryItem(
        id: 'leave-003',
        type: 'Annual Leave',
        typeIcon: Icons.beach_access,
        typeColor: KFColors.primary600,
        startDate: DateTime(2025, 12, 15),
        endDate: DateTime(2025, 12, 15),
        days: 0.5,
        status: StatusType.rejected,
        appliedDate: DateTime(2025, 12, 10),
        approver: 'Mohd Razak',
        rejectionReason: 'Team event scheduled on this date',
      ),
      _LeaveHistoryItem(
        id: 'leave-004',
        type: 'Annual Leave',
        typeIcon: Icons.beach_access,
        typeColor: KFColors.primary600,
        startDate: DateTime(2026, 2, 10),
        endDate: DateTime(2026, 2, 14),
        days: 5,
        status: StatusType.pending,
        appliedDate: DateTime(2026, 1, 5),
      ),
    ];

    if (_selectedFilter == 'all') {
      return allItems;
    }

    final statusMap = {
      'pending': StatusType.pending,
      'approved': StatusType.approved,
      'rejected': StatusType.rejected,
    };

    return allItems
        .where((item) => item.status == statusMap[_selectedFilter])
        .toList();
  }

  Future<void> _onRefresh() async {
    await _loadLeaveHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Leave History'),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _leaveHistory.isEmpty
                        ? _buildEmptyState()
                        : _buildHistoryList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KFSpacing.space4,
        vertical: KFSpacing.space3,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: KFColors.gray200),
        ),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = filter.id == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: KFSpacing.space2),
            child: Material(
              color: isSelected ? KFColors.primary600 : KFColors.gray100,
              borderRadius: KFRadius.radiusFull,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedFilter = filter.id);
                  _loadLeaveHistory();
                },
                borderRadius: KFRadius.radiusFull,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KFSpacing.space4,
                    vertical: KFSpacing.space2,
                  ),
                  child: Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      fontWeight: KFTypography.medium,
                      color: isSelected ? KFColors.white : KFColors.gray700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: KFSpacing.screenPadding,
      itemCount: 4,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: KFSpacing.space4),
          child: KFSkeletonCard(height: 100),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadLeaveHistory,
    );
  }

  Widget _buildEmptyState() {
    return const KFEmptyState(
      icon: Icons.history,
      title: 'No Leave History',
      message: 'No leave applications found with the selected filter.',
    );
  }

  Widget _buildHistoryList() {
    return KFRefreshable(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: KFSpacing.screenPadding,
        itemCount: _leaveHistory.length,
        itemBuilder: (context, index) {
          final item = _leaveHistory[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: KFSpacing.space3),
            child: _buildHistoryCard(item),
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard(_LeaveHistoryItem item) {
    return KFCard(
      onTap: () => widget.onLeaveTap?.call(item.id),
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: item.typeColor.withOpacity(0.1),
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Icon(item.typeIcon, color: item.typeColor, size: 20),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          fontWeight: KFTypography.semiBold,
                        ),
                      ),
                      const SizedBox(height: KFSpacing.space1),
                      Text(
                        _formatDateRange(item.startDate, item.endDate),
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          color: KFColors.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    KFStatusChip(
                      label: _getStatusLabel(item.status),
                      type: item.status,
                      size: ChipSize.small,
                    ),
                    const SizedBox(height: KFSpacing.space1),
                    Text(
                      '${item.days} ${item.days == 1 || item.days == 0.5 ? 'day' : 'days'}',
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeSm,
                        fontWeight: KFTypography.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (item.status == StatusType.rejected &&
                item.rejectionReason != null) ...[
              const SizedBox(height: KFSpacing.space3),
              Container(
                padding: const EdgeInsets.all(KFSpacing.space3),
                decoration: BoxDecoration(
                  color: KFColors.error50,
                  borderRadius: KFRadius.radiusSm,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: KFColors.error600,
                    ),
                    const SizedBox(width: KFSpacing.space2),
                    Expanded(
                      child: Text(
                        item.rejectionReason!,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeXs,
                          color: KFColors.error700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime end) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    if (start == end) {
      return '${start.day} ${months[start.month - 1]} ${start.year}';
    }

    if (start.month == end.month && start.year == end.year) {
      return '${start.day}-${end.day} ${months[start.month - 1]} ${start.year}';
    }

    return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${end.year}';
  }

  String _getStatusLabel(StatusType status) {
    switch (status) {
      case StatusType.pending:
        return 'Pending';
      case StatusType.approved:
        return 'Approved';
      case StatusType.rejected:
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}

class _LeaveHistoryItem {
  final String id;
  final String type;
  final IconData typeIcon;
  final Color typeColor;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final StatusType status;
  final DateTime appliedDate;
  final String? approver;
  final String? rejectionReason;

  _LeaveHistoryItem({
    required this.id,
    required this.type,
    required this.typeIcon,
    required this.typeColor,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.status,
    required this.appliedDate,
    this.approver,
    this.rejectionReason,
  });
}

class _FilterOption {
  final String id;
  final String label;

  _FilterOption(this.id, this.label);
}
