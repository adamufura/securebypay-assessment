import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'auth_models.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _api = apiClient,
        _storage = tokenStorage;

  final ApiClient _api;
  final TokenStorage _storage;

  Future<AuthSession> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneCountryCode,
    required String phoneNumber,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/register',
      auth: false,
      body: {
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'email': email.trim().toLowerCase(),
        'phoneCountryCode': phoneCountryCode,
        'phoneNumber': phoneNumber.replaceAll(RegExp(r'\s+'), ''),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final session = AuthSession.fromJson(data);
    await _persist(session);
    return session;
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      '/auth/login',
      auth: false,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    ) as Map<String, dynamic>;

    final session = AuthSession.fromJson(data);
    await _persist(session);
    return session;
  }

  Future<String> forgotPassword(String email) async {
    final data = await _api.post(
      '/auth/forgot',
      auth: false,
      body: {'email': email.trim().toLowerCase()},
    );

    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ??
          'If that email exists, a reset link has been sent.';
    }
    return 'If that email exists, a reset link has been sent.';
  }

  Future<AppUser> me() async {
    final data = await _api.get('/auth/me') as Map<String, dynamic>;
    final user = AppUser.fromJson(data);
    await _storage.saveUser(user.toJson());
    return user;
  }

  AppUser? readCachedUser() {
    final json = _storage.cachedUser;
    if (json == null) return null;
    return AppUser.fromJson(json);
  }

  bool get hasToken => _storage.hasToken;

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<void> _persist(AuthSession session) async {
    await _storage.saveToken(session.accessToken);
    await _storage.saveUser(session.user.toJson());
  }
}
