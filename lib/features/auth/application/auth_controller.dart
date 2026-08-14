import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/networking/ndichow_api_client.dart';
import '../../../shared/models/customer.dart';
import '../data/auth_repository.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    bootstrap();
  }

  AuthController.authenticated(Customer customer)
    : _repository = null,
      _customer = customer,
      _status = AuthStatus.authenticated;

  final AuthRepository? _repository;
  AuthStatus _status = AuthStatus.loading;
  Customer? _customer;
  String? _errorMessage;
  bool _isSubmitting = false;

  AuthStatus get status => _status;
  Customer? get customer => _customer;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  Future<void> bootstrap() async {
    final repository = _repository;
    if (repository == null) return;
    try {
      _customer = await repository.restoreSession();
      _status =
          _customer == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated;
    } catch (_) {
      _status = AuthStatus.unauthenticated;
      _errorMessage =
          'We could not restore your session. Please sign in again.';
    }
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) =>
      _submit(() => _repository!.login(email: email, password: password));

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) => _submit(
    () => _repository!.register(name: name, email: email, password: password),
  );

  Future<bool> _submit(Future<Customer> Function() action) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _customer = await action();
      _status = AuthStatus.authenticated;
      return true;
    } on NdiChowApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository?.logout();
    } finally {
      _customer = null;
      _status = AuthStatus.unauthenticated;
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void sessionExpired() {
    if (_status != AuthStatus.authenticated) return;
    _customer = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Your session expired. Please sign in again.';
    unawaited(_repository?.clearSession());
    notifyListeners();
  }
}
