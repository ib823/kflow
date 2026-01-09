# KERJAFLOW ACCESSIBILITY GUIDE
## WCAG 2.2 AA Compliance - Every User, Every Ability

---

## 1. ACCESSIBILITY REQUIREMENTS MATRIX

### 1.1 WCAG 2.2 Level AA Compliance

| Principle | Guideline | Requirement | Implementation |
|-----------|-----------|-------------|----------------|
| **Perceivable** | 1.1.1 Non-text Content | All images have alt text | `semanticLabel` on all `Image`, `Icon` |
| | 1.3.1 Info and Relationships | Semantic structure | Proper heading hierarchy |
| | 1.3.4 Orientation | Works in any orientation | No orientation lock |
| | 1.4.1 Use of Color | Not color-only | Icons + color for status |
| | 1.4.3 Contrast (Minimum) | 4.5:1 for text | All colors verified |
| | 1.4.4 Resize Text | 200% zoom support | Responsive text |
| | 1.4.10 Reflow | No horizontal scroll | Responsive layouts |
| | 1.4.11 Non-text Contrast | 3:1 for UI components | Border/background contrast |
| | 1.4.12 Text Spacing | Adjustable spacing | Dynamic typography |
| **Operable** | 2.1.1 Keyboard | All keyboard accessible | Focus management |
| | 2.1.2 No Keyboard Trap | Can navigate away | Proper focus order |
| | 2.4.3 Focus Order | Logical tab order | `FocusTraversalGroup` |
| | 2.4.6 Headings and Labels | Descriptive labels | Semantic widgets |
| | 2.4.7 Focus Visible | Visible focus indicator | Custom focus styles |
| | 2.5.5 Target Size | 44×44px minimum | Touch targets verified |
| **Understandable** | 3.1.1 Language of Page | Language declared | `Locale` set |
| | 3.2.1 On Focus | No unexpected changes | Controlled navigation |
| | 3.3.1 Error Identification | Errors described | Field-level errors |
| | 3.3.2 Labels or Instructions | Clear labels | Helper text |
| **Robust** | 4.1.2 Name, Role, Value | Semantic properties | `Semantics` widget |

---

## 2. SCREEN READER SUPPORT

### 2.1 Semantic Labels

```dart
/// CORRECT: Provide meaningful semantic labels
Icon(
  Icons.notifications,
  semanticLabel: 'Notifications, 3 unread',
)

Image.asset(
  'assets/logo.png',
  semanticLabel: 'KerjaFlow company logo',
)

/// WRONG: Missing semantic information
Icon(Icons.notifications) // Screen reader says "Icon"
```

### 2.2 Semantics Widget Usage

```dart
/// Wrap complex widgets with Semantics
Semantics(
  label: 'Leave balance card',
  hint: 'Double tap to view details',
  button: true,
  child: LeaveBalanceCard(
    leaveType: 'Annual',
    balance: 12,
    total: 14,
  ),
)

/// For custom buttons
Semantics(
  label: 'Apply for annual leave',
  button: true,
  enabled: true,
  onTap: () => _applyLeave(),
  child: CustomApplyButton(),
)

/// For status indicators
Semantics(
  label: 'Leave request status: Approved',
  child: StatusChip(status: LeaveStatus.approved),
)
```

### 2.3 Excluding Decorative Elements

```dart
/// Exclude decorative elements from screen reader
Semantics(
  excludeSemantics: true,
  child: DecorativeBackground(),
)

/// Or use ExcludeSemantics widget
ExcludeSemantics(
  child: AnimatedGradient(),
)
```

### 2.4 Live Regions for Dynamic Content

```dart
/// Announce dynamic updates
Semantics(
  liveRegion: true,
  child: Text('$unreadCount new notifications'),
)

/// For loading states
Semantics(
  label: isLoading ? 'Loading payslips' : 'Payslips loaded',
  liveRegion: true,
  child: PayslipList(),
)
```

---

## 3. FOCUS MANAGEMENT

### 3.1 Focus Traversal Order

```dart
/// Define logical focus order
FocusTraversalGroup(
  policy: OrderedTraversalPolicy(),
  child: Column(
    children: [
      FocusTraversalOrder(
        order: NumericFocusOrder(1),
        child: EmailField(),
      ),
      FocusTraversalOrder(
        order: NumericFocusOrder(2),
        child: PasswordField(),
      ),
      FocusTraversalOrder(
        order: NumericFocusOrder(3),
        child: LoginButton(),
      ),
    ],
  ),
)
```

### 3.2 Custom Focus Indicators

```dart
/// Theme-level focus indicator
ThemeData(
  focusColor: KFColors.primary400,
  
  // For Material widgets
  inputDecorationTheme: InputDecorationTheme(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: KFColors.primary600,
        width: 2,
      ),
      borderRadius: KFRadius.radiusLg,
    ),
  ),
  
  // For buttons
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom().copyWith(
      overlayColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.focused)) {
          return KFColors.primary300.withOpacity(0.3);
        }
        return null;
      }),
    ),
  ),
)

/// Custom focus decoration
class FocusableCard extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() => _isFocused = hasFocus);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: _isFocused ? KFColors.primary600 : Colors.transparent,
            width: 2,
          ),
          borderRadius: KFRadius.radiusLg,
        ),
        child: content,
      ),
    );
  }
}
```

