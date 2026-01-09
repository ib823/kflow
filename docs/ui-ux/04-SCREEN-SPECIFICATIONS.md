# KERJAFLOW SCREEN SPECIFICATIONS
## All 27 Screens - Pixel Perfect - All States

---

## SCREEN INVENTORY

| ID | Screen | Category | Access Level |
|----|--------|----------|--------------|
| S-001 | Splash | Auth | All |
| S-002 | Login | Auth | Unauthenticated |
| S-003 | PIN Setup | Auth | New Users |
| S-004 | PIN Entry | Auth | Returning |
| S-005 | Forgot Password | Auth | Unauthenticated |
| S-006 | Reset Password | Auth | Unauthenticated |
| S-010 | Dashboard | Home | Authenticated |
| S-020 | Payslip List | Payslip | Authenticated |
| S-021 | Payslip Detail | Payslip | PIN Verified |
| S-022 | Payslip PDF | Payslip | PIN Verified |
| S-030 | Leave Balance | Leave | Authenticated |
| S-031 | Leave History | Leave | Authenticated |
| S-032 | Leave Apply | Leave | Authenticated |
| S-033 | Leave Detail | Leave | Authenticated |
| S-034 | Leave Calendar | Leave | Authenticated |
| S-040 | Approval List | Approvals | Supervisor+ |
| S-041 | Approval Detail | Approvals | Supervisor+ |
| S-050 | Notification List | Notifications | Authenticated |
| S-051 | Notification Detail | Notifications | Authenticated |
| S-060 | Document List | Documents | Authenticated |
| S-061 | Document Upload | Documents | Authenticated |
| S-062 | Document Viewer | Documents | Authenticated |
| S-070 | Profile View | Profile | Authenticated |
| S-071 | Profile Edit | Profile | Authenticated |
| S-072 | Change Password | Settings | Authenticated |
| S-073 | Change PIN | Settings | Authenticated |
| S-080 | Settings | Settings | Authenticated |
| S-081 | Language Selection | Settings | Authenticated |
| S-082 | About | Settings | Authenticated |

---

## SCREEN STATES MATRIX

Every screen must support these states:

| State | Description | Visual Treatment |
|-------|-------------|------------------|
| Loading | Data being fetched | Skeleton shimmer |
| Success | Data loaded | Normal content |
| Empty | No data available | Illustration + CTA |
| Error | Load failed | Error message + retry |
| Offline | No connection | Cached data + banner |
| Refreshing | Pull to refresh | Refresh indicator |

---

## S-001: SPLASH SCREEN

### Layout Specification

```
┌─────────────────────────────────┐
│          Status Bar             │ 44-59pt
├─────────────────────────────────┤
│                                 │
│                                 │
│                                 │
│         ┌─────────┐             │
│         │  LOGO   │             │ 120×120dp
│         └─────────┘             │
│                                 │
│        KerjaFlow                │ displayMedium
│                                 │
│         ●●●○○○                  │ Loading dots
│                                 │
│                                 │
│                                 │
├─────────────────────────────────┤
│      "Powered by Company"       │ bodySmall, gray-500
└─────────────────────────────────┘
```

### Specifications

| Element | Property | Value |
|---------|----------|-------|
| Background | Color | #FFFFFF (light) / #0F0F1A (dark) |
| Logo | Size | 120×120dp |
| Logo | Position | Centered, 40% from top |
| App Name | Font | displayMedium (36sp) |
| App Name | Color | primary-600 |
| Loading Indicator | Type | 6 dots animation |
| Loading Indicator | Color | primary-400 |
| Duration | Min | 1500ms |
| Duration | Max | 3000ms (with network check) |

### Animation Sequence

```dart
// Splash animation timeline
1. 0ms:     Logo fade in (300ms)
2. 300ms:   Logo scale 0.8 → 1.0 (spring, 500ms)
3. 500ms:   App name fade in (200ms)
4. 800ms:   Loading dots start
5. 1500ms+: Transition to next screen
```

---

## S-002: LOGIN SCREEN

### Layout Specification (Phone)

