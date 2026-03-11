// lib/features/roadmap/presentation/pages/main_shell_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iron_mind/core/theme/app_theme.dart';

import 'package:flutter/services.dart';

class MainShellPage extends StatefulWidget {
  final Widget child;
  const MainShellPage({super.key, required this.child});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  DateTime? _lastBackPressTime;

  static const _tabs = [
    (path: '/',       icon: Icons.grid_view_rounded,      activeIcon: Icons.grid_view_rounded,    label: 'Focus'),
    (path: '/today',  icon: Icons.bolt_rounded,           activeIcon: Icons.bolt_rounded,         label: "Aujourd'hui"),
    (path: '/stats',  icon: Icons.analytics_outlined,     activeIcon: Icons.analytics_rounded,    label: 'Progrès'),
    (path: '/journal',icon: Icons.auto_stories_outlined,  activeIcon: Icons.auto_stories_rounded, label: 'Journal'),
    (path: '/map',    icon: Icons.map_outlined,           activeIcon: Icons.map_rounded,          label: 'Carte'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return _tabs.indexWhere((t) => t.path == location);
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex(context);
    final isHome = GoRouterState.of(context).uri.path == '/';
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (!isHome) {
          context.go('/');
        } else {
          final now = DateTime.now();
          if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
            _lastBackPressTime = now;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Appuyez encore une fois pour quitter', style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12)),
                duration: Duration(seconds: 2),
                backgroundColor: IronMindColors.card,
              ),
            );
          } else {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: IronMindColors.background,
        body: widget.child,
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: IronMindColors.surface,
            border: Border(top: BorderSide(color: IronMindColors.glassBorder, width: 0.5)),
          ),
          child: SafeArea(
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _tabs.asMap().entries.map((e) {
                  final i      = e.key;
                  final tab    = e.value;
                  final active = i == current;
                  return Expanded(
                    child: InkWell(
                      onTap: () => _navigateToTab(context, i),
                      borderRadius: BorderRadius.circular(12),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon(
                                active ? tab.activeIcon : tab.icon,
                                color: active ? Theme.of(context).colorScheme.primary : IronMindColors.textSecondary,
                                size: active ? 26 : 24,
                              ),
                            const SizedBox(height: 4),
                            Text(
                              tab.label,
                              style: TextStyle(
                                fontFamily:  'JetBrainsMono',
                                fontSize:    11,
                                color: active ? Theme.of(context).colorScheme.primary : IronMindColors.textSecondary,
                                fontWeight:  active ? FontWeight.w700 : FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                            ),
                            if (active) ...[
                              const SizedBox(height: 4),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    context.go(_tabs[index].path);
  }
}
