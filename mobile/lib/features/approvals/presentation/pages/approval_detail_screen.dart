import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Approval detail screen for reviewing and approving/rejecting leave requests
class ApprovalDetailScreen extends StatefulWidget {
  final String approvalId;
  final VoidCallback? onApproved;
  final VoidCallback? onRejected;

  const ApprovalDetailScreen({
    super.key,
    required this.approvalId,
    this.onApproved,
    this.onRejected,
  });

  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = true;
  bool _isProcessing = false;
  String? _errorMessage;
  _ApprovalDetail? _approval;

  @override
  void initState() {
    super.initState();
    _loadApprovalDetail();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadApprovalDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _approval = _getMockApprovalDetail();
      });
    }
  }

  _ApprovalDetail _getMockApprovalDetail() {
    return _ApprovalDetail(
      id: widget.approvalId,
      employeeName: 'Sarah Tan',
      employeeId: 'EMP2345',
      employeeAvatar: null,
      department: 'Engineering',
      position: 'Software Engineer',
      leaveType: 'Annual Leave',
      leaveTypeIcon: Icons.beach_access,
      leaveTypeColor: KFColors.primary600,
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 1, 17),
      days: 3,
      reason: 'Family vacation - visiting parents in Penang for Chinese New Year preparation.',
      submittedDate: DateTime(2026, 1, 8),
      status: StatusType.pending,
      currentBalance: 10,
      balanceAfter: 7,
    );
  }

  Future<void> _handleApprove() async {
    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showSuccessDialog('Approved', 'Leave request has been approved.');
    }
  }

  Future<void> _handleReject() async {
    if (_commentController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Please provide a reason for rejection');
      return;
    }

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isProcessing = false);
      _showSuccessDialog('Rejected', 'Leave request has been rejected.');
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: title == 'Approved'
                    ? KFColors.success100
                    : KFColors.error100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                title == 'Approved' ? Icons.check : Icons.close,
                color: title == 'Approved'
                    ? KFColors.success600
                    : KFColors.error600,
                size: 24,
              ),
            ),
            const SizedBox(width: KFSpacing.space3),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (title == 'Approved') {
                widget.onApproved?.call();
              } else {
                widget.onRejected?.call();
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Approval Detail'),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null && _approval == null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar:
          !_isLoading && _approval != null && _approval!.status == StatusType.pending
              ? _buildActionButtons()
              : null,
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        children: const [
          KFSkeletonCard(height: 120),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 200),
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 150),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadApprovalDetail,
    );
  }

  Widget _buildContent() {
    final approval = _approval!;

    return KFLoadingOverlay(
      isLoading: _isProcessing,
      message: 'Processing...',
      child: SingleChildScrollView(
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildEmployeeCard(approval),
            const SizedBox(height: KFSpacing.space4),
            _buildLeaveDetailsCard(approval),
            const SizedBox(height: KFSpacing.space4),
            _buildBalanceCard(approval),
            const SizedBox(height: KFSpacing.space4),
            _buildReasonCard(approval),
            if (approval.status == StatusType.pending) ...[
              const SizedBox(height: KFSpacing.space4),
              _buildCommentSection(),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: KFSpacing.space4),
              KFInfoBanner(
                message: _errorMessage!,
                backgroundColor: KFColors.error100,
                textColor: KFColors.error700,
                icon: Icons.error_outline,
                onDismiss: () => setState(() => _errorMessage = null),
              ),
            ],
            const SizedBox(height: KFSpacing.space8),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(_ApprovalDetail approval) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: KFColors.primary100,
              child: approval.employeeAvatar != null
                  ? ClipOval(
                      child: Image.network(
                        approval.employeeAvatar!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      approval.employeeName.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: KFTypography.fontSize2xl,
                        fontWeight: KFTypography.bold,
                        color: KFColors.primary600,
                      ),
                    ),
            ),
            const SizedBox(width: KFSpacing.space4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    approval.employeeName,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeLg,
                      fontWeight: KFTypography.semiBold,
                    ),
                  ),
                  const SizedBox(height: KFSpacing.space1),
                  Text(
                    approval.employeeId,
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.gray600,
                    ),
                  ),
                  Text(
                    '${approval.position} • ${approval.department}',
                    style: const TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      color: KFColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveDetailsCard(_ApprovalDetail approval) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: approval.leaveTypeColor.withOpacity(0.1),
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Icon(
                    approval.leaveTypeIcon,
                    color: approval.leaveTypeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        approval.leaveType,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          fontWeight: KFTypography.semiBold,
                        ),
                      ),
                      Text(
                        'Submitted ${_formatDate(approval.submittedDate)}',
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          color: KFColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                KFStatusChip(
                  label: _getStatusLabel(approval.status),
                  type: approval.status,
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space4),
            const Divider(),
            const SizedBox(height: KFSpacing.space3),
            _buildDetailRow('Start Date', _formatDate(approval.startDate)),
            _buildDetailRow('End Date', _formatDate(approval.endDate)),
            _buildDetailRow(
              'Duration',
              '${approval.days} ${approval.days == 1 ? 'day' : 'days'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KFSpacing.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              color: KFColors.gray600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              fontWeight: KFTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(_ApprovalDetail approval) {
    return Container(
      padding: const EdgeInsets.all(KFSpacing.space4),
      decoration: BoxDecoration(
        color: KFColors.info50,
        borderRadius: KFRadius.radiusMd,
        border: Border.all(color: KFColors.info200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.info600,
                  ),
                ),
                Text(
                  '${approval.currentBalance} days',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeLg,
                    fontWeight: KFTypography.bold,
                    color: KFColors.info700,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            color: KFColors.info400,
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
                  'After Approval',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.info600,
                  ),
                ),
                Text(
                  '${approval.balanceAfter} days',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeLg,
                    fontWeight: KFTypography.bold,
                    color: KFColors.info700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(_ApprovalDetail approval) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reason',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space3),
            Text(
              approval.reason,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space2),
            const Text(
              'Required for rejection',
              style: TextStyle(
                fontSize: KFTypography.fontSizeXs,
                color: KFColors.gray500,
              ),
            ),
            const SizedBox(height: KFSpacing.space3),
            KFTextArea(
              controller: _commentController,
              hint: 'Add a comment (optional for approval, required for rejection)',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: EdgeInsets.only(
        left: KFSpacing.space4,
        right: KFSpacing.space4,
        top: KFSpacing.space4,
        bottom: MediaQuery.of(context).padding.bottom + KFSpacing.space4,
      ),
      decoration: const BoxDecoration(
        color: KFColors.white,
        border: Border(
          top: BorderSide(color: KFColors.gray200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: KFDangerButton(
              label: 'Reject',
              onPressed: _isProcessing ? null : _handleReject,
              isLoading: _isProcessing,
            ),
          ),
          const SizedBox(width: KFSpacing.space4),
          Expanded(
            child: KFSuccessButton(
              label: 'Approve',
              onPressed: _isProcessing ? null : _handleApprove,
              isLoading: _isProcessing,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

class _ApprovalDetail {
  final String id;
  final String employeeName;
  final String employeeId;
  final String? employeeAvatar;
  final String department;
  final String position;
  final String leaveType;
  final IconData leaveTypeIcon;
  final Color leaveTypeColor;
  final DateTime startDate;
  final DateTime endDate;
  final double days;
  final String reason;
  final DateTime submittedDate;
  final StatusType status;
  final int currentBalance;
  final int balanceAfter;

  _ApprovalDetail({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    this.employeeAvatar,
    required this.department,
    required this.position,
    required this.leaveType,
    required this.leaveTypeIcon,
    required this.leaveTypeColor,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    required this.submittedDate,
    required this.status,
    required this.currentBalance,
    required this.balanceAfter,
  });
}