```
┌─────────────────────────────────┐
│          Status Bar             │
├─────────────────────────────────┤
│                                 │
│         ┌─────────┐             │
│         │  LOGO   │             │ 100×100dp
│         └─────────┘             │
│                                 │
│       Welcome Back              │ headlineLarge
│    Sign in to continue          │ bodyMedium, gray-600
│                                 │
│  ┌───────────────────────────┐  │
│  │ 👤 Email or Employee No   │  │ Input field
│  └───────────────────────────┘  │
│                                 │ space-4
│  ┌───────────────────────────┐  │
│  │ 🔒 Password           👁  │  │ Input + toggle
│  └───────────────────────────┘  │
│                                 │
│            Forgot Password? →   │ textButton, right-aligned
│                                 │
│  ┌───────────────────────────┐  │
│  │         LOGIN             │  │ Primary button
│  └───────────────────────────┘  │
│                                 │
│                                 │
│  ───────── or continue with ─────│ Divider + text
│                                 │
│  ┌─────┐  ┌─────┐  ┌─────┐     │
│  │ 🍎  │  │  G  │  │ HMS │     │ Social buttons
│  └─────┘  └─────┘  └─────┘     │
│                                 │
└─────────────────────────────────┘
```

### Layout Specification (Tablet)

```
┌──────────────────────────────────────────────────────────┐
│                       Status Bar                          │
├────────────────────────┬─────────────────────────────────┤
│                        │                                  │
│   ┌────────────────┐   │        Welcome Back              │
│   │                │   │     Sign in to continue          │
│   │   BRANDING     │   │                                  │
│   │   ILLUSTRATION │   │  ┌───────────────────────────┐   │
│   │                │   │  │ Email or Employee No      │   │
│   │                │   │  └───────────────────────────┘   │
│   │                │   │                                  │
│   │                │   │  ┌───────────────────────────┐   │
│   │                │   │  │ Password                  │   │
│   │                │   │  └───────────────────────────┘   │
│   │                │   │                                  │
│   │                │   │         Forgot Password? →       │
│   │                │   │                                  │
│   └────────────────┘   │  ┌───────────────────────────┐   │
│                        │  │         LOGIN             │   │
│                        │  └───────────────────────────┘   │
│                        │                                  │
└────────────────────────┴─────────────────────────────────┘
```

### Input Field Specifications

| State | Border | Background | Icon | Label |
|-------|--------|------------|------|-------|
| Default | gray-300 | white | gray-400 | gray-600 |
| Focused | primary-600 (2px) | primary-50 | primary-600 | primary-600 |
| Filled | gray-300 | white | gray-600 | gray-600 |
| Error | error-500 (2px) | error-50 | error-500 | error-500 |
| Disabled | gray-200 | gray-100 | gray-300 | gray-400 |

### Validation Rules

| Field | Rule | Error Message |
|-------|------|---------------|
| Email | Required | "Email is required" |
| Email | Format | "Invalid email format" |
| Email | Employee No | Also accepts EMP#### format |
| Password | Required | "Password is required" |
| Password | Min length | "Password must be at least 8 characters" |

### Error States

```dart
// Invalid credentials
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Invalid email or password'),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
  ),
);

// Account locked
showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Account Locked'),
    content: Text('Too many failed attempts. Try again in 15 minutes.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text('OK'),
      ),
    ],
  ),
);
```

---

## S-010: DASHBOARD

### Layout Specification (Phone)

```
┌─────────────────────────────────┐
│ Logo              🔔(3)  👤     │ App bar
├─────────────────────────────────┤
│                                 │
│ Good morning, Ahmad! 👋         │ Greeting
│ Tuesday, 9 Jan 2026             │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  Leave Balance   12 days    │ │ Quick stat card
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │  📄 Latest Payslip    NEW   │ │
│ │  December 2025              │ │
│ │  Net: RM 4,422.00      →    │ │
│ └─────────────────────────────┘ │
│                                 │
│ Recent Leave                    │
│ ┌─────────────────────────────┐ │
│ │ 🏖 Annual   2-3 Jan  ✓      │ │
│ │ 🏥 Medical  27 Dec   ✓      │ │
│ └─────────────────────────────┘ │
│                                 │
│ Upcoming Holiday                │
│ ┌─────────────────────────────┐ │
│ │ 🎊 Thaipusam                │ │
│ │    29 January 2026          │ │
│ └─────────────────────────────┘ │
│                                 │
├─────────────────────────────────┤
│ 🏠    📄    📅    🔔    👤     │ Bottom nav
└─────────────────────────────────┘
```

