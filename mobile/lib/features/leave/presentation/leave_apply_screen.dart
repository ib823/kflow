import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/theme/app_theme.dart';

class LeaveApplyScreen extends ConsumerStatefulWidget {
  const LeaveApplyScreen({super.key});

  @override
  ConsumerState<LeaveApplyScreen> createState() => _LeaveApplyScreenState();
}

class _LeaveApplyScreenState extends ConsumerState<LeaveApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLeaveType;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  String? _halfDayType;
  final _reasonController = TextEditingController();
  bool _isLoading = false;

  // Mock leave types
  final _leaveTypes = [
    {'id': 1, 'code': 'AL', 'name': 'Annual Leave', 'available': 10.0},
    {'id': 2, 'code': 'MC', 'name': 'Medical Leave', 'available': 12.0},
    {'id': 3, 'code': 'EL', 'name': 'Emergency Leave', 'available': 2.0},
    {'id': 4, 'code': 'UL', 'name': 'Unpaid Leave', 'available': 30.0},
  ];

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
    if (!_formKey.currentState!.validate()) return;
    if (_dateFrom == null || _dateTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Call API to submit leave request
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Leave request submitted successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply Leave'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Leave Type
            DropdownButtonFormField<String>(
              value: _selectedLeaveType,
              decoration: const InputDecoration(
                labelText: 'Leave Type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _leaveTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['code'] as String,
                  child: Text(
                    '${type['name']} (${(type['available'] as double).toStringAsFixed(0)} days available)',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLeaveType = value);
              },
              validator: (value) {
                if (value == null) return 'Please select leave type';
                return null;
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // Date From
            InkWell(
              onTap: () => _selectDate(true),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'From Date',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _dateFrom != null
                      ? _formatDate(_dateFrom!)
                      : 'Select date',
                  style: TextStyle(
                    color: _dateFrom != null
                        ? null
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Date To
            InkWell(
              onTap: _dateFrom != null ? () => _selectDate(false) : null,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'To Date',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  enabled: _dateFrom != null,
                ),
                child: Text(
                  _dateTo != null
                      ? _formatDate(_dateTo!)
                      : 'Select date',
                  style: TextStyle(
                    color: _dateTo != null
                        ? null
                        : AppColors.textSecondary,
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
