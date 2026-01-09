# KERJAFLOW PLATFORM SPECIFICATIONS
## All Devices, All Platforms, Pixel-Perfect

---

## 1. MOBILE PHONES

### 1.1 iOS (iPhone)

| Model | Screen Size | Resolution | Scale | Safe Areas |
|-------|-------------|------------|-------|------------|
| iPhone SE (3rd) | 4.7" | 750×1334 | 2x | Top: 20, Bottom: 0 |
| iPhone 14 | 6.1" | 1170×2532 | 3x | Top: 47, Bottom: 34 |
| iPhone 14 Plus | 6.7" | 1284×2778 | 3x | Top: 47, Bottom: 34 |
| iPhone 14 Pro | 6.1" | 1179×2556 | 3x | Top: 59, Bottom: 34 |
| iPhone 14 Pro Max | 6.7" | 1290×2796 | 3x | Top: 59, Bottom: 34 |
| iPhone 15 | 6.1" | 1179×2556 | 3x | Top: 59, Bottom: 34 |
| iPhone 15 Pro Max | 6.7" | 1290×2796 | 3x | Top: 59, Bottom: 34 |

**iOS-Specific Requirements:**
```dart
// Safe area handling
SafeArea(
  top: true,
  bottom: true,
  child: content,
)

// Dynamic Island awareness
MediaQuery.of(context).viewPadding.top // Returns 59 for Pro models

// Home indicator padding
MediaQuery.of(context).viewPadding.bottom // Returns 34
```

**iOS Design Rules:**
- Navigation bar height: 44pt
- Tab bar height: 49pt (83pt with home indicator)
- Large title navigation: 96pt
- System font: SF Pro (use -apple-system)
- Haptic feedback: Use UIFeedbackGenerator
- No back button text (use chevron.left icon only)

### 1.2 Android Phones

| Category | Examples | Resolution Range | Density |
|----------|----------|------------------|---------|
| Small | Galaxy A14 | 720×1600 | hdpi-xhdpi |
| Medium | Pixel 7 | 1080×2400 | xxhdpi |
| Large | Galaxy S24 | 1080×2340 | xxhdpi |
| XL | Galaxy S24 Ultra | 1440×3088 | xxxhdpi |
| Foldable Inner | Galaxy Z Fold | 1812×2176 | xxxhdpi |
| Foldable Cover | Galaxy Z Fold | 904×2316 | xxxhdpi |

**Android-Specific Requirements:**
```dart
// Handle display cutouts
SystemChrome.setEnabledSystemUIMode(
  SystemUiMode.edgeToEdge,
);

// Bottom navigation handling
NavigationBarTheme(
  data: NavigationBarThemeData(
    height: 80, // Material 3 spec
  ),
)

// Foldable awareness
MediaQuery.of(context).displayFeatures // Check for hinges/folds
```

**Android Design Rules:**
- Navigation bar: 80dp (Material 3)
- Status bar: 24dp (up to 48dp with cutout)
- FAB size: 56dp standard, 96dp expanded
- Touch ripple: MaterialStateProperty
- System font: Roboto (use sans-serif)

### 1.3 HUAWEI Phones (HMS)

| Model | Screen Size | Resolution | HMS Version |
|-------|-------------|------------|-------------|
| Mate 60 Pro | 6.82" | 1260×2720 | HMS Core 6.12+ |
| Mate X5 (Folded) | 6.4" | 1080×2504 | HMS Core 6.12+ |
| Mate X5 (Unfolded) | 7.85" | 2200×2480 | HMS Core 6.12+ |
| nova 12 | 6.7" | 1080×2412 | HMS Core 6.10+ |
| P60 Pro | 6.67" | 1220×2700 | HMS Core 6.10+ |

**Huawei HMS-Specific Requirements:**
```yaml
# pubspec.yaml
dependencies:
  huawei_push: ^6.12.0
  huawei_account: ^6.4.0
  huawei_analytics: ^6.12.0
  huawei_location: ^6.4.0
```