### Dashboard Cards

#### Greeting Card
```dart
Container(
  padding: EdgeInsets.all(16),
  child: Row(
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(), // Good morning/afternoon/evening
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Ahmad Bin Mohd 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      Spacer(),
      CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(profilePhotoUrl),
      ),
    ],
  ),
)
```

#### Quick Stats Row
```dart
Row(
  children: [
    Expanded(
      child: QuickStatCard(
        icon: Icons.event_note,
        iconColor: Colors.green,
        label: 'Leave',
        value: '12',
        unit: 'days',
      ),
    ),
    SizedBox(width: 12),
    Expanded(
      child: QuickStatCard(
        icon: Icons.pending_actions,
        iconColor: Colors.orange,
        label: 'Pending',
        value: '2',
        unit: 'requests',
      ),
    ),
    if (isManager) ...[
      SizedBox(width: 12),
      Expanded(
        child: QuickStatCard(
          icon: Icons.approval,
          iconColor: Colors.blue,
          label: 'Approvals',
          value: '5',
          unit: 'waiting',
          badge: true,
        ),
      ),
    ],
  ],
)
```

---

## S-020: PAYSLIP LIST

### Layout (Phone - Grid)

```
┌─────────────────────────────────┐
│ ←  Payslips           2025 ▼   │ App bar + year filter
├─────────────────────────────────┤
│                                 │
│ ┌─────────┐  ┌─────────┐       │
│ │  DEC    │  │  NOV    │       │
│ │  2025   │  │  2025   │       │
│ │ RM4,422 │  │ RM4,422 │       │
│ │   ✓     │  │   ✓     │       │
│ └─────────┘  └─────────┘       │
│                                 │
│ ┌─────────┐  ┌─────────┐       │
│ │  OCT    │  │  SEP    │       │
│ │  2025   │  │  2025   │       │
│ │ RM4,422 │  │ RM4,500 │       │
│ │   ✓     │  │   ✓     │       │
│ └─────────┘  └─────────┘       │
│                                 │
│ ... scrollable ...              │
│                                 │
├─────────────────────────────────┤
│ 🏠    📄    📅    🔔    👤     │
└─────────────────────────────────┘
```

### Payslip Card Component

```dart
class PayslipCard extends StatelessWidget {
  final Payslip payslip;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isNew ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: isNew ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NEW badge
            if (isNew)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
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
              payslip.monthName.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            
            // Year
            Text(
              payslip.year.toString(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            
            Spacer(),
            
            // Net amount
            Text(
              payslip.formattedNetAmount,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[900],
              ),
            ),
            
            SizedBox(height: 8),
            
            // Status
            Row(
              children: [
                Icon(
                  payslip.isPaid ? Icons.check_circle : Icons.schedule,
                  size: 16,
                  color: payslip.isPaid ? Colors.green : Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  payslip.isPaid ? 'Paid' : 'Processing',
                  style: TextStyle(
                    fontSize: 12,
                    color: payslip.isPaid ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Grid Configuration

| Screen Size | Columns | Card Aspect | Spacing |
|-------------|---------|-------------|---------|
| Phone (<600) | 2 | 1:1.2 | 12dp |
| Tablet (600-900) | 3 | 1:1.1 | 16dp |
| Tablet (900+) | 4 | 1:1.0 | 20dp |
| Desktop | 5+ | 1:0.9 | 24dp |

---

## S-021: PAYSLIP DETAIL

### Layout Specification

```
┌─────────────────────────────────┐
│ ←  December 2025    📤   📥    │ Back, Share, Download
├─────────────────────────────────┤
│                                 │
│ ┌─────────────────────────────┐ │
│ │ Ahmad Bin Mohd              │ │ Employee header
│ │ EMP001234 | Production      │ │
│ │ Production Operator         │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │         SUMMARY             │ │
│ │ ─────────────────────────── │ │
│ │ Gross Salary    RM 5,000.00 │ │
│ │ Deductions     -RM   578.00 │ │
│ │ ─────────────────────────── │ │
│ │ Net Pay        RM 4,422.00  │ │ Large, primary color
│ └─────────────────────────────┘ │
│                                 │
│ Earnings                    ▼   │ Expandable section
│ ┌─────────────────────────────┐ │
│ │ Basic Salary    RM 4,000.00 │ │
│ │ Shift Allow.    RM   500.00 │ │
│ │ Transport       RM   300.00 │ │
│ │ Attendance      RM   200.00 │ │
│ └─────────────────────────────┘ │
│                                 │
│ Deductions                  ▼   │
│ ┌─────────────────────────────┐ │
│ │ EPF (11%)       RM   550.00 │ │
│ │ SOCSO           RM    19.75 │ │
│ │ EIS             RM     8.00 │ │
│ │ PCB             RM     0.00 │ │
│ └─────────────────────────────┘ │
│                                 │
│ Statutory (Employee/Employer)   │
│ ┌─────────────────────────────┐ │
│ │ EPF     RM 550 / RM 650     │ │
│ │ SOCSO   RM  20 / RM  70     │ │
│ │ EIS     RM   8 / RM   8     │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │     View PDF Payslip    →   │ │ Action button
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

