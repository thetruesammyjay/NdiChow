import '../../../core/networking/ndichow_api_client.dart';
import '../../../shared/models/customer.dart';
import 'session_store.dart';

class AuthRepository {
  const AuthRepository(this._api, this._store);

  final NdiChowApiClient _api;
  final SessionStore _store;

  Future<Customer?> restoreSession() async {
    final token = await _store.readToken();
    if (token == null) return null;
    _api.setSessionToken(token);
    try {
      return await _api.getCurrentCustomer();
    } on NdiChowApiException catch (error) {
      if (!error.isUnauthenticated) rethrow;
      await clearSession();
      return null;
    }
  }

  Future<Customer> login({
    required String email,
    required String password,
  }) async {
    final session = await _api.login(email: email, password: password);
    await _saveSession(session);
    return session.customer;
  }

  Future<Customer> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final session = await _api.register(
      name: name,
      email: email,
      password: password,
    );
    await _saveSession(session);
    return session.customer;
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    _api.setSessionToken(null);
    await _store.clearToken();
  }

  Future<void> _saveSession(AuthSession session) async {
    _api.setSessionToken(session.token);
    await _store.writeToken(session.token);
  }
}
