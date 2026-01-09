# KERJAFLOW COMPONENT LIBRARY
## Every Widget, Every State, Every Variation

---

## 1. BUTTON COMPONENTS

### 1.1 Primary Button

```dart
/// KFPrimaryButton
/// Main action button
class KFPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 48, // Touch target
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: KFColors.primary600,
          foregroundColor: Colors.white,
          disabledBackgroundColor: KFColors.gray200,
          disabledForegroundColor: KFColors.gray400,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: KFRadius.radiusLg,
          ),
        ),
        child: _buildContent(),
      ),
    );
  }
}
```

| State | Background | Text | Border |
|-------|------------|------|--------|
| Default | primary-600 | white | none |
| Hover | primary-500 | white | none |
| Pressed | primary-700 | white | none |
| Focused | primary-600 | white | primary-300 (2px) |
| Disabled | gray-200 | gray-400 | none |
| Loading | primary-600 | spinner | none |

### 1.2 Secondary Button

```dart
/// KFSecondaryButton
/// Alternative action
class KFSecondaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: KFColors.primary600,
        side: BorderSide(color: KFColors.primary600),
        padding: EdgeInsets.symmetric(horizontal: 24),
        minimumSize: Size(0, 48),
        shape: RoundedRectangleBorder(
          borderRadius: KFRadius.radiusLg,
        ),
      ),
      child: Text(label),
    );
  }
}
```

### 1.3 Text Button

```dart
/// KFTextButton
/// Tertiary action
class KFTextButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: KFColors.primary600,
        minimumSize: Size(44, 44),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(label),
    );
  }
}
```

### 1.4 Icon Button

```dart
/// KFIconButton
/// Icon-only action
class KFIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: KFRadius.radiusFull,
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: size * 0.5,
              color: onPressed != null 
                ? KFColors.gray700 
                : KFColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}
```

### 1.5 Floating Action Button

```dart
/// KFFAB
/// Primary floating action
class KFFAB extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final bool extended;
  final String? label;
  
  @override
  Widget build(BuildContext context) {
    if (extended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        backgroundColor: KFColors.secondary500,
        foregroundColor: Colors.white,
      );
    }
    
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: KFColors.secondary500,
      foregroundColor: Colors.white,
      child: Icon(icon),
    );
  }
}
```

---

## 2. INPUT COMPONENTS

### 2.1 Text Field

```dart
/// KFTextField
/// Standard text input
class KFTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        errorText: error,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffix: suffix,
        filled: true,
        fillColor: enabled ? Colors.white : KFColors.gray100,
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.gray300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.primary600, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
          borderSide: BorderSide(color: KFColors.error500),
        ),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }
}
```

| State | Border | Background | Label |
|-------|--------|------------|-------|
| Empty | gray-300 | white | gray-500 |
| Focused | primary-600 (2px) | white | primary-600 |
| Filled | gray-400 | white | gray-600 |
| Error | error-500 | white | error-500 |
| Disabled | gray-200 | gray-100 | gray-400 |

### 2.2 Password Field

```dart
/// KFPasswordField
/// Password input with visibility toggle
class KFPasswordField extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return KFTextField(
      label: label,
      obscureText: _obscured,
      suffix: IconButton(
        icon: Icon(
          _obscured ? Icons.visibility_off : Icons.visibility,
          color: KFColors.gray500,
        ),
        onPressed: () => setState(() => _obscured = !_obscured),
      ),
    );
  }
}
```

### 2.3 Dropdown Field

```dart
/// KFDropdown
/// Selection from list
class KFDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? error;
  
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: error,
        border: OutlineInputBorder(
          borderRadius: KFRadius.radiusLg,
        ),
      ),
      icon: Icon(Icons.keyboard_arrow_down),
      dropdownColor: Colors.white,
      borderRadius: KFRadius.radiusLg,
    );
  }
}
```

### 2.4 Date Picker Field

```dart
/// KFDatePicker
/// Date selection
class KFDatePicker extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: firstDate,
          lastDate: lastDate,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: KFColors.primary600,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) onChanged(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: KFRadius.radiusLg,
          ),
        ),
        child: Text(
          value != null 
            ? DateFormat('EEE, d MMM yyyy').format(value!)
            : 'Select date',
        ),
      ),
    );
  }
}
```

---

## 3. CARD COMPONENTS

### 3.1 Standard Card