### Summary Card Specification

```dart
Container(
  padding: EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF1A5276),
        Color(0xFF2E86AB),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    children: [
      Text('SUMMARY', style: labelStyle.copyWith(color: Colors.white70)),
      SizedBox(height: 16),
      _buildRow('Gross Salary', grossAmount, Colors.white),
      _buildRow('Deductions', '-$deductionAmount', Colors.red[200]!),
      Divider(color: Colors.white30),
      _buildRow('Net Pay', netAmount, Colors.white, isLarge: true),
    ],
  ),
)
```

---

## S-032: LEAVE APPLY

### Layout Specification

```
┌─────────────────────────────────┐
│ ✕  Apply Leave          Submit │ Modal header
├─────────────────────────────────┤
│                                 │
│ Leave Type                      │
│ ┌───────────────────────────▼─┐ │
│ │ Annual Leave (12 days left) │ │ Dropdown
│ └─────────────────────────────┘ │
│                                 │
│ From Date                       │
│ ┌───────────────────────────📅┐ │
│ │ Mon, 13 Jan 2026            │ │ Date picker
│ └─────────────────────────────┘ │
│                                 │
│ To Date                         │
│ ┌───────────────────────────📅┐ │
│ │ Tue, 14 Jan 2026            │ │ Date picker
│ └─────────────────────────────┘ │
│                                 │
│ ☐ Half Day                      │ Checkbox (single day only)
│                                 │
│ Reason (Optional)               │
│ ┌─────────────────────────────┐ │
│ │                             │ │
│ │ Family vacation             │ │ Text area
│ │                             │ │
│ └─────────────────────────────┘ │
│ 85/500 characters               │
│                                 │
│ Attachment                      │
│ ┌─────────────────────────────┐ │
│ │ 📷  📁  Upload Document     │ │ Only if required
│ └─────────────────────────────┘ │
│                                 │
│ ═════════════════════════════   │
│                                 │
│ Summary                         │
│ ┌─────────────────────────────┐ │
│ │ Working days: 2             │ │
│ │ Approver: Encik Ali         │ │
│ │ Balance after: 10 days      │ │
│ └─────────────────────────────┘ │
│                                 │
└─────────────────────────────────┘
```

### Leave Type Dropdown

```dart
class LeaveTypeDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<LeaveType>(
      decoration: InputDecoration(
        labelText: 'Leave Type',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: leaveTypes.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: type.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(type.icon, color: type.color, size: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(type.name),
                    Text(
                      '${type.balance} days remaining',
                      style: TextStyle(
                        fontSize: 12,
                        color: type.balance > 0 
                          ? Colors.grey[600] 
                          : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }
}
```

### Validation Rules

| Field | Rule | Error |
|-------|------|-------|
| Leave Type | Required | "Please select leave type" |
| From Date | Required | "Please select start date" |
| From Date | Not past | "Cannot apply for past dates" |
| To Date | Required | "Please select end date" |
| To Date | >= From | "End date must be after start date" |
| Balance | Sufficient | "Insufficient leave balance" |
| Attachment | Required for MC | "Medical certificate required" |

