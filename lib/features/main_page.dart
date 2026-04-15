import 'package:flutter/material.dart';
import 'package:one_day/core/di/di.dart';
import 'package:one_day/core/theme/app_colors.dart';
import 'package:one_day/core/utils/app_refresh_notifier.dart';
import 'package:one_day/core/utils/responsive_utils.dart';
import 'package:one_day/features/challenge/presentation/pages/challenge_feed_page.dart';
import 'package:one_day/features/impact/presentation/pages/impact_page.dart';
import 'package:one_day/features/profile/presentation/pages/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = [
    ChallengeFeedPage(),
    ImpactPage(),
    ProfilePage(),
  ];

  static const List<NavigationDestination> _destinations = [
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_graph_outlined),
      selectedIcon: Icon(Icons.auto_graph),
      label: 'Impact',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _selectedIndex = index);
    // Notify pages to refresh their data when switching tabs
    getIt<AppRefreshNotifier>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);

    if (desktop) {
      return _buildDesktopLayout();
    }
    return _buildMobileLayout();
  }

  /// Desktop: NavigationRail on the left, content area centered with max-width.
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'OneDay',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
              ),
            ),
            destinations: _destinations.map((d) {
              return NavigationRailDestination(
                icon: d.icon,
                selectedIcon: d.selectedIcon,
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.divider),
          Expanded(
            child: responsiveMaxWidth(
              maxWidth: 800,
              child: IndexedStack(
                index: _selectedIndex,
                children: _pages,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile/Tablet: Bottom NavigationBar.
  Widget _buildMobileLayout() {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onDestinationSelected,
          destinations: _destinations,
        ),
      ),
    );
  }
}
