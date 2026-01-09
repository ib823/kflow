import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';

/// Standard text field
class KFTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  const KFTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onTap: onTap,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(
        fontSize: KFTypography.fontSizeBase,
        color: KFColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: error,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        prefix: prefix,
        suffix: suffix,
      ),
    );
  }
}

/// Password field with visibility toggle
class KFPasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;

  const KFPasswordField({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.validator,
  });

  @override
  State<KFPasswordField> createState() => _KFPasswordFieldState();
}

class _KFPasswordFieldState extends State<KFPasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscured,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      style: const TextStyle(
        fontSize: KFTypography.fontSizeBase,
        color: KFColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: widget.label ?? 'Password',
        hintText: widget.hint,
        errorText: widget.error,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscured ? Icons.visibility_off : Icons.visibility,
            color: KFColors.gray500,
            size: KFIconSizes.md,
          ),
          onPressed: () => setState(() => _obscured = !_obscured),
        ),
      ),
    );
  }
}

/// Search field
class KFSearchField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  const KFSearchField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  @override
  State<KFSearchField> createState() => _KFSearchFieldState();
}

class _KFSearchFieldState extends State<KFSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: KFTypography.fontSizeBase),
      decoration: InputDecoration(
        hintText: widget.hint ?? 'Search...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _hasText
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  widget.onClear?.call();
                },
              )
            : null,
        filled: true,
        fillColor: KFColors.gray100,
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusFull,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusFull,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusFull,
          borderSide: const BorderSide(color: KFColors.primary600, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KFSpacing.space4,
          vertical: KFSpacing.space3,
        ),
      ),
    );
  }
}

/// Dropdown field
class KFDropdown<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? error;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const KFDropdown({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.value,
    required this.items,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
      ),
      icon: const Icon(Icons.keyboard_arrow_down),
      dropdownColor: Theme.of(context).cardTheme.color,
      borderRadius: KFRadius.radiusLg,
      style: const TextStyle(
        fontFamily: KFTypography.fontFamily,
        fontSize: KFTypography.fontSizeBase,
        color: KFColors.gray900,
      ),
    );
  }
}

/// Date picker field
class KFDatePicker extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? error;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onChanged;
  final bool enabled;

  const KFDatePicker({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () async {
              final date = await showDatePicker(
                context: context,
                initialDate: value ?? DateTime.now(),
                firstDate: firstDate ?? DateTime(2020),
                lastDate: lastDate ?? DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: KFColors.primary600,
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                onChanged?.call(date);
              }
            }
          : null,
      borderRadius: KFRadius.radiusLg,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: error,
          suffixIcon: const Icon(Icons.calendar_today),
          enabled: enabled,
        ),
        child: Text(
          value != null
              ? '${value!.day}/${value!.month}/${value!.year}'
              : hint ?? 'Select date',
          style: TextStyle(
            color: value != null ? KFColors.gray900 : KFColors.gray400,
          ),
        ),
      ),
    );
  }
}

/// Date range picker field
class KFDateRangePicker extends StatelessWidget {
  final String? label;
  final String? error;
  final DateTimeRange? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTimeRange>? onChanged;
  final bool enabled;

  const KFDateRangePicker({
    super.key,
    this.label,
    this.error,
    this.value,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () async {
              final range = await showDateRangePicker(
                context: context,
                initialDateRange: value,
                firstDate: firstDate ?? DateTime(2020),
                lastDate: lastDate ?? DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                            primary: KFColors.primary600,
                          ),
                    ),
                    child: child!,
                  );
                },
              );
              if (range != null) {
                onChanged?.call(range);
              }
            }
          : null,
      borderRadius: KFRadius.radiusLg,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          suffixIcon: const Icon(Icons.date_range),
          enabled: enabled,
        ),
        child: Text(
          value != null
              ? '${_formatDate(value!.start)} - ${_formatDate(value!.end)}'
              : 'Select date range',
          style: TextStyle(
            color: value != null ? KFColors.gray900 : KFColors.gray400,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Text area for multi-line input
class KFTextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? error;
  final TextEditingController? controller;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  const KFTextArea({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.controller,
    this.minLines = 3,
    this.maxLines = 5,
    this.maxLength,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: KFTypography.fontSizeBase,
        color: KFColors.gray900,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: error,
        alignLabelWithHint: true,
      ),
    );
  }
}
