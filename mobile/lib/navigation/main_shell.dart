import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/core.dart';

/// Main shell with bottom navigation for authenticated screens
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: KFBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        items: const [
          KFNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          KFNavItem(
            icon: Icons.receipt_long_outlined,
            activeIcon: Icons.receipt_long,
            label: 'Payslip',
          ),
          KFNavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
            label: 'Leave',
          ),
          KFNavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Alerts',
            badgeCount: 3,
          ),
          KFNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
