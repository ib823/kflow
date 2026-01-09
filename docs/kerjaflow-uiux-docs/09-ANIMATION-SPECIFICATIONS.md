# KERJAFLOW ANIMATION SPECIFICATIONS
## Micro-interactions, Transitions, Motion Design

---

## 1. ANIMATION PRINCIPLES

### 1.1 Core Philosophy

| Principle | Description | Implementation |
|-----------|-------------|----------------|
| **Purposeful** | Every animation has a reason | Guide attention, show relationships |
| **Quick** | Respect user's time | 200-300ms for most interactions |
| **Natural** | Follow physics | Easing curves, spring animations |
| **Consistent** | Same actions = same animations | Reusable animation classes |
| **Accessible** | Reduced motion support | Check system preferences |

### 1.2 Duration Guidelines

| Category | Duration | Use Case |
|----------|----------|----------|
| Instant | 0ms | Immediate feedback (color change) |
| Fast | 100ms | Micro-interactions (button press) |
| Normal | 200ms | Most transitions |
| Slow | 300ms | Complex transitions |
| Slower | 500ms | Page transitions, modals |
| Slowest | 800ms | Emphasis animations |

---

## 2. EASING CURVES

### 2.1 Standard Curves

```dart
/// KerjaFlow Animation Curves
class KFCurves {
  /// Standard easing - most common
  static const Curve standard = Curves.easeInOut;
  
  /// Emphasized - for important transitions
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);
  
  /// Decelerate - enter animations
  static const Curve decelerate = Curves.easeOut;
  
  /// Accelerate - exit animations
  static const Curve accelerate = Curves.easeIn;
  
  /// Spring - playful, bouncy
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0);
  
  /// Overshoot - emphasis with bounce back
  static const Curve overshoot = Curves.elasticOut;
}
```

### 2.2 Curve Usage Matrix

| Animation Type | Curve | Reason |
|----------------|-------|--------|
| Button press | decelerate | Quick response |
| Page enter | emphasized | Smooth entrance |
| Page exit | accelerate | Get out of way |
| Modal appear | spring | Attention-grabbing |
| Modal dismiss | decelerate | Smooth departure |
| Card expand | emphasized | Natural feel |
| List item stagger | decelerate | Flowing motion |
| Error shake | overshoot | Attention |
| Success check | spring | Celebration |

---

## 3. MICRO-INTERACTIONS

### 3.1 Button Animations

```dart
/// Button press feedback
class AnimatedButton extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonContent,
      ),
    );
  }
  
  // Scale: 1.0 → 0.95 → 1.0
  // Duration: 100ms down, 100ms up
  // Curve: easeOut
}
```

### 3.2 Card Tap Animation

```dart
/// Card interaction
class AnimatedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: _isPressed ? 1 : 0),
      duration: Duration(milliseconds: 100),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 - (0.02 * value), // Scale to 0.98
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10 - (4 * value), // Shadow reduces
                  offset: Offset(0, 4 - (2 * value)),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
    );
  }
}
```

### 3.3 Toggle/Switch Animation

```dart
/// Smooth toggle
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  curve: Curves.easeInOut,
  width: 48,
  height: 28,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(14),
    color: isOn ? KFColors.primary600 : KFColors.gray300,
  ),
  child: AnimatedAlign(
    duration: Duration(milliseconds: 200),
    curve: Curves.easeInOut,
    alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      width: 24,
      height: 24,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: KFShadows.sm,
      ),
    ),
  ),
)
```

### 3.4 Checkbox Animation

```dart
/// Animated checkbox with checkmark draw
class AnimatedCheckbox extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isChecked ? KFColors.primary600 : KFColors.gray400,
          width: 2,
        ),
        color: isChecked ? KFColors.primary600 : Colors.transparent,
      ),
      child: isChecked
        ? TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: Duration(milliseconds: 200),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return CustomPaint(
                painter: CheckmarkPainter(progress: value),
              );
            },
          )
        : null,
    );
  }
}
```

---

## 4. PAGE TRANSITIONS

### 4.1 Standard Page Transition

