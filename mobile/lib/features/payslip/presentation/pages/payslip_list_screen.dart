import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Payslip list screen showing all payslips
class PayslipListScreen extends StatefulWidget {
  final void Function(String payslipId)? onPayslipTap;

  const PayslipListScreen({
    super.key,
    this.onPayslipTap,
  });

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<_PayslipItem> _payslips = [];
  String _selectedYear = '2026';

  final List<String> _years = ['2026', '2025', '2024', '2023'];

  @override
  void initState() {
    super.initState();
    _loadPayslips();
  }

  Future<void> _loadPayslips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _payslips = _getMockPayslips();
      });
    }
  }

  List<_PayslipItem> _getMockPayslips() {
    if (_selectedYear == '2026') {
      return [
        _PayslipItem(
          id: 'ps-2026-01',
          month: 'January',
          year: 2026,
          netAmount: 4380.00,
          grossAmount: 5500.00,
          isNew: false,
          status: StatusType.pending,
        ),
      ];
    }
    return [
      _PayslipItem(
        id: 'ps-2025-12',
        month: 'December',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: true,
        status: StatusType.approved,
      ),
      _PayslipItem(
        id: 'ps-2025-11',
        month: 'November',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: false,
        status: StatusType.approved,
      ),
      _PayslipItem(
        id: 'ps-2025-10',
        month: 'October',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: false,
        status: StatusType.approved,
      ),
      _PayslipItem(
        id: 'ps-2025-09',
        month: 'September',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: false,
        status: StatusType.approved,
      ),
      _PayslipItem(
        id: 'ps-2025-08',
        month: 'August',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: false,
        status: StatusType.approved,
      ),
      _PayslipItem(
        id: 'ps-2025-07',
        month: 'July',
        year: 2025,
        netAmount: 4422.00,
        grossAmount: 5500.00,
        isNew: false,
        status: StatusType.approved,
      ),
    ];
  }

  Future<void> _onRefresh() async {
    await _loadPayslips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KFAppBar(title: 'Payslips'),
      body: Column(
        children: [
          _buildYearSelector(),
          Expanded(
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState()
                    : _payslips.isEmpty
                        ? _buildEmptyState()
                        : _buildPayslipList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
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
        children: _years.map((year) {
          final isSelected = year == _selectedYear;
          return Padding(
            padding: const EdgeInsets.only(right: KFSpacing.space2),
            child: Material(
              color: isSelected ? KFColors.primary600 : KFColors.gray100,
              borderRadius: KFRadius.radiusFull,
              child: InkWell(
                onTap: () {
                  setState(() => _selectedYear = year);
                  _loadPayslips();
                },
                borderRadius: KFRadius.radiusFull,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KFSpacing.space4,
                    vertical: KFSpacing.space2,
                  ),
                  child: Text(
                    year,
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
      itemCount: 6,
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
      onRetry: _loadPayslips,
    );
  }

  Widget _buildEmptyState() {
    return const KFEmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No Payslips',
      message: 'No payslips found for this year.',
    );
  }

  Widget _buildPayslipList() {
    return KFRefreshable(
      onRefresh: _onRefresh,
      child: ListView.builder(
        padding: KFSpacing.screenPadding,
        itemCount: _payslips.length,
        itemBuilder: (context, index) {
          final payslip = _payslips[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: KFSpacing.space4),
            child: _buildPayslipCard(payslip),
          );
        },
      ),
    );
  }

  Widget _buildPayslipCard(_PayslipItem payslip) {
    return KFElevatedCard(
      onTap: () => widget.onPayslipTap?.call(payslip.id),
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
                    color: KFColors.primary100,
                    borderRadius: KFRadius.radiusMd,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: KFColors.primary600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: KFSpacing.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${payslip.month} ${payslip.year}',
                            style: const TextStyle(
                              fontSize: KFTypography.fontSizeMd,
                              fontWeight: KFTypography.semiBold,
                            ),
                          ),
                          if (payslip.isNew) ...[
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
                              child: const Text(
                                'NEW',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: KFTypography.bold,
                                  color: KFColors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: KFSpacing.space1),
                      Text(
                        'Gross: RM ${payslip.grossAmount.toStringAsFixed(2)}',
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
                      'RM ${payslip.netAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: KFTypography.fontSizeLg,
                        fontWeight: KFTypography.bold,
                        color: KFColors.primary600,
                      ),
                    ),
                    const SizedBox(height: KFSpacing.space1),
                    KFStatusChip(
                      label: payslip.status == StatusType.approved
                          ? 'Released'
                          : 'Processing',
                      type: payslip.status,
                      size: ChipSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PayslipItem {
  final String id;
  final String month;
  final int year;
  final double netAmount;
  final double grossAmount;
  final bool isNew;
  final StatusType status;

  _PayslipItem({
    required this.id,
    required this.month,
    required this.year,
    required this.netAmount,
    required this.grossAmount,
    required this.isNew,
    required this.status,
  });
}
