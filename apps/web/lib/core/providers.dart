import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/auth_models.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/dashboard/data/dashboard_repository.dart';
import 'network/api_client.dart';
import 'storage/token_storage.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(sharedPreferencesProvider));
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  final client = ApiClient(tokenStorage: storage);
  client.onUnauthorized = () {
    ref.read(authControllerProvider.notifier).handleUnauthorized();
  };
  return client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(apiClient: ref.watch(apiClientProvider));
});

class AuthState {
  const AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isInitializing = true,
  });

  final AppUser? user;
  final bool isAuthenticated;
  final bool isInitializing;

  AuthState copyWith({
    AppUser? user,
    bool? isAuthenticated,
    bool? isInitializing,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(bootstrap);
    return const AuthState();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> bootstrap() async {
    if (!_repo.hasToken) {
      state = const AuthState(isAuthenticated: false, isInitializing: false);
      return;
    }

    final cached = _repo.readCachedUser();
    state = AuthState(
      user: cached,
      isAuthenticated: true,
      isInitializing: true,
    );

    try {
      final user = await _repo.me();
      state = AuthState(
        user: user,
        isAuthenticated: true,
        isInitializing: false,
      );
    } catch (_) {
      await _repo.logout();
      state = const AuthState(isAuthenticated: false, isInitializing: false);
    }
  }

  Future<void> applySession(AuthSession session) async {
    state = AuthState(
      user: session.user,
      isAuthenticated: true,
      isInitializing: false,
    );
  }

  void setUser(AppUser user) {
    state = AuthState(
      user: user,
      isAuthenticated: true,
      isInitializing: false,
    );
  }

  Future<void> refreshUser() async {
    final user = await _repo.me();
    setUser(user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isAuthenticated: false, isInitializing: false);
  }

  void handleUnauthorized() {
    _repo.logout();
    state = const AuthState(isAuthenticated: false, isInitializing: false);
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
