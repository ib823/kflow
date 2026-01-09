import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Leave balance screen showing all leave type balances
class LeaveBalanceScreen extends StatefulWidget {
  final VoidCallback? onApplyLeave;
  final VoidCallback? onViewHistory;

  const LeaveBalanceScreen({
    super.key,
    this.onApplyLeave,
    this.onViewHistory,
  });

  @override
  State<LeaveBalanceScreen> createState() => _LeaveBalanceScreenState();
}

class _LeaveBalanceScreenState extends State<LeaveBalanceScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_LeaveType> _leaveTypes = [];

  @override
  void initState() {
    super.initState();
    _loadLeaveBalances();
  }

  Future<void> _loadLeaveBalances() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _leaveTypes = _getMockLeaveTypes();
      });
    }
  }

  List<_LeaveType> _getMockLeaveTypes() {
    return [
      _LeaveType(
        id: 'annual',
        name: 'Annual Leave',
        icon: Icons.beach_access,
        color: KFColors.primary600,
        entitled: 14,
        taken: 2,
        pending: 0,
        balance: 12,
      ),
      _LeaveType(
        id: 'medical',
        name: 'Medical Leave',
        icon: Icons.local_hospital,
        color: KFColors.error500,
        entitled: 14,
        taken: 3,
        pending: 0,
        balance: 11,
      ),
      _LeaveType(
        id: 'emergency',
        name: 'Emergency Leave',
        icon: Icons.warning_amber,
        color: KFColors.warning500,
        entitled: 3,
        taken: 0,
        pending: 0,
        balance: 3,
      ),
      _LeaveType(
        id: 'unpaid',
        name: 'Unpaid Leave',
        icon: Icons.money_off,
        color: KFColors.gray500,
        entitled: 30,
        taken: 0,
        pending: 0,
        balance: 30,
      ),
      _LeaveType(
        id: 'compassionate',
        name: 'Compassionate Leave',
        icon: Icons.favorite,
        color: KFColors.secondary500,
        entitled: 3,
        taken: 0,
        pending: 0,
        balance: 3,
      ),
    ];
  }

  Future<void> _onRefresh() async {
    await _loadLeaveBalances();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KFAppBar(
        title: 'Leave Balance',
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: widget.onViewHistory,
            tooltip: 'View History',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
      floatingActionButton: KFFAB(
        icon: Icons.add,
        label: 'Apply Leave',
        onPressed: widget.onApplyLeave,
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: KFSpacing.screenPadding,
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: KFSpacing.space4),
          child: KFSkeletonCard(height: 120),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadLeaveBalances,
    );
  }

  Widget _buildContent() {
    return KFRefreshable(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: KFSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: KFSpacing.space6),
            const KFSectionHeader(title: 'Leave Types'),
            const SizedBox(height: KFSpacing.space3),
            ..._leaveTypes.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: KFSpacing.space3),
                  child: _buildLeaveTypeCard(type),
                )),
            const SizedBox(height: KFSpacing.space8),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalEntitled = _leaveTypes.fold(0, (sum, t) => sum + t.entitled);
    final totalTaken = _leaveTypes.fold(0, (sum, t) => sum + t.taken);
    final totalBalance = _leaveTypes.fold(0, (sum, t) => sum + t.balance);

    return KFElevatedCard(
      child: Container(
        padding: const EdgeInsets.all(KFSpacing.space4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [KFColors.primary600, KFColors.primary700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: KFRadius.radiusMd,
        ),
        child: Column(
          children: [
            const Text(
              'Total Balance',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                color: KFColors.white,
              ),
            ),
            const SizedBox(height: KFSpacing.space2),
            Text(
              '$totalBalance days',
              style: const TextStyle(
                fontSize: KFTypography.fontSize4xl,
                fontWeight: KFTypography.bold,
                color: KFColors.white,
              ),
            ),
            const SizedBox(height: KFSpacing.space4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSummaryItem('Entitled', totalEntitled),
                Container(
                  width: 1,
                  height: 40,
                  color: KFColors.white.withOpacity(0.3),
                ),
                _buildSummaryItem('Taken', totalTaken),
                Container(
                  width: 1,
                  height: 40,
                  color: KFColors.white.withOpacity(0.3),
                ),
                _buildSummaryItem('Balance', totalBalance),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int value) {
    return Column(
      children: [
        Text(
          '$value',
          style: const TextStyle(
            fontSize: KFTypography.fontSizeXl,
            fontWeight: KFTypography.bold,
            color: KFColors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: KFTypography.fontSizeSm,
            color: KFColors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveTypeCard(_LeaveType type) {
    final progress = type.entitled > 0 ? type.taken / type.entitled : 0.0;

    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.1),
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: Icon(type.icon, color: type.color, size: 24),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.name,
                        style: const TextStyle(
                          fontSize: KFTypography.fontSizeMd,
                          fontWeight: KFTypography.semiBold,
                        ),
                      ),
                      const SizedBox(height: KFSpacing.space1),
                      Text(
                        '${type.taken} of ${type.entitled} days used',
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
                    Text(
                      '${type.balance}',
                      style: TextStyle(
                        fontSize: KFTypography.fontSize2xl,
                        fontWeight: KFTypography.bold,
                        color: type.color,
                      ),
                    ),
                    const Text(
                      'days left',
                      style: TextStyle(
                        fontSize: KFTypography.fontSizeXs,
                        color: KFColors.gray500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space3),
            // Progress bar
            ClipRRect(
              borderRadius: KFRadius.radiusFull,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: KFColors.gray200,
                valueColor: AlwaysStoppedAnimation(type.color),
                minHeight: 6,
              ),
            ),
            if (type.pending > 0) ...[
              const SizedBox(height: KFSpacing.space2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KFSpacing.space2,
                  vertical: KFSpacing.space1,
                ),
                decoration: BoxDecoration(
                  color: KFColors.warning100,
                  borderRadius: KFRadius.radiusFull,
                ),
                child: Text(
                  '${type.pending} pending approval',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.warning700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeaveType {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int entitled;
  final int taken;
  final int pending;
  final int balance;

  _LeaveType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.entitled,
    required this.taken,
    required this.pending,
    required this.balance,
  });
}
