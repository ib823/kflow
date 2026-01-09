import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Approval list screen with tabs for Pending/Approved/Rejected
class ApprovalListScreen extends StatefulWidget {
  final void Function(String approvalId)? onApprovalTap;

  const ApprovalListScreen({
    super.key,
    this.onApprovalTap,
  });

  @override
  State<ApprovalListScreen> createState() => _ApprovalListScreenState();
}

class _ApprovalListScreenState extends State<ApprovalListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;
  List<_ApprovalItem> _pendingItems = [];
  List<_ApprovalItem> _approvedItems = [];
  List<_ApprovalItem> _rejectedItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadApprovals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _pendingItems = _getMockPendingItems();
        _approvedItems = _getMockApprovedItems();
        _rejectedItems = _getMockRejectedItems();
      });
    }
  }

  List<_ApprovalItem> _getMockPendingItems() {
    return [
      _ApprovalItem(
        id: 'apr-001',
        employeeName: 'Sarah Tan',
        employeeId: 'EMP2345',
        employeeAvatar: null,
        leaveType: 'Annual Leave',
        leaveTypeIcon: Icons.beach_access,
        leaveTypeColor: KFColors.primary600,
        startDate: DateTime(2026, 1, 15),
        endDate: DateTime(2026, 1, 17),
        days: 3,
        reason: 'Family vacation',
        submittedDate: DateTime(2026, 1, 8),
        status: StatusType.pending,
      ),
      _ApprovalItem(
        id: 'apr-002',
        employeeName: 'Ali bin Hassan',
        employeeId: 'EMP3456',
        employeeAvatar: null,
        leaveType: 'Medical Leave',
        leaveTypeIcon: Icons.local_hospital,
        leaveTypeColor: KFColors.error500,
        startDate: DateTime(2026, 1, 10),
        endDate: DateTime(2026, 1, 10),
        days: 1,
        reason: 'Doctor appointment',
        submittedDate: DateTime(2026, 1, 9),
        status: StatusType.pending,
      ),
      _ApprovalItem(
        id: 'apr-003',
        employeeName: 'Priya Kumar',
        employeeId: 'EMP4567',
        employeeAvatar: null,
        leaveType: 'Emergency Leave',
        leaveTypeIcon: Icons.warning_amber,
        leaveTypeColor: KFColors.warning500,
        startDate: DateTime(2026, 1, 12),
        endDate: DateTime(2026, 1, 12),
        days: 1,
        reason: 'Family emergency',
        submittedDate: DateTime(2026, 1, 9),
        status: StatusType.pending,
      ),
    ];
  }

  List<_ApprovalItem> _getMockApprovedItems() {
    return [
      _ApprovalItem(
        id: 'apr-101',
        employeeName: 'John Lim',
        employeeId: 'EMP5678',
        employeeAvatar: null,
        leaveType: 'Annual Leave',
        leaveTypeIcon: Icons.beach_access,
        leaveTypeColor: KFColors.primary600,
        startDate: DateTime(2026, 1, 2),
        endDate: DateTime(2026, 1, 3),
        days: 2,
        reason: 'Personal matters',
        submittedDate: DateTime(2025, 12, 28),
        status: StatusType.approved,
      ),
    ];
  }

  List<_ApprovalItem> _getMockRejectedItems() {
    return [
      _ApprovalItem(
        id: 'apr-201',
        employeeName: 'Mei Ling',
        employeeId: 'EMP6789',
        employeeAvatar: null,
        leaveType: 'Annual Leave',
        leaveTypeIcon: Icons.beach_access,
        leaveTypeColor: KFColors.primary600,
        startDate: DateTime(2025, 12, 31),
        endDate: DateTime(2025, 12, 31),
        days: 1,
        reason: 'Year end celebration',
        submittedDate: DateTime(2025, 12, 20),
        status: StatusType.rejected,
        rejectionReason: 'Critical project deadline',
      ),
    ];
  }

  Future<void> _onRefresh() async {
    await _loadApprovals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approvals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pending'),
                  if (_pendingItems.isNotEmpty) ...[
                    const SizedBox(width: KFSpacing.space2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KFSpacing.space2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: KFColors.error500,
                        borderRadius: KFRadius.radiusFull,
                      ),
                      child: Text(
                        '${_pendingItems.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: KFTypography.bold,
                          color: KFColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Tab(text: 'Approved'),
            const Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApprovalList(_pendingItems, 'No pending approvals'),
                    _buildApprovalList(_approvedItems, 'No approved requests'),
                    _buildApprovalList(_rejectedItems, 'No rejected requests'),
                  ],
                ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: KFSpacing.screenPadding,
      itemCount: 3,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: KFSpacing.space4),
          child: KFSkeletonCard(height: 140),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadApprovals,
    );
  }

  Widget _buildApprovalList(List<_ApprovalItem> items, String emptyMessage) {
    if (items.isEmpty) {
      return KFEmptyState(
        icon: Icons.assignment_outlined,
        title: 'No Items',
        message: emptyMessage,
      );
    }

    return KFRefreshable(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: KFSpacing.screenPadding,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: KFSpacing.space3),
            child: _buildApprovalCard(item),
          );
        },
      ),
    );
  }

  Widget _buildApprovalCard(_ApprovalItem item) {
    return KFApprovalCard(
      employeeName: item.employeeName,
      employeeId: item.employeeId,
      leaveType: item.leaveType,
      leaveTypeIcon: item.leaveTypeIcon,
      leaveTypeColor: item.leaveTypeColor,
      startDate: item.startDate,
      endDate: item.endDate,
      days: item.days,
      reason: item.reason,
      status: item.status,
      onTap: () => widget.onApprovalTap?.call(item.id),
    );
  }
}

class _ApprovalItem {
  final String id;
  final String employeeName;
  final String employeeId;
  final String? employeeAvatar;
  final String leaveType;
  final IconData leaveTypeIcon;
  final Color leaveTypeColor;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final String reason;
  final DateTime submittedDate;
  final StatusType status;
  final String? rejectionReason;

  _ApprovalItem({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    this.employeeAvatar,
    required this.leaveType,
    required this.leaveTypeIcon,
    required this.leaveTypeColor,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.submittedDate,
    required this.status,
    this.rejectionReason,
  });
}