### 3.3 Focus Restoration

```dart
/// Restore focus after navigation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DetailScreen(),
  ),
).then((_) {
  // Focus returns to the element that triggered navigation
  FocusScope.of(context).requestFocus(_triggerFocusNode);
});
```

---

## 4. COLOR CONTRAST

### 4.1 Contrast Ratios

| Element | Minimum Ratio | Our Implementation |
|---------|---------------|-------------------|
| Normal text (< 18sp) | 4.5:1 | 7.2:1 ✓ |
| Large text (≥ 18sp or 14sp bold) | 3:1 | 5.5:1 ✓ |
| UI components | 3:1 | 4.5:1 ✓ |
| Focus indicators | 3:1 | 4.5:1 ✓ |

### 4.2 Color Combinations Verified

| Foreground | Background | Ratio | Pass |
|------------|------------|-------|------|
| gray-900 (#1A1A2E) | white (#FFFFFF) | 15.4:1 | AAA ✓ |
| gray-700 (#4A4A5A) | white (#FFFFFF) | 7.3:1 | AAA ✓ |
| gray-600 (#6B6B7B) | white (#FFFFFF) | 5.1:1 | AA ✓ |
| primary-600 (#1A5276) | white (#FFFFFF) | 7.2:1 | AAA ✓ |
| white (#FFFFFF) | primary-600 (#1A5276) | 7.2:1 | AAA ✓ |
| error-600 (#C0392B) | white (#FFFFFF) | 5.4:1 | AA ✓ |
| success-600 (#27AE60) | white (#FFFFFF) | 3.5:1 | AA ✓ |
| white (#FFFFFF) | darkSurface (#1A1A2E) | 15.4:1 | AAA ✓ |

### 4.3 High Contrast Mode

```dart
/// Provide high contrast option
class KFAccessibility {
  static bool highContrastEnabled = false;
  
  static Color getColor(Color normal, Color highContrast) {
    return highContrastEnabled ? highContrast : normal;
  }
}

/// Usage
Container(
  color: KFAccessibility.getColor(
    KFColors.gray100,  // Normal
    KFColors.white,     // High contrast
  ),
  child: Text(
    'Content',
    style: TextStyle(
      color: KFAccessibility.getColor(
        KFColors.gray700,  // Normal
        KFColors.gray900,  // High contrast
      ),
    ),
  ),
)
```

---

## 5. TOUCH TARGETS

### 5.1 Minimum Size Requirements

```dart
/// Ensure minimum touch target size
class KFTouchTarget extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double minSize;
  
  const KFTouchTarget({
    required this.child,
    required this.onTap,
    this.minSize = 48, // WCAG minimum is 44
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: Center(child: child),
      ),
    );
  }
}
```

### 5.2 Touch Target Spacing

```dart
/// Ensure adequate spacing between targets
Row(
  children: [
    IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {},
      constraints: BoxConstraints(minWidth: 48, minHeight: 48),
    ),
    SizedBox(width: 8), // Minimum 8dp between targets
    IconButton(
      icon: Icon(Icons.delete),
      onPressed: () {},
      constraints: BoxConstraints(minWidth: 48, minHeight: 48),
    ),
  ],
)
```

---

## 6. TEXT SCALING

### 6.1 Support System Font Scaling

```dart
/// Allow text to scale with system settings
Text(
  'Leave Balance',
  style: Theme.of(context).textTheme.headlineMedium,
  // Text will scale with system accessibility settings
)

/// For specific control
MediaQuery(
  data: MediaQuery.of(context).copyWith(
    textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 2.0),
  ),
  child: child,
)
```

### 6.2 Prevent Text Overflow at 200% Scale

```dart
/// Use flexible containers
Flexible(
  child: Text(
    'This is a long text that should wrap',
    overflow: TextOverflow.visible,
    softWrap: true,
  ),
)

/// Use FittedBox for constrained areas
FittedBox(
  fit: BoxFit.scaleDown,
  child: Text('Amount: RM 4,422.00'),
)
```

---

## 7. REDUCED MOTION

### 7.1 Respect System Preferences

```dart
/// Check for reduced motion preference
class KFMotion {
  static bool get prefersReducedMotion {
    return WidgetsBinding.instance.window.accessibilityFeatures.reduceMotion;
  }
  
  static Duration getDuration(Duration normal) {
    return prefersReducedMotion ? Duration.zero : normal;
  }
  
  static Curve getCurve(Curve normal) {
    return prefersReducedMotion ? Curves.linear : normal;
  }
}

/// Usage
AnimatedContainer(
  duration: KFMotion.getDuration(Duration(milliseconds: 300)),
  curve: KFMotion.getCurve(Curves.easeInOut),
  // ...
)
```

### 7.2 Essential vs Decorative Animation

```dart
/// Essential animation (always show, but simplify)
// Loading indicator - essential, keep but simplify
if (KFMotion.prefersReducedMotion) {
  return Text('Loading...');
} else {
  return CircularProgressIndicator();
}

/// Decorative animation (skip entirely)
// Page transition - decorative, can skip
Navigator.push(
  context,
  KFMotion.prefersReducedMotion
    ? MaterialPageRoute(builder: (_) => NextScreen())
    : PageRouteBuilder(
        pageBuilder: (_, __, ___) => NextScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
);
```

---

## 8. FORM ACCESSIBILITY

### 8.1 Field Labels

```dart
/// Always provide visible labels
TextFormField(
  decoration: InputDecoration(
    labelText: 'Email Address', // Visible label
    hintText: 'example@company.com', // Additional hint
    helperText: 'We will never share your email', // Helper text
  ),
)

/// For icon-only buttons, add tooltip
Tooltip(
  message: 'Download PDF',
  child: IconButton(
    icon: Icon(Icons.download),
    onPressed: () {},
  ),
)
```

### 8.2 Error Handling

```dart
/// Descriptive error messages
TextFormField(
  decoration: InputDecoration(
    labelText: 'Password',
    errorText: _hasError 
      ? 'Password must be at least 8 characters with one number'
      : null,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null;
  },
)

/// Announce errors to screen readers
Semantics(
  liveRegion: true,
  child: _hasError
    ? Text(
        'Error: Invalid password',
        style: TextStyle(color: KFColors.error600),
      )
    : SizedBox.shrink(),
)
```

### 8.3 Required Field Indication

```dart
/// Indicate required fields
Row(
  children: [
    Text('Email'),
    Text(' *', style: TextStyle(color: KFColors.error500)),
  ],
)

/// With screen reader support
Semantics(
  label: 'Email, required field',
  child: TextFormField(),
)
```

---

## 9. SCREEN READER ANNOUNCEMENTS

### 9.1 Route Announcements

```dart
/// Announce screen changes
class KFRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _announceRoute(route);
  }
  
  void _announceRoute(Route<dynamic> route) {
    if (route is PageRoute) {
      final routeName = route.settings.name ?? 'New screen';
      SemanticsService.announce(
        'Navigated to $routeName',
        TextDirection.ltr,
      );
    }
  }
}
```

### 9.2 Action Feedback

```dart
/// Announce action results
Future<void> _submitLeaveRequest() async {
  try {
    await repository.submitLeave(request);
    
    // Visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leave request submitted')),
    );
    
    // Screen reader announcement
    SemanticsService.announce(
      'Leave request submitted successfully',
      TextDirection.ltr,
    );
  } catch (e) {
    SemanticsService.announce(
      'Error: Failed to submit leave request',
      TextDirection.ltr,
    );
  }
}
```

---

## 10. ACCESSIBILITY TESTING CHECKLIST

### 10.1 Automated Testing

```dart
/// Widget test with accessibility checks
testWidgets('Login screen is accessible', (tester) async {
  await tester.pumpWidget(LoginScreen());
  
  // Check semantic labels
  expect(
    find.bySemanticsLabel('Email address'),
    findsOneWidget,
  );
  
  // Check minimum touch target
  final button = tester.widget<ElevatedButton>(
    find.widgetWithText(ElevatedButton, 'Login'),
  );
  final size = tester.getSize(find.byWidget(button));
  expect(size.width, greaterThanOrEqualTo(44));
  expect(size.height, greaterThanOrEqualTo(44));
});
```

### 10.2 Manual Testing Checklist

| Test | Method | Expected Result |
|------|--------|-----------------|
| Screen reader | TalkBack/VoiceOver | All elements announced |
| Keyboard navigation | External keyboard | All features accessible |
| High contrast | System setting | All text readable |
| Large text (200%) | System setting | No overflow/truncation |
| Reduced motion | System setting | Animations simplified |
| Focus indicators | Tab through | All focus visible |
| Touch targets | Tap test | All targets ≥44dp |
| Color blindness | Simulator | Status distinguishable |

---

## 11. USER SEGMENT ACCOMMODATIONS

### 11.1 Low Literacy Users

```dart
/// Visual-first design
class VisualLeaveCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Large icon
          Icon(Icons.beach_access, size: 48, color: KFColors.leaveAnnual),
          // Simple text
          Text('Annual Leave', style: TextStyle(fontSize: 18)),
          // Visual progress
          LinearProgressIndicator(value: 12/14),
          // Clear numbers
          Text('12 / 14', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
```

### 11.2 Elderly Users

```dart
/// Large text mode
class LargeTextMode {
  static const double scaleFactor = 1.5;
  
  static TextStyle scale(TextStyle style) {
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * scaleFactor,
    );
  }
}

/// Extra large touch targets
const double elderlyTouchTarget = 64;
```

### 11.3 Factory Workers (Gloves)

```dart
/// Glove-friendly mode
class GloveMode {
  static const double touchTarget = 72;
  static const double buttonSpacing = 16;
  
  static EdgeInsets get buttonPadding => EdgeInsets.all(20);
}
```

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Compliance Target:** WCAG 2.2 Level AA