```dart
// HMS Push Kit integration
import 'package:huawei_push/huawei_push.dart';

// HMS Account Kit (instead of Google Sign-In)
import 'package:huawei_account/huawei_account.dart';

// HMS Analytics
import 'package:huawei_analytics/huawei_analytics.dart';

// Check HMS availability
HmsApiAvailability.isHmsAvailable().then((status) {
  if (status == 0) {
    // HMS available
  }
});
```

**Huawei Design Rules:**
- Follow EMUI design guidelines
- Use Huawei Sans font on EMUI
- Support HarmonyOS NEXT when available
- AppGallery icon requirements: 216×216 PNG
- Handle Huawei-specific display cutouts
- Test on Huawei devices (mandatory before release)

---

## 2. TABLETS

### 2.1 iPad (iPadOS)

| Model | Screen Size | Resolution | Split View |
|-------|-------------|------------|------------|
| iPad (10th gen) | 10.9" | 2360×1640 | Yes |
| iPad Air | 10.9" | 2360×1640 | Yes |
| iPad Pro 11" | 11" | 2388×1668 | Yes |
| iPad Pro 12.9" | 12.9" | 2732×2048 | Yes |
| iPad mini | 8.3" | 2266×1488 | Yes |

**iPad Layout Specifications:**

```dart
// Responsive layout for iPad
class AdaptiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width >= 1024) {
      // iPad Pro landscape - 3 column
      return ThreeColumnLayout();
    } else if (width >= 768) {
      // iPad portrait - 2 column
      return TwoColumnLayout();
    } else {
      // Compact - single column
      return SingleColumnLayout();
    }
  }
}

// Two column master-detail
class TwoColumnLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 320, // Fixed sidebar width
          child: MasterList(),
        ),
        Expanded(
          child: DetailView(),
        ),
      ],
    );
  }
}
```

**iPad Split View Support:**
```dart
// Minimum supported widths
const double minimumSplitWidth = 320; // 1/3 screen
const double minimumFullWidth = 507;  // 1/2 screen
const double minimumExpandedWidth = 678; // 2/3 screen

// Handle size class changes
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 1024) {
      return RegularLayout(); // Full features
    } else if (constraints.maxWidth >= 507) {
      return CompactLayout(); // Reduced features
    } else {
      return MinimalLayout(); // Essential only
    }
  },
)
```

### 2.2 Android Tablets

| Category | Examples | Resolution | Aspect Ratio |
|----------|----------|------------|--------------|
| Small | Galaxy Tab A8 | 1920×1200 | 16:10 |
| Medium | Galaxy Tab S9 | 2560×1600 | 16:10 |
| Large | Galaxy Tab S9+ | 2800×1752 | 16:10 |
| XL | Galaxy Tab S9 Ultra | 2960×1848 | 16:10 |

**Android Tablet Layout:**
```dart
// Window size classes (Material 3)
enum WindowSizeClass { compact, medium, expanded }

WindowSizeClass getWindowSizeClass(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 600) return WindowSizeClass.compact;
  if (width < 840) return WindowSizeClass.medium;
  return WindowSizeClass.expanded;
}

// Navigation rail for medium/expanded
NavigationRail(
  selectedIndex: _selectedIndex,
  onDestinationSelected: (int index) {
    setState(() => _selectedIndex = index);
  },
  labelType: NavigationRailLabelType.all,
  destinations: [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: Text('Home'),
    ),
    // ... more destinations
  ],
)
```

### 2.3 HUAWEI Tablets

| Model | Screen Size | Resolution | HarmonyOS |
|-------|-------------|------------|-----------|
| MatePad Pro 13.2" | 13.2" | 2880×1920 | 4.0+ |
| MatePad Pro 11" | 11" | 2560×1600 | 4.0+ |
| MatePad 11.5" | 11.5" | 2200×1440 | 3.1+ |
| MatePad SE | 10.4" | 2000×1200 | 3.1+ |

**Huawei Tablet Specific:**
- Support Multi-Window mode
- Support App Multiplier (phone apps scaled)
- Optimize for M-Pencil input
- Support PC Mode (desktop-like)

---

## 3. SMARTWATCHES

### 3.1 Apple Watch

