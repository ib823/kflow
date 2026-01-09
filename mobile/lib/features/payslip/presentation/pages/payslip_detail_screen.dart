import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Payslip detail screen showing breakdown of earnings and deductions
class PayslipDetailScreen extends StatefulWidget {
  final String payslipId;
  final VoidCallback? onDownloadPdf;
  final VoidCallback? onShare;

  const PayslipDetailScreen({
    super.key,
    required this.payslipId,
    this.onDownloadPdf,
    this.onShare,
  });

  @override
  State<PayslipDetailScreen> createState() => _PayslipDetailScreenState();
}

class _PayslipDetailScreenState extends State<PayslipDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  _PayslipDetail? _payslip;

  @override
  void initState() {
    super.initState();
    _loadPayslipDetail();
  }

  Future<void> _loadPayslipDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _payslip = _getMockPayslipDetail();
      });
    }
  }

  _PayslipDetail _getMockPayslipDetail() {
    return _PayslipDetail(
      id: widget.payslipId,
      month: 'December',
      year: 2025,
      payPeriod: '1 - 31 December 2025',
      payDate: '27 December 2025',
      employeeName: 'Ahmad Bin Mohd',
      employeeId: 'EMP1234',
      department: 'Engineering',
      position: 'Software Engineer',
      earnings: [
        _PayslipLine('Basic Salary', 5000.00),
        _PayslipLine('Fixed Allowance', 300.00),
        _PayslipLine('Transport Allowance', 200.00),
      ],
      deductions: [
        _PayslipLine('EPF (Employee 11%)', 550.00),
        _PayslipLine('SOCSO', 19.75),
        _PayslipLine('EIS', 11.00),
        _PayslipLine('PCB (Tax)', 47.25),
      ],
      employerContributions: [
        _PayslipLine('EPF (Employer 13%)', 650.00),
        _PayslipLine('SOCSO (Employer)', 86.65),
        _PayslipLine('EIS (Employer)', 11.00),
      ],
      grossEarnings: 5500.00,
      totalDeductions: 628.00,
      netPay: 4872.00,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KFAppBar(
        title: 'Payslip Detail',
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: widget.onShare,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: widget.onDownloadPdf,
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
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
          SizedBox(height: KFSpacing.space4),
          KFSkeletonCard(height: 80),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return KFErrorState(
      message: _errorMessage!,
      onRetry: _loadPayslipDetail,
    );
  }

  Widget _buildContent() {
    final payslip = _payslip!;

    return SingleChildScrollView(
      padding: KFSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeaderCard(payslip),
          const SizedBox(height: KFSpacing.space4),
          _buildEmployeeInfoCard(payslip),
          const SizedBox(height: KFSpacing.space4),
          _buildEarningsCard(payslip),
          const SizedBox(height: KFSpacing.space4),
          _buildDeductionsCard(payslip),
          const SizedBox(height: KFSpacing.space4),
          _buildEmployerContributionsCard(payslip),
          const SizedBox(height: KFSpacing.space4),
          _buildSummaryCard(payslip),
          const SizedBox(height: KFSpacing.space6),
          _buildDownloadButton(),
          const SizedBox(height: KFSpacing.space6),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(_PayslipDetail payslip) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${payslip.month} ${payslip.year}',
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXl,
                    fontWeight: KFTypography.bold,
                    color: KFColors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KFSpacing.space3,
                    vertical: KFSpacing.space1,
                  ),
                  decoration: BoxDecoration(
                    color: KFColors.white.withOpacity(0.2),
                    borderRadius: KFRadius.radiusFull,
                  ),
                  child: const Text(
                    'RELEASED',
                    style: TextStyle(
                      fontSize: KFTypography.fontSizeXs,
                      fontWeight: KFTypography.bold,
                      color: KFColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space2),
            Text(
              'Pay Period: ${payslip.payPeriod}',
              style: TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.white.withOpacity(0.8),
              ),
            ),
            Text(
              'Pay Date: ${payslip.payDate}',
              style: TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard(_PayslipDetail payslip) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Employee Information',
              style: TextStyle(
                fontSize: KFTypography.fontSizeMd,
                fontWeight: KFTypography.semiBold,
              ),
            ),
            const SizedBox(height: KFSpacing.space3),
            _buildInfoRow('Name', payslip.employeeName),
            _buildInfoRow('Employee ID', payslip.employeeId),
            _buildInfoRow('Department', payslip.department),
            _buildInfoRow('Position', payslip.position),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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

  Widget _buildEarningsCard(_PayslipDetail payslip) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Earnings',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.semiBold,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KFColors.success500,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space3),
            ...payslip.earnings.map((item) => _buildLineItem(item)),
            const Divider(height: KFSpacing.space4),
            _buildTotalRow('Gross Earnings', payslip.grossEarnings),
          ],
        ),
      ),
    );
  }

  Widget _buildDeductionsCard(_PayslipDetail payslip) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deductions',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.semiBold,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KFColors.error500,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space3),
            ...payslip.deductions.map((item) => _buildLineItem(item)),
            const Divider(height: KFSpacing.space4),
            _buildTotalRow('Total Deductions', payslip.totalDeductions,
                isDeduction: true),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployerContributionsCard(_PayslipDetail payslip) {
    return KFCard(
      child: Padding(
        padding: const EdgeInsets.all(KFSpacing.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Employer Contributions',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.semiBold,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: KFColors.info500,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KFSpacing.space3),
            ...payslip.employerContributions.map((item) => _buildLineItem(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(_PayslipLine item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KFSpacing.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.label,
              style: const TextStyle(
                fontSize: KFTypography.fontSizeSm,
                color: KFColors.gray700,
              ),
            ),
          ),
          Text(
            'RM ${item.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: KFTypography.fontSizeSm,
              fontWeight: KFTypography.medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isDeduction = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: KFTypography.fontSizeSm,
            fontWeight: KFTypography.semiBold,
          ),
        ),
        Text(
          '${isDeduction ? '-' : ''}RM ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: KFTypography.fontSizeMd,
            fontWeight: KFTypography.bold,
            color: isDeduction ? KFColors.error600 : KFColors.success600,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(_PayslipDetail payslip) {
    return Container(
      padding: const EdgeInsets.all(KFSpacing.space4),
      decoration: BoxDecoration(
        color: KFColors.success50,
        borderRadius: KFRadius.radiusMd,
        border: Border.all(color: KFColors.success200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Net Pay',
            style: TextStyle(
              fontSize: KFTypography.fontSizeLg,
              fontWeight: KFTypography.semiBold,
              color: KFColors.success700,
            ),
          ),
          Text(
            'RM ${payslip.netPay.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: KFTypography.fontSize2xl,
              fontWeight: KFTypography.bold,
              color: KFColors.success700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return KFPrimaryButton(
      label: 'Download PDF',
      leadingIcon: Icons.download,
      onPressed: widget.onDownloadPdf,
    );
  }
}

class _PayslipDetail {
  final String id;
  final String month;
  final int year;
  final String payPeriod;
  final String payDate;
  final String employeeName;
  final String employeeId;
  final String department;
  final String position;
  final List<_PayslipLine> earnings;
  final List<_PayslipLine> deductions;
  final List<_PayslipLine> employerContributions;
  final double grossEarnings;
  final double totalDeductions;
  final double netPay;

  _PayslipDetail({
    required this.id,
    required this.month,
    required this.year,
    required this.payPeriod,
    required this.payDate,
    required this.employeeName,
    required this.employeeId,
    required this.department,
    required this.position,
    required this.earnings,
    required this.deductions,
    required this.employerContributions,
    required this.grossEarnings,
    required this.totalDeductions,
    required this.netPay,
  });
}

class _PayslipLine {
  final String label;
  final double amount;

  _PayslipLine(this.label, this.amount);
}