```dart
/// Slide + Fade transition
class KFPageRoute<T> extends PageRouteBuilder<T> {
  KFPageRoute({required this.page})
    : super(
        transitionDuration: Duration(milliseconds: 300),
        reverseTransitionDuration: Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Check reduced motion
          if (MediaQuery.of(context).disableAnimations) {
            return child;
          }
          
          return SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.1, 0), // Subtle slide from right
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: KFCurves.emphasized,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      );
      
  final Widget page;
}
```

### 4.2 Modal/Bottom Sheet Transition

```dart
/// Bottom sheet slide up
showModalBottomSheet(
  context: context,
  transitionAnimationController: AnimationController(
    duration: Duration(milliseconds: 300),
    vsync: this,
  ),
  builder: (context) => BottomSheetContent(),
);

/// Custom modal with scale + fade
class ModalRoute<T> extends PageRouteBuilder<T> {
  ModalRoute({required this.child})
    : super(
        opaque: false,
        barrierColor: Colors.black54,
        barrierDismissible: true,
        transitionDuration: Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => child,
        transitionsBuilder: (_, animation, __, child) {
          return ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: KFCurves.spring),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      );
      
  final Widget child;
}
```

### 4.3 Tab Switch Animation

```dart
/// Cross-fade between tabs
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  switchInCurve: Curves.easeOut,
  switchOutCurve: Curves.easeIn,
  transitionBuilder: (child, animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  },
  child: _buildTabContent(selectedIndex),
)
```

---

## 5. LOADING ANIMATIONS

### 5.1 Skeleton Shimmer

```dart
/// Shimmer loading effect
class SkeletonLoader extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2 * _controller.value, 0),
              end: Alignment(1.0 + 2 * _controller.value, 0),
              colors: [
                KFColors.gray200,
                KFColors.gray100,
                KFColors.gray200,
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: Container(
            decoration: BoxDecoration(
              color: KFColors.gray200,
              borderRadius: KFRadius.radiusMd,
            ),
          ),
        );
      },
    );
  }
  
  // Duration: 1500ms
  // Repeat: infinite
}
```

### 5.2 Pull to Refresh

```dart
/// Custom refresh indicator
RefreshIndicator(
  displacement: 40,
  strokeWidth: 2.5,
  color: KFColors.primary600,
  backgroundColor: Colors.white,
  onRefresh: _onRefresh,
  child: listContent,
)
```

### 5.3 Button Loading State

```dart
/// Loading button with spinner
AnimatedSwitcher(
  duration: Duration(milliseconds: 200),
  child: isLoading
    ? SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
    : Text('Submit'),
)
```

---

## 6. LIST ANIMATIONS

### 6.1 Staggered List Appearance

```dart
/// Stagger items on list load
class StaggeredList extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.1; // 100ms between items
            final progress = (_controller.value - delay).clamp(0.0, 1.0);
            
            return Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - progress)),
                child: child,
              ),
            );
          },
          child: ListItem(item: items[index]),
        );
      },
    );
  }
}
```

### 6.2 Item Swipe Actions

```dart
/// Swipe to reveal actions
Dismissible(
  key: Key(item.id),
  background: Container(
    color: KFColors.success500,
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.only(left: 20),
    child: Icon(Icons.check, color: Colors.white),
  ),
  secondaryBackground: Container(
    color: KFColors.error500,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 20),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  confirmDismiss: (direction) async {
    // Confirm action
    return await showConfirmDialog();
  },
  onDismissed: (direction) {
    if (direction == DismissDirection.startToEnd) {
      _approve(item);
    } else {
      _reject(item);
    }
  },
  child: ListItem(item: item),
)
```

### 6.3 Add/Remove Animation

```dart
/// Animated list for dynamic content
AnimatedList(
  key: _listKey,
  initialItemCount: items.length,
  itemBuilder: (context, index, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: ListItem(item: items[index]),
      ),
    );
  },
)

// Remove item with animation
_listKey.currentState?.removeItem(
  index,
  (context, animation) => SizeTransition(
    sizeFactor: animation,
    child: FadeTransition(
      opacity: animation,
      child: removedItem,
    ),
  ),
  duration: Duration(milliseconds: 250),
);
```

---