| Model | Screen Size | Resolution | watchOS |
|-------|-------------|------------|---------|
| Watch SE (40mm) | 40mm | 324×394 | 9.0+ |
| Watch SE (44mm) | 44mm | 368×448 | 9.0+ |
| Series 9 (41mm) | 41mm | 352×430 | 10.0+ |
| Series 9 (45mm) | 45mm | 396×484 | 10.0+ |
| Ultra 2 (49mm) | 49mm | 410×502 | 10.0+ |

**Apple Watch KerjaFlow Features:**
```swift
// WatchKit App - Complications
struct KerjaFlowComplication: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "LeaveBalance",
            provider: LeaveBalanceProvider()
        ) { entry in
            LeaveBalanceView(entry: entry)
        }
        .configurationDisplayName("Leave Balance")
        .description("Shows remaining leave days")
        .supportedFamilies([
            .circularSmall,
            .rectangularSmall,
            .modularSmall,
            .graphicCircular
        ])
    }
}

// Quick Actions
struct QuickLeaveView: View {
    var body: some View {
        List {
            Button("Apply Sick Leave") { applyLeave(.sick) }
            Button("Apply Annual Leave") { applyLeave(.annual) }
            Button("View Balance") { showBalance() }
        }
        .navigationTitle("Quick Leave")
    }
}
```

**Apple Watch Screen Layout:**
```
┌─────────────────────┐
│     Status Bar      │ 28pt
├─────────────────────┤
│                     │
│    Content Area     │ Variable
│                     │
├─────────────────────┤
│  Bottom Action Bar  │ 44pt (optional)
└─────────────────────┘
```

### 3.2 Wear OS (Google)

| Model | Screen Size | Resolution | Wear OS |
|-------|-------------|------------|---------|
| Pixel Watch 2 | 41mm | 450×450 | 4.0 |
| Galaxy Watch 6 | 40mm | 432×432 | 4.0 |
| Galaxy Watch 6 | 44mm | 480×480 | 4.0 |
| Galaxy Watch Ultra | 47mm | 480×480 | 4.0 |

**Wear OS Implementation:**
```dart
// wear_os_app/lib/main.dart
import 'package:wear/wear.dart';

class KerjaFlowWearApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF2E86AB),
            ),
          ),
          home: shape == WearShape.round
              ? RoundWatchLayout()
              : SquareWatchLayout(),
        );
      },
    );
  }
}

// Rotary input support
RotaryScrollableWidget(
  child: ListView(
    children: [
      LeaveBalanceTile(),
      QuickApplyTile(),
      NotificationsTile(),
    ],
  ),
)
```

### 3.3 HUAWEI Watch (HarmonyOS)

| Model | Screen Size | Resolution | HarmonyOS |
|-------|-------------|------------|-----------|
| Watch 4 Pro | 48mm | 466×466 | 4.0 |
| Watch GT 4 | 46mm | 466×466 | 4.0 |
| Watch GT 4 | 41mm | 466×466 | 4.0 |
| Watch Fit 3 | 1.82" | 480×408 | 4.0 |

**Huawei Watch Implementation:**
```java
// HarmonyOS ArkUI (for Watch)
@Entry
@Component
struct LeaveBalanceCard {
  @State leaveBalance: number = 12
  
  build() {
    Column() {
      Text('Leave Balance')
        .fontSize(14)
        .fontColor('#FFFFFF')
      
      Text(this.leaveBalance.toString())
        .fontSize(36)
        .fontWeight(FontWeight.Bold)
        .fontColor('#2E86AB')
      
      Text('days remaining')
        .fontSize(12)
        .fontColor('#A8A8B3')
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .backgroundColor('#1A1A2E')
  }
}
```

**Watch Screen Specifications:**

| Feature | Value |
|---------|-------|
| Min touch target | 48×48 dp |
| Font minimum | 16sp |
| Max list items visible | 3-4 |
| Animation duration | 200-300ms |
| Glanceable info time | < 3 seconds |

---

## 4. TV & STADIUM DISPLAYS

### 4.1 TV Displays (Android TV / Fire TV)

