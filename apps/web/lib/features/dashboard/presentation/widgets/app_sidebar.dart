import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/auth_models.dart';

class NavDest {
  const NavDest({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}

const List<NavDest> kAppNavDestinations = [
  NavDest(
    label: 'Dashboard',
    icon: Icons.grid_view_rounded,
    path: '/dashboard',
  ),
  NavDest(
    label: 'Shipments',
    icon: Icons.local_shipping_outlined,
    path: '/shipments',
  ),
  NavDest(
    label: 'Our Services',
    icon: Icons.miscellaneous_services_outlined,
    path: '/services',
  ),
  NavDest(
    label: 'Notifications',
    icon: Icons.notifications_none_rounded,
    path: '/notifications',
  ),
  NavDest(
    label: 'Wallet',
    icon: Icons.account_balance_wallet_outlined,
    path: '/wallet',
  ),
  NavDest(
    label: 'My Addresses',
    icon: Icons.location_on_outlined,
    path: '/addresses',
  ),
  NavDest(
    label: 'Invite & Earn',
    icon: Icons.card_giftcard_outlined,
    path: '/invite',
  ),
  NavDest(
    label: 'Help Center',
    icon: Icons.help_outline_rounded,
    path: '/help',
  ),
];

enum SidebarMode { full, rail, drawer }

class AppSidebar extends ConsumerWidget {
  const AppSidebar({
    super.key,
    required this.mode,
    required this.currentPath,
    this.onNavigate,
  });

  final SidebarMode mode;
  final String currentPath;
  final VoidCallback? onNavigate;

  bool get _iconsOnly => mode == SidebarMode.rail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final width = _iconsOnly ? 84.0 : 240.0;

    return Material(
      color: AppColors.sidebarBg,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _iconsOnly ? 16 : 20,
                  24,
                  _iconsOnly ? 16 : 20,
                  12,
                ),
                child: _Logo(compact: _iconsOnly),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: _iconsOnly ? 12 : 12,
                    vertical: 8,
                  ),
                  children: [
                    for (final dest in kAppNavDestinations)
                      _NavItem(
                        dest: dest,
                        selected: _isSelected(dest.path, currentPath),
                        iconsOnly: _iconsOnly,
                        onTap: () {
                          onNavigate?.call();
                          if (GoRouterState.of(context).uri.path != dest.path) {
                            context.go(dest.path);
                          }
                        },
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  _iconsOnly ? 12 : 16,
                  8,
                  _iconsOnly ? 12 : 16,
                  20,
                ),
                child: _UserFooter(
                  user: user,
                  iconsOnly: _iconsOnly,
                  onLogout: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/sign-in');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isSelected(String destPath, String current) {
    if (destPath == '/dashboard') {
      return current == '/dashboard' || current == '/';
    }
    return current == destPath || current.startsWith('$destPath/');
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.brandPurple,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.public, color: Colors.white, size: 20),
    );

    if (compact) return mark;

    return Row(
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          'Myafrimall',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.navy,
              ),
        ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.dest,
    required this.selected,
    required this.iconsOnly,
    required this.onTap,
  });

  final NavDest dest;
  final bool selected;
  final bool iconsOnly;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Tooltip(
        message: iconsOnly ? dest.label : '',
        child: Material(
          color: selected ? AppColors.navy : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.sidebarActive),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadii.sidebarActive),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: iconsOnly ? 12 : 14,
                vertical: 12,
              ),
              child: Row(
                mainAxisAlignment:
                    iconsOnly ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  Icon(dest.icon, size: 20, color: fg),
                  if (!iconsOnly) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dest.label,
                        style: TextStyle(
                          color: fg,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserFooter extends StatelessWidget {
  const _UserFooter({
    required this.user,
    required this.iconsOnly,
    required this.onLogout,
  });

  final AppUser? user;
  final bool iconsOnly;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final name = user?.fullName.isNotEmpty == true
        ? user!.fullName
        : 'Firstname Lastname';
    final initials = _initials(name);

    if (iconsOnly) {
      return Column(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.brandPurple.withValues(alpha: 0.15),
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.brandPurple,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          IconButton(
            onPressed: onLogout,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.brandPurple.withValues(alpha: 0.15),
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.brandPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onLogout,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(Icons.logout_rounded, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 10),
                Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.isEmpty ? 'U' : parts.first[0].toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
