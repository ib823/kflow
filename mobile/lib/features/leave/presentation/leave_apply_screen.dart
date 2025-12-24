import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';
import '../../../shared/providers/leave_provider.dart';
import '../../../shared/models/leave.dart';
import '../../../core/error/api_exception.dart';

class LeaveApplyScreen extends ConsumerStatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  ConsumerState<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends ConsumerState<LeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedLeaveTypeId;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _halfDayType;
  final _reasonController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isFrom) async {
    final initialDate = isFrom
        ? (_dateFrom ?? DateTime.now())
        : (_dateTo ?? _dateFrom ?? DateTime.now());

    final firstDate = isFrom
        ? DateTime.now()
        : (_dateFrom ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = pickedDate;
          if (_dateTo != null && _dateTo!.isBefore(pickedDate)) {
            _dateTo = pickedDate;
          }
        } else {
          _dateTo = pickedDate;
        }
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _calculateDays() {
    if (_dateFrom == null || _dateTo == null) return 0;
    return _dateTo!.difference(_dateFrom!).inDays + 1;
  }

  Future<void> _handleSubmit() async {
    // Clear previous error
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    if (_dateFrom == null || _dateTo == null) {
      setState(() => _errorMessage = 'Please select both start and end dates');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select dates'),
          backgroundColor: AppColors.error,
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.textInverse,
            onPressed: () {},
          ),
        ),
      );
      return;
    }

    // Validate leave balance
    final leaveState = ref.read(leaveNotifierProvider).valueOrNull;
    if (leaveState != null && _selectedLeaveTypeId != null) {
      final available = leaveState.getAvailableBalance(_selectedLeaveTypeId!);
      final requestedDays = _halfDayType != null ? 0.5 : _calculateDays().toDouble();

      if (requestedDays > available) {
        setState(() => _errorMessage = 'Insufficient leave balance. Available: $available days');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Insufficient leave balance. You have $available days available.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      // Create leave request using provider
      final request = CreateLeaveRequest(
        leaveTypeId: _selectedLeaveTypeId!,
        dateFrom: _formatDate(_dateFrom!),
        dateTo: _formatDate(_dateTo!),
        halfDayType: _halfDayType,
        reason: _reasonController.text.isNotEmpty ? _reasonController.text : null,
      );

      await ref.read(leaveNotifierProvider.notifier).submitRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(true); // Return true to indicate success
      }
    } on ApiException catch (e) {
      // Handle API-specific errors with user-friendly messages
      if (mounted) {
        String message;
        switch (e.code) {
          case 'INSUFFICIENT_BALANCE':
            message = 'You don\'t have enough leave balance for this request.';
            break;
          case 'LEAVE_OVERLAP':
            message = 'You already have a leave request for these dates.';
            break;
          case 'INSUFFICIENT_NOTICE':
            message = 'This leave type requires more advance notice.';
            break;
          case 'MAX_DAYS_EXCEEDED':
            message = 'This request exceeds the maximum days allowed.';
            break;
          case 'ATTACHMENT_REQUIRED':
            message = 'This leave type requires an attachment.';
            break;
          default:
            message = e.message;
        }
        setState(() => _errorMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textInverse,
              onPressed: _handleSubmit,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        final message = 'An unexpected error occurred. Please try again.';
        setState(() => _errorMessage = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: AppColors.error,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppColors.textInverse,
              onPressed: _handleSubmit,
            ),
          ),
        );
        // Log the actual error for debugging (in production, use a logging service)
        debugPrint('Leave submission error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = _calculateDays();
    final isSingleDay = days == 1;

    // Watch leave types from provider
    final leaveTypesAsync = ref.watch(leaveTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Leave'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Error message display
            if (_errorMessage != null)
              Semantics(
                liveRegion: true,
                child: Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.errorSurface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Leave Type - from provider
            leaveTypesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Failed to load leave types: $e'),
              data: (leaveTypes) => DropdownButtonFormField<int>(
                value: _selectedLeaveTypeId,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: leaveTypes.map((type) {
                  final leaveState = ref.read(leaveNotifierProvider).valueOrNull;
                  final available = leaveState?.getAvailableBalance(type.id) ?? 0;
                  return DropdownMenuItem<int>(
                    value: type.id,
                    child: Text(
                      '${type.name} (${available.toStringAsFixed(0)} days available)',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedLeaveTypeId = value);
                },
                validator: (value) {
                  if (value == null) return 'Please select leave type';
                  return null;
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Date From - with accessibility
            Semantics(
              label: _dateFrom != null
                  ? 'Start date: ${_formatDate(_dateFrom!)}'
                  : 'Select start date',
              button: true,
              child: InkWell(
                onTap: () => _selectDate(true),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'From Date',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    _dateFrom != null ? _formatDate(_dateFrom!) : 'Select date',
                    style: TextStyle(
                      color: _dateFrom != null ? null : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Date To - with accessibility
            Semantics(
              label: _dateTo != null
                  ? 'End date: ${_formatDate(_dateTo!)}'
                  : _dateFrom == null
                      ? 'End date. Select start date first'
                      : 'Select end date',
              button: _dateFrom != null,
              child: InkWell(
                onTap: _dateFrom != null ? () => _selectDate(false) : null,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    enabled: _dateFrom != null,
                  ),
                  child: Text(
                    _dateTo != null ? _formatDate(_dateTo!) : 'Select date',
                    style: TextStyle(
                      color: _dateTo != null ? null : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Half Day Option (only for single day)
            if (isSingleDay) ...[
              DropdownButtonFormField<String>(
                value: _halfDayType,
                decoration: const InputDecoration(
                  labelText: 'Half Day (Optional)',
                  prefixIcon: Icon(Icons.timelapse_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('Full Day')),
                  DropdownMenuItem(value: 'AM', child: Text('Morning (AM)')),
                  DropdownMenuItem(value: 'PM', child: Text('Afternoon (PM)')),
                ],
                onChanged: (value) {
                  setState(() => _halfDayType = value);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Days Summary
            if (days > 0)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _halfDayType != null
                          ? '0.5 day'
                          : '$days ${days == 1 ? 'day' : 'days'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: AppSpacing.lg),

            // Reason
            TextFormField(
              controller: _reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            FilledButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit Application'),
            ),
          ],
        ),
      ),
    );
  }
}