| Resolution | Aspect | Common Sizes |
|------------|--------|--------------|
| 1920×1080 (FHD) | 16:9 | 32"-55" |
| 3840×2160 (4K) | 16:9 | 55"-85" |
| 7680×4320 (8K) | 16:9 | 65"+ |

**TV Layout Specifications:**
```dart
// TV Layout (10-foot interface)
class TVLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const DirectionalFocusIntent(TraversalDirection.down),
      },
      child: Container(
        padding: EdgeInsets.all(48), // TV overscan safe area
        child: Row(
          children: [
            // Sidebar navigation (always visible)
            SizedBox(
              width: 280,
              child: TVNavigationRail(),
            ),
            SizedBox(width: 48),
            // Main content area
            Expanded(
              child: TVContentArea(),
            ),
          ],
        ),
      ),
    );
  }
}
```

**TV Design Rules:**
- Minimum font size: 24sp
- Minimum touch target: 56dp
- Focus indicators: Mandatory (2px border or scale)
- Overscan safe area: 48dp all sides
- D-pad navigation: All elements reachable
- No hover states (focus only)

### 4.2 Stadium Displays

| Resolution | Use Case |
|------------|----------|
| 3840×2160 | Standard signage |
| 3840×1080 | Wide format |
| 5120×1440 | Ultra-wide |
| 7680×4320 | Large venue |

**Stadium Display Layout:**
```dart
// Stadium/Kiosk mode
class StadiumDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF0D3B50), // Dark branded background
      padding: EdgeInsets.all(80), // Large margins
      child: Column(
        children: [
          // Company branding
          Row(
            children: [
              Image.asset('assets/logo_white.png', height: 120),
              Spacer(),
              CurrentDateTime(), // Large clock
            ],
          ),
          SizedBox(height: 64),
          // Main metrics - 4 column grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: 32,
              crossAxisSpacing: 32,
              children: [
                MetricCard(
                  title: 'Employees Present',
                  value: '847',
                  percentage: '94%',
                  trend: TrendDirection.up,
                ),
                MetricCard(
                  title: 'On Leave Today',
                  value: '23',
                  percentage: '2.6%',
                  trend: TrendDirection.neutral,
                ),
                MetricCard(
                  title: 'Pending Approvals',
                  value: '12',
                  percentage: '',
                  trend: TrendDirection.attention,
                ),
                MetricCard(
                  title: 'Next Payday',
                  value: '25 Jan',
                  percentage: '16 days',
                  trend: TrendDirection.neutral,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Stadium Text Sizes:**
| Element | Size | Weight |
|---------|------|--------|
| Title | 96px | Bold |
| Metric Value | 144px | Extra Bold |
| Metric Label | 48px | Medium |
| Body | 32px | Regular |

---

## 5. ADVERTISEMENT SIZES (IAB Standards)

### 5.1 Mobile Ads

| Name | Size | Usage |
|------|------|-------|
| Mobile Banner | 320×50 | In-app banner |
| Large Mobile Banner | 320×100 | In-app premium |
| Mobile Interstitial | 320×480 | Full screen |
| Mobile Interstitial Large | 480×320 | Full screen landscape |

### 5.2 Tablet Ads

| Name | Size | Usage |
|------|------|-------|
| Tablet Banner | 728×90 | Leaderboard |
| Tablet Medium Rectangle | 300×250 | In-content |
| Tablet Interstitial | 768×1024 | Full screen portrait |
| Tablet Interstitial | 1024×768 | Full screen landscape |

### 5.3 Digital Signage

| Name | Size | Usage |
|------|------|-------|
| Full HD | 1920×1080 | Standard displays |
| 4K | 3840×2160 | High-res displays |
| Ultra Wide | 3840×1080 | Banner displays |
| Portrait | 1080×1920 | Vertical displays |

### 5.4 App Store Assets

| Platform | Asset | Size |
|----------|-------|------|
| iOS | App Icon | 1024×1024 |
| iOS | Screenshots (6.7") | 1290×2796 |
| iOS | Screenshots (6.5") | 1284×2778 |
| iOS | Screenshots (5.5") | 1242×2208 |
| iOS | iPad Screenshots | 2048×2732 |
| Android | App Icon | 512×512 |
| Android | Feature Graphic | 1024×500 |
| Android | Screenshots (phone) | 1080×1920 min |
| Android | Screenshots (tablet 7") | 1200×1920 |
| Android | Screenshots (tablet 10") | 1920×1200 |
| Huawei | App Icon | 216×216 |
| Huawei | Feature Graphic | 1024×500 |
| Huawei | Screenshots | 1080×1920 min |

---

## 6. PLATFORM-SPECIFIC COMPONENTS

### 6.1 iOS-Native Feel

```dart
// Use Cupertino widgets on iOS
import 'package:flutter/cupertino.dart';