```dart
/// KFCard
/// Basic card container
class KFCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool elevated;
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: KFRadius.radiusXl,
      elevation: elevated ? 0 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: KFRadius.radiusXl,
        child: Container(
          padding: padding ?? EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: KFRadius.radiusXl,
            border: Border.all(color: KFColors.gray200),
            boxShadow: elevated ? KFShadows.sm : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### 3.2 Payslip Card

```dart
/// KFPayslipCard
/// Monthly payslip preview
class KFPayslipCard extends StatelessWidget {
  final String month;
  final String year;
  final double netAmount;
  final String currencyCode;
  final bool isNew;
  final bool isPaid;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return KFCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NEW badge
          if (isNew)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: KFColors.primary600,
                borderRadius: KFRadius.radiusSm,
              ),
              child: Text(
                'NEW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          
          SizedBox(height: 8),
          
          // Month
          Text(
            month.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: KFColors.gray600,
            ),
          ),
          
          // Year
          Text(
            year,
            style: TextStyle(
              fontSize: 12,
              color: KFColors.gray400,
            ),
          ),
          
          Spacer(),
          
          // Net amount
          Text(
            '$currencyCode ${_formatAmount(netAmount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: KFColors.gray900,
            ),
          ),
          
          SizedBox(height: 8),
          
          // Status
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle : Icons.schedule,
                size: 16,
                color: isPaid ? KFColors.success600 : KFColors.warning600,
              ),
              SizedBox(width: 4),
              Text(
                isPaid ? 'Paid' : 'Processing',
                style: TextStyle(
                  fontSize: 12,
                  color: isPaid ? KFColors.success600 : KFColors.warning600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### 3.3 Leave Balance Card

```dart
/// KFLeaveBalanceCard
/// Leave type balance display
class KFLeaveBalanceCard extends StatelessWidget {
  final String leaveType;
  final IconData icon;
  final Color color;
  final int balance;
  final int total;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? balance / total : 0.0;
    
    return KFCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: KFRadius.radiusMd,
                ),
                child: Icon(icon, color: color),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  leaveType,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16),
          
          // Balance
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$balance',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: KFColors.gray900,
                  ),
                ),
                TextSpan(
                  text: ' / $total days',
                  style: TextStyle(
                    fontSize: 14,
                    color: KFColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: 12),
          
          // Progress bar
          ClipRRect(
            borderRadius: KFRadius.radiusFull,
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: KFColors.gray200,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 4. STATUS COMPONENTS

### 4.1 Status Chip

```dart
/// KFStatusChip
/// Status indicator
class KFStatusChip extends StatelessWidget {
  final String label;
  final StatusType type;
  
  @override
  Widget build(BuildContext context) {
    final config = _getConfig(type);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: KFRadius.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.textColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: config.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

enum StatusType { approved, pending, rejected, cancelled }
```

| Status | Background | Text | Icon |
|--------|------------|------|------|
| Approved | success-100 | success-700 | check_circle |
| Pending | warning-100 | warning-700 | schedule |
| Rejected | error-100 | error-700 | cancel |
| Cancelled | gray-100 | gray-600 | block |

### 4.2 Badge

```dart
/// KFBadge
/// Notification count badge
class KFBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: count > 9 ? 4 : 0,
              ),
              constraints: BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: KFColors.error500,
                shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: count > 9 ? KFRadius.radiusFull : null,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## 5. NAVIGATION COMPONENTS

### 5.1 Bottom Navigation Bar

```dart
/// KFBottomNavBar
/// Main app navigation
class KFBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: KFColors.primary600,
      unselectedItemColor: KFColors.gray500,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_outlined),
          activeIcon: Icon(Icons.receipt_long),
          label: 'Payslip',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note_outlined),
          activeIcon: Icon(Icons.event_note),
          label: 'Leave',
        ),
        BottomNavigationBarItem(
          icon: KFBadge(
            count: unreadCount,
            child: Icon(Icons.notifications_outlined),
          ),
          activeIcon: Icon(Icons.notifications),
          label: 'Inbox',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
```

### 5.2 App Bar

```dart
/// KFAppBar
/// Screen header
class KFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: false,
      leading: showBack
        ? IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: onBack ?? () => Navigator.pop(context),
          )
        : null,
      actions: actions,
    );
  }
  
  @override
  Size get preferredSize => Size.fromHeight(56);
}
```

---

## 6. FEEDBACK COMPONENTS

### 6.1 Snackbar

```dart
/// Show KerjaFlow snackbar
void showKFSnackbar(
  BuildContext context, {
  required String message,
  SnackbarType type = SnackbarType.info,
  Duration duration = const Duration(seconds: 3),
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final config = _getConfig(type);
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(config.icon, color: Colors.white, size: 20),
          SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
      backgroundColor: config.color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: KFRadius.radiusMd,
      ),
      duration: duration,
      action: actionLabel != null
        ? SnackBarAction(
            label: actionLabel,
            textColor: Colors.white,
            onPressed: onAction ?? () {},
          )
        : null,
    ),
  );
}

enum SnackbarType { success, error, warning, info }
```

### 6.2 Empty State

```dart
/// KFEmptyState
/// No data placeholder
class KFEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: KFColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: KFColors.gray400,
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: KFColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              SizedBox(height: 24),
              KFSecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 6.3 Skeleton Loader

```dart
/// KFSkeleton
/// Loading placeholder
class KFSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: KFColors.gray200,
      highlightColor: KFColors.gray100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: KFColors.gray200,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
```

---

## 7. PIN COMPONENTS

### 7.1 PIN Input Display

```dart
/// KFPinDisplay
/// PIN entry dots
class KFPinDisplay extends StatelessWidget {
  final int length;
  final int filled;
  final bool hasError;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filled;
        return Container(
          width: 16,
          height: 16,
          margin: EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasError
              ? KFColors.error500
              : isFilled
                ? KFColors.primary600
                : Colors.transparent,
            border: Border.all(
              color: hasError
                ? KFColors.error500
                : isFilled
                  ? KFColors.primary600
                  : KFColors.gray300,
              width: 2,
            ),
          ),
        );
      }),
    );
  }
}
```

### 7.2 PIN Keypad

```dart
/// KFPinKeypad
/// Number entry pad
class KFPinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row 1-2-3
        _buildRow(['1', '2', '3']),
        SizedBox(height: 16),
        // Row 4-5-6
        _buildRow(['4', '5', '6']),
        SizedBox(height: 16),
        // Row 7-8-9
        _buildRow(['7', '8', '9']),
        SizedBox(height: 16),
        // Row biometric-0-delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showBiometric)
              _buildKey(
                child: Icon(Icons.fingerprint),
                onTap: onBiometric,
              )
            else
              SizedBox(width: 72),
            _buildDigitKey('0'),
            _buildKey(
              child: Icon(Icons.backspace_outlined),
              onTap: onDelete,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDigitKey(String digit) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onDigit(digit),
        borderRadius: KFRadius.radiusFull,
        child: Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: Text(
            digit,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Total Components:** 30+