---

## COMPONENT STATES REFERENCE

### Button States

| State | Background | Text | Border | Opacity |
|-------|------------|------|--------|---------|
| Default | primary-600 | white | none | 1.0 |
| Hover | primary-500 | white | none | 1.0 |
| Pressed | primary-700 | white | none | 1.0 |
| Focused | primary-600 | white | primary-300 (2px) | 1.0 |
| Disabled | gray-200 | gray-400 | none | 0.5 |
| Loading | primary-600 | spinner | none | 1.0 |

### Input Field States

| State | Border | Background | Label | Helper |
|-------|--------|------------|-------|--------|
| Empty | gray-300 | white | gray-500 | gray-500 |
| Focused | primary-600 | primary-50 | primary-600 | gray-500 |
| Filled | gray-400 | white | gray-600 | gray-500 |
| Error | error-500 | error-50 | error-500 | error-500 |
| Success | success-500 | success-50 | success-500 | success-500 |
| Disabled | gray-200 | gray-100 | gray-400 | gray-400 |
| Read-only | gray-200 | gray-50 | gray-500 | gray-500 |

### Card States

| State | Shadow | Border | Background | Scale |
|-------|--------|--------|------------|-------|
| Default | shadow-sm | none | white | 1.0 |
| Hover | shadow-md | none | white | 1.0 |
| Pressed | shadow-xs | none | gray-50 | 0.98 |
| Selected | shadow-md | primary-600 | primary-50 | 1.0 |
| Disabled | none | gray-200 | gray-100 | 1.0 |

---

## EMPTY STATES

### No Payslips

```
┌─────────────────────────────────┐
│                                 │
│         📄                      │ 80×80 illustration
│      ╱    ╲                     │
│     ╱      ╲                    │
│                                 │
│    No Payslips Yet              │ headlineMedium
│                                 │
│  Your payslips will appear      │ bodyMedium, gray-600
│  here once processed.           │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### No Notifications

```
┌─────────────────────────────────┐
│                                 │
│         🔔                      │ 80×80 illustration
│         zzz                     │
│                                 │
│   All Caught Up!                │ headlineMedium
│                                 │
│  You have no new                │ bodyMedium, gray-600
│  notifications.                 │
│                                 │
│                                 │
└─────────────────────────────────┘
```

### No Leave Balance

```
┌─────────────────────────────────┐
│                                 │
│         📅                      │ 80×80 illustration
│          0                      │
│                                 │
│   No Leave Balance              │ headlineMedium
│                                 │
│  Contact HR to set up           │ bodyMedium, gray-600
│  your leave entitlements.       │
│                                 │
│  ┌─────────────────────────┐    │
│  │     Contact HR          │    │ Secondary button
│  └─────────────────────────┘    │
│                                 │
└─────────────────────────────────┘
```

---

## ERROR STATES

### Network Error

```
┌─────────────────────────────────┐
│                                 │
│         📡                      │ 80×80 illustration
│          ✕                      │
│                                 │
│   Connection Failed             │ headlineMedium
│                                 │
│  Unable to connect to server.   │ bodyMedium, gray-600
│  Please check your internet.    │
│                                 │
│  ┌─────────────────────────┐    │
│  │       Try Again         │    │ Primary button
│  └─────────────────────────┘    │
│                                 │
│       Use Offline Mode          │ Text button
│                                 │
└─────────────────────────────────┘
```

### Server Error

```
┌─────────────────────────────────┐
│                                 │
│         🔧                      │ 80×80 illustration
│                                 │
│   Something Went Wrong          │ headlineMedium
│                                 │
│  We're having technical         │ bodyMedium, gray-600
│  difficulties. Try again.       │
│                                 │
│  Error code: ERR_500            │ bodySmall, gray-400
│                                 │
│  ┌─────────────────────────┐    │
│  │       Try Again         │    │ Primary button
│  └─────────────────────────┘    │
│                                 │
│       Report Problem            │ Text button
│                                 │
└─────────────────────────────────┘
```

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Total Screens:** 27
**Total States Per Screen:** 6 minimum
