import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Dialog for entering rejection reason
///
/// Requires a minimum of 10 characters for the rejection reason.
/// Returns the reason string if submitted, null if cancelled.
class RejectionReasonDialog extends StatefulWidget {
  const RejectionReasonDialog({super.key});

  @override
  State<RejectionReasonDialog> createState() => _RejectionReasonDialogState();
}

class _RejectionReasonDialogState extends State<RejectionReasonDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static const int _minReasonLength = 10;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.cancel, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          const Text('Reject Leave Request'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejecting this leave request. '
              'The employee will be notified with this reason.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _controller,
              maxLines: 4,
              maxLength: 500,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Rejection Reason',
                hintText: 'Enter the reason for rejection...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a rejection reason';
                }
                if (value.trim().length < _minReasonLength) {
                  return 'Reason must be at least $_minReasonLength characters';
                }
                return null;
              },
              onChanged: (_) => setState(() {}),
            ),
            if (_controller.text.isNotEmpty && _controller.text.length < _minReasonLength)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  '${_minReasonLength - _controller.text.length} more characters required',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.warning,
                      ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _controller.text.length >= _minReasonLength
              ? () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(context, _controller.text.trim());
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: const Text('Reject'),
        ),
      ],
    );
  }
}