Widget buildPlatformButton(BuildContext context) {
  if (Platform.isIOS) {
    return CupertinoButton.filled(
      child: Text('Apply Leave'),
      onPressed: () {},
    );
  }
  return ElevatedButton(
    child: Text('Apply Leave'),
    onPressed: () {},
  );
}

// iOS-style navigation
CupertinoPageRoute(
  builder: (context) => DetailScreen(),
)

// iOS-style date picker
CupertinoDatePicker(
  mode: CupertinoDatePickerMode.date,
  onDateTimeChanged: (DateTime value) {},
)
```

### 6.2 Android Material Feel

```dart
// Material 3 theming
ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF1A5276),
    brightness: Brightness.light,
  ),
)

// Material navigation
MaterialPageRoute(
  builder: (context) => DetailScreen(),
)

// Material date picker
showDatePicker(
  context: context,
  initialDate: DateTime.now(),
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
)
```

### 6.3 Huawei HMS Specific

```dart
// HMS Push notification handling
class HMSPushHandler {
  static Future<void> init() async {
    // Request token
    String? token = await HmsPush.getToken('');
    
    // Subscribe to topics
    await HmsPush.subscribe('kerjaflow_announcements');
    
    // Handle notification tap
    HmsPush.onNotificationOpenedApp.listen((remoteMessage) {
      // Navigate to relevant screen
    });
  }
}

// HMS Location (instead of Google Location)
Future<Location> getCurrentLocation() async {
  final location = await HMSLocation.getLastLocation();
  return location;
}
```

---

## 7. RESPONSIVE BEHAVIOR MATRIX

| Breakpoint | Navigation | Content Columns | Cards/Row |
|------------|------------|-----------------|-----------|
| Watch | Single screen | 1 | 1 |
| Phone Portrait | Bottom nav | 1 | 1-2 |
| Phone Landscape | Bottom nav | 2 | 2-3 |
| Tablet Portrait | Nav rail | 2 | 2-3 |
| Tablet Landscape | Nav rail + detail | 3 | 3-4 |
| Desktop | Side nav | 3+ | 4+ |
| TV | Side nav | 4 | 4 |
| Stadium | None (auto) | 4 | 4 |

---

## 8. IMPLEMENTATION CHECKLIST

### Per Platform Verification

- [ ] iOS iPhone - All screen sizes
- [ ] iOS iPhone - Dynamic Island handling
- [ ] iOS iPhone - Home indicator safe area
- [ ] iOS iPad - Split view support
- [ ] iOS iPad - Multitasking support
- [ ] iOS Apple Watch - Complications
- [ ] iOS Apple Watch - Quick actions
- [ ] Android Phone - All densities (hdpi → xxxhdpi)
- [ ] Android Phone - Display cutout handling
- [ ] Android Phone - Gesture navigation
- [ ] Android Tablet - Window size classes
- [ ] Android Tablet - Keyboard support
- [ ] Wear OS - Round/square layouts
- [ ] Wear OS - Rotary input
- [ ] Huawei Phone - HMS integration
- [ ] Huawei Phone - AppGallery requirements
- [ ] Huawei Tablet - Multi-window
- [ ] Huawei Watch - HarmonyOS app
- [ ] Web Desktop - All breakpoints
- [ ] Web Mobile - Touch optimization
- [ ] TV - D-pad navigation
- [ ] TV - Focus management

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
**Compliance:** WCAG 2.2 AA, Material Design 3, Human Interface Guidelines, EMUI Guidelines
