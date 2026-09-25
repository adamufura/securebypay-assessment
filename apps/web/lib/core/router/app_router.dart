import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password_page.dart';
import '../../features/auth/presentation/sign_in_page.dart';
import '../../features/auth/presentation/sign_up_page.dart';
import '../../features/dashboard/presentation/coming_soon_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/dashboard/presentation/shipments_page.dart';
import '../../features/legal/privacy_page.dart';
import '../../features/legal/terms_page.dart';
import '../providers.dart';

/// Instant page swap — no mobile slide / modal feel on Flutter Web.
CustomTransitionPage<void> _webPage({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
  );
}

GoRoute _route(String path, Widget child) {
  return GoRoute(
    path: path,
    pageBuilder: (context, state) => _webPage(
      key: state.pageKey,
      child: child,
    ),
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefresh(ref);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final loggingIn = location == '/sign-in' ||
          location == '/sign-up' ||
          location == '/forgot-password';
      final isLegal = location == '/privacy' || location == '/terms';

      if (auth.isInitializing) {
        return null;
      }

      final signedIn = auth.isAuthenticated;

      if (location == '/') {
        return signedIn ? '/dashboard' : '/sign-in';
      }

      if (!signedIn && !loggingIn && !isLegal) {
        return '/sign-in';
      }

      if (signedIn && loggingIn) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      _route('/', const _BootSplash()),
      _route('/sign-in', const SignInPage()),
      _route('/sign-up', const SignUpPage()),
      _route('/forgot-password', const ForgotPasswordPage()),
      _route('/privacy', const PrivacyPage()),
      _route('/terms', const TermsPage()),
      _route('/dashboard', const DashboardPage()),
      _route('/shipments', const ShipmentsPage()),
      _route('/services', const ComingSoonPage(title: 'Our Services')),
      _route('/notifications', const ComingSoonPage(title: 'Notifications')),
      _route('/wallet', const ComingSoonPage(title: 'Wallet')),
      _route('/addresses', const ComingSoonPage(title: 'My Addresses')),
      _route('/invite', const ComingSoonPage(title: 'Invite & Earn')),
      _route('/help', const ComingSoonPage(title: 'Help Center')),
    ],
  );
});

class _BootSplash extends StatelessWidget {
  const _BootSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._ref) {
    _subscription = _ref.listen<AuthState>(authControllerProvider, (_, _) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