## 7. FEEDBACK ANIMATIONS

### 7.1 Success Animation

```dart
/// Animated checkmark on success
class SuccessAnimation extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: KFColors.success100,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 600),
        curve: KFCurves.spring,
        builder: (context, value, _) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Circle scale in
              Transform.scale(
                scale: value,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: KFColors.success500,
                  ),
                ),
              ),
              // Checkmark draw
              CustomPaint(
                size: Size(30, 30),
                painter: CheckmarkPainter(
                  progress: (value - 0.3).clamp(0, 1) / 0.7,
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

### 7.2 Error Shake Animation

```dart
/// Shake animation for errors
class ShakeAnimation extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final sineValue = sin(_controller.value * 3 * pi);
        return Transform.translate(
          offset: Offset(10 * sineValue, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
  
  // Duration: 400ms
  // Shake 3 times
}
```

### 7.3 Haptic Feedback

```dart
/// Haptic feedback for interactions
class KFHaptics {
  /// Light impact - button taps
  static void light() {
    HapticFeedback.lightImpact();
  }
  
  /// Medium impact - selections
  static void medium() {
    HapticFeedback.mediumImpact();
  }
  
  /// Heavy impact - significant actions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }
  
  /// Success - completion
  static void success() {
    HapticFeedback.mediumImpact();
    Future.delayed(Duration(milliseconds: 100), () {
      HapticFeedback.lightImpact();
    });
  }
  
  /// Error - failure
  static void error() {
    HapticFeedback.heavyImpact();
  }
  
  /// Selection change
  static void selection() {
    HapticFeedback.selectionClick();
  }
}
```

---

## 8. REDUCED MOTION SUPPORT

### 8.1 Motion Preferences Check

```dart
/// Respect reduced motion preference
class KFMotion {
  static bool prefersReduced(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  
  static Duration duration(
    BuildContext context,
    Duration normal, {
    Duration? reduced,
  }) {
    if (prefersReduced(context)) {
      return reduced ?? Duration.zero;
    }
    return normal;
  }
  
  static Widget conditional(
    BuildContext context, {
    required Widget animated,
    required Widget static,
  }) {
    return prefersReduced(context) ? static : animated;
  }
}
```

### 8.2 Simplified Animations

```dart
/// Use simplified animations when reduced motion enabled
AnimatedOpacity(
  opacity: isVisible ? 1.0 : 0.0,
  duration: KFMotion.duration(
    context,
    Duration(milliseconds: 300),
  ),
  child: content,
)

/// Skip complex animations entirely
if (!KFMotion.prefersReduced(context)) {
  return AnimatedComplexWidget();
} else {
  return StaticWidget();
}
```

---

## 9. ANIMATION TIMING REFERENCE

### 9.1 Complete Timing Chart

| Animation | Duration | Easing | Delay |
|-----------|----------|--------|-------|
| Button tap | 100ms | easeOut | 0 |
| Button release | 100ms | easeIn | 0 |
| Card tap | 100ms | easeOut | 0 |
| Page transition | 300ms | emphasized | 0 |
| Modal appear | 250ms | spring | 0 |
| Modal dismiss | 200ms | easeIn | 0 |
| Bottom sheet | 300ms | decelerate | 0 |
| Tab switch | 200ms | easeInOut | 0 |
| List item appear | 200ms | decelerate | index × 50ms |
| Skeleton shimmer | 1500ms | linear | 0 (loop) |
| Pull to refresh | 500ms | decelerate | 0 |
| Snackbar appear | 250ms | decelerate | 0 |
| Snackbar dismiss | 200ms | accelerate | 0 |
| Toast | 200ms | easeOut | 0 |
| Tooltip | 150ms | easeOut | 500ms |
| Dropdown open | 200ms | decelerate | 0 |
| Dropdown close | 150ms | accelerate | 0 |
| Checkbox | 150ms | easeOut | 0 |
| Switch | 200ms | easeInOut | 0 |
| Success check | 600ms | spring | 0 |
| Error shake | 400ms | linear | 0 |
| Focus ring | 100ms | easeOut | 0 |

---

**Document Version:** 4.0
**Last Updated:** January 9, 2026
