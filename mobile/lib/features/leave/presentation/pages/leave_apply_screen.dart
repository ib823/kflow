import 'package:flutter/material.dart';
import '../../../../core/core.dart';

/// Leave application screen
class LeaveApplyScreen extends StatefulWidget {
  final VoidCallback? onSuccess;

  const LeaveApplyScreen({
    super.key,
    this.onSuccess,
  });

  @override
  State<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends State<LeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  String? _selectedLeaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isHalfDay = false;
  String _halfDayPeriod = 'morning';
  bool _isLoading = false;
  String? _errorMessage;

  final List<_LeaveTypeOption> _leaveTypes = [
    _LeaveTypeOption('annual', 'Annual Leave', 12),
    _LeaveTypeOption('medical', 'Medical Leave', 11),
    _LeaveTypeOption('emergency', 'Emergency Leave', 3),
    _LeaveTypeOption('unpaid', 'Unpaid Leave', 30),
    _LeaveTypeOption('compassionate', 'Compassionate Leave', 3),
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _numberOfDays {
    if (_startDate == null || _endDate == null) return 0;
    if (_isHalfDay) return 0; // Will show 0.5 separately
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLeaveType == null) {
      setState(() => _errorMessage = 'Please select a leave type');
      return;
    }

    if (_startDate == null) {
      setState(() => _errorMessage = 'Please select a start date');
      return;
    }

    if (!_isHalfDay && _endDate == null) {
      setState(() => _errorMessage = 'Please select an end date');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: KFColors.success100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: KFColors.success600,
                size: 24,
              ),
            ),
            const SizedBox(width: KFSpacing.space3),
            const Text('Application Submitted'),
          ],
        ),
        content: const Text(
          'Your leave application has been submitted successfully. You will receive a notification once it is approved.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onSuccess?.call();
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
      appBar: const KFAppBar(title: 'Apply Leave'),
      body: KFLoadingOverlay(
        isLoading: _isLoading,
        message: 'Submitting application...',
        child: SingleChildScrollView(
          padding: KFSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  KFInfoBanner(
                    message: _errorMessage!,
                    backgroundColor: KFColors.error100,
                    textColor: KFColors.error700,
                    icon: Icons.error_outline,
                    onDismiss: () => setState(() => _errorMessage = null),
                  ),
                  const SizedBox(height: KFSpacing.space4),
                ],
                _buildLeaveTypeSelector(),
                const SizedBox(height: KFSpacing.space4),
                _buildHalfDayToggle(),
                const SizedBox(height: KFSpacing.space4),
                _buildDateSelectors(),
                if (_isHalfDay) ...[
                  const SizedBox(height: KFSpacing.space4),
                  _buildHalfDayPeriodSelector(),
                ],
                const SizedBox(height: KFSpacing.space4),
                _buildDurationSummary(),
                const SizedBox(height: KFSpacing.space4),
                KFTextArea(
                  controller: _reasonController,
                  label: 'Reason',
                  hint: 'Enter the reason for your leave application',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a reason';
                    }
                    if (value.length < 10) {
                      return 'Reason must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: KFSpacing.space4),
                _buildAttachmentSection(),
                const SizedBox(height: KFSpacing.space8),
                KFPrimaryButton(
                  label: 'Submit Application',
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: KFSpacing.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Leave Type',
          style: TextStyle(
            fontSize: KFTypography.fontSizeSm,
            fontWeight: KFTypography.medium,
            color: KFColors.gray700,
          ),
        ),
        const SizedBox(height: KFSpacing.space2),
        Wrap(
          spacing: KFSpacing.space2,
          runSpacing: KFSpacing.space2,
          children: _leaveTypes.map((type) {
            final isSelected = _selectedLeaveType == type.id;
            return Material(
              color: isSelected ? KFColors.primary600 : KFColors.gray100,
              borderRadius: KFRadius.radiusMd,
              child: InkWell(
                onTap: () => setState(() => _selectedLeaveType = type.id),
                borderRadius: KFRadius.radiusMd,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KFSpacing.space3,
                    vertical: KFSpacing.space2,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.name,
                        style: TextStyle(
                          fontSize: KFTypography.fontSizeSm,
                          fontWeight: KFTypography.medium,
                          color: isSelected ? KFColors.white : KFColors.gray700,
                        ),
                      ),
                      const SizedBox(width: KFSpacing.space2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KFSpacing.space2,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? KFColors.white.withOpacity(0.2)
                              : KFColors.gray200,
                          borderRadius: KFRadius.radiusFull,
                        ),
                        child: Text(
                          '${type.balance}',
                          style: TextStyle(
                            fontSize: KFTypography.fontSizeXs,
                            fontWeight: KFTypography.medium,
                            color:
                                isSelected ? KFColors.white : KFColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHalfDayToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Half Day',
          style: TextStyle(
            fontSize: KFTypography.fontSizeSm,
            fontWeight: KFTypography.medium,
            color: KFColors.gray700,
          ),
        ),
        Switch(
          value: _isHalfDay,
          onChanged: (value) {
            setState(() {
              _isHalfDay = value;
              if (value) {
                _endDate = _startDate;
              }
            });
          },
          activeColor: KFColors.primary600,
        ),
      ],
    );
  }

  Widget _buildDateSelectors() {
    return Row(
      children: [
        Expanded(
          child: KFDatePicker(
            label: _isHalfDay ? 'Date' : 'Start Date',
            value: _startDate,
            onChanged: (date) {
              setState(() {
                _startDate = date;
                if (_isHalfDay) {
                  _endDate = date;
                } else if (_endDate != null && date.isAfter(_endDate!)) {
                  _endDate = null;
                }
              });
            },
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          ),
        ),
        if (!_isHalfDay) ...[
          const SizedBox(width: KFSpacing.space4),
          Expanded(
            child: KFDatePicker(
              label: 'End Date',
              value: _endDate,
              onChanged: (date) => setState(() => _endDate = date),
              firstDate: _startDate ?? DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildHalfDayPeriodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Period',
          style: TextStyle(
            fontSize: KFTypography.fontSizeSm,
            fontWeight: KFTypography.medium,
            color: KFColors.gray700,
          ),
        ),
        const SizedBox(height: KFSpacing.space2),
        Row(
          children: [
            Expanded(
              child: _buildPeriodOption('morning', 'Morning', '8:00 AM - 1:00 PM'),
            ),
            const SizedBox(width: KFSpacing.space3),
            Expanded(
              child: _buildPeriodOption(
                  'afternoon', 'Afternoon', '2:00 PM - 6:00 PM'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodOption(String value, String title, String subtitle) {
    final isSelected = _halfDayPeriod == value;
    return Material(
      color: isSelected ? KFColors.primary50 : KFColors.white,
      borderRadius: KFRadius.radiusMd,
      child: InkWell(
        onTap: () => setState(() => _halfDayPeriod = value),
        borderRadius: KFRadius.radiusMd,
        child: Container(
          padding: const EdgeInsets.all(KFSpacing.space3),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? KFColors.primary600 : KFColors.gray300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: KFRadius.radiusMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    size: 20,
                    color: isSelected ? KFColors.primary600 : KFColors.gray400,
                  ),
                  const SizedBox(width: KFSpacing.space2),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: KFTypography.fontSizeSm,
                      fontWeight: KFTypography.medium,
                      color: isSelected ? KFColors.primary700 : KFColors.gray700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KFSpacing.space1),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.gray500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSummary() {
    if (_startDate == null) return const SizedBox.shrink();

    final durationText = _isHalfDay ? '0.5 day' : '$_numberOfDays day(s)';

    return Container(
      padding: const EdgeInsets.all(KFSpacing.space4),
      decoration: BoxDecoration(
        color: KFColors.info50,
        borderRadius: KFRadius.radiusMd,
        border: Border.all(color: KFColors.info200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            size: 20,
            color: KFColors.info600,
          ),
          const SizedBox(width: KFSpacing.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeXs,
                    color: KFColors.info600,
                  ),
                ),
                Text(
                  durationText,
                  style: const TextStyle(
                    fontSize: KFTypography.fontSizeMd,
                    fontWeight: KFTypography.semiBold,
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

  Widget _buildAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attachments (Optional)',
          style: TextStyle(
            fontSize: KFTypography.fontSizeSm,
            fontWeight: KFTypography.medium,
            color: KFColors.gray700,
          ),
        ),
        const SizedBox(height: KFSpacing.space2),
        Container(
          padding: const EdgeInsets.all(KFSpacing.space4),
          decoration: BoxDecoration(
            border: Border.all(
              color: KFColors.gray300,
              style: BorderStyle.solid,
            ),
            borderRadius: KFRadius.radiusMd,
          ),
          child: InkWell(
            onTap: () {
              // TODO: Implement file picker
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.upload_file,
                  color: KFColors.gray500,
                ),
                SizedBox(width: KFSpacing.space2),
                Text(
                  'Upload supporting document',
                  style: TextStyle(
                    fontSize: KFTypography.fontSizeSm,
                    color: KFColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KFSpacing.space2),
        const Text(
          'Max file size: 5MB. Supported: PDF, JPG, PNG',
          style: TextStyle(
            fontSize: KFTypography.fontSizeXs,
            color: KFColors.gray500,
          ),
        ),
      ],
    );
  }
}

class _LeaveTypeOption {
  final String id;
  final String name;
  final int balance;

  _LeaveTypeOption(this.id, this.name, this.balance);
}
