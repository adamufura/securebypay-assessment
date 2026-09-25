import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import 'app_sidebar.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final SidebarMode mode;
        if (width >= 1024) {
          mode = SidebarMode.full;
        } else if (width >= 768) {
          mode = SidebarMode.rail;
        } else {
          mode = SidebarMode.drawer;
        }

        final showInlineSidebar = mode != SidebarMode.drawer;

        return Scaffold(
          backgroundColor: AppColors.pageBg,
          drawer: mode == SidebarMode.drawer
              ? Drawer(
                  backgroundColor: AppColors.sidebarBg,
                  child: AppSidebar(
                    mode: SidebarMode.full,
                    currentPath: path,
                    onNavigate: () => Navigator.of(context).pop(),
                  ),
                )
              : null,
          body: Row(
            children: [
              if (showInlineSidebar)
                AppSidebar(mode: mode, currentPath: path),
              Expanded(
                child: Column(
                  children: [
                    if (mode == SidebarMode.drawer ||
                        title != null ||
                        subtitle != null)
                      _TopBar(
                        showMenu: mode == SidebarMode.drawer,
                        title: title,
                        subtitle: subtitle,
                      ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.showMenu,
    this.title,
    this.subtitle,
  });

  final bool showMenu;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pageBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 20, 4),
          child: Row(
            children: [
              if (showMenu)
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu_rounded),
                ),
              if (title != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 22,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
              else
                const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
