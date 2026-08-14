import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../shared/models/customer.dart';
import '../../shared/models/order.dart';
import '../../shared/models/restaurant.dart';

class NdiChowApiClient {
  NdiChowApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;
  String? _token;
  void Function()? onUnauthorized;

  void setSessionToken(String? token) => _token = token;

  Future<List<Restaurant>> getRestaurants({String? query}) async {
    final uri = _uri(
      '/restaurants',
      query == null || query.trim().isEmpty ? null : {'q': query.trim()},
    );
    final body = await _request(() => _client.get(uri));
    return _dataList(body, Restaurant.fromJson, 'restaurant');
  }

  Future<Restaurant> getRestaurant(String restaurantId) async {
    final body = await _request(
      () => _client.get(
        _uri('/restaurants/${Uri.encodeComponent(restaurantId)}'),
      ),
    );
    return Restaurant.fromJson(_dataMap(body));
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final body = await _request(
      () => _client.post(
        _uri('/auth/register'),
        headers: _jsonHeaders(),
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ),
    );
    return AuthSession.fromJson(_dataMap(body));
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final body = await _request(
      () => _client.post(
        _uri('/auth/login'),
        headers: _jsonHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      ),
    );
    return AuthSession.fromJson(_dataMap(body));
  }

  Future<Customer> getCurrentCustomer() async {
    final body = await _request(
      () => _client.get(_uri('/auth/me'), headers: _authHeaders()),
    );
    return Customer.fromJson(_dataMap(body));
  }

  Future<void> logout() async {
    await _request(
      () => _client.post(_uri('/auth/logout'), headers: _authHeaders()),
    );
  }

  Future<List<CustomerOrder>> getOrders() async {
    final body = await _request(
      () => _client.get(_uri('/orders'), headers: _authHeaders()),
    );
    return _dataList(body, CustomerOrder.fromJson, 'order');
  }

  Future<CustomerOrder> getOrder(String orderId) async {
    final body = await _request(
      () => _client.get(
        _uri('/orders/${Uri.encodeComponent(orderId)}'),
        headers: _authHeaders(),
      ),
    );
    return CustomerOrder.fromJson(_dataMap(body));
  }

  Future<CustomerOrder> createOrder({
    required String restaurantId,
    required String deliveryAddress,
    required List<Map<String, Object?>> items,
    required String idempotencyKey,
  }) async {
    final body = await _request(
      () => _client.post(
        _uri('/orders'),
        headers: {..._authHeaders(), 'Idempotency-Key': idempotencyKey},
        body: jsonEncode({
          'restaurantId': restaurantId,
          'deliveryAddress': deliveryAddress,
          'items': items,
        }),
      ),
    );
    return CustomerOrder.fromJson(_dataMap(body));
  }

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> _jsonHeaders() => const {
    'Content-Type': 'application/json',
  };

  Map<String, String> _authHeaders() {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw const NdiChowApiException(
        'UNAUTHENTICATED',
        'Please sign in to continue.',
      );
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> _request(
    Future<http.Response> Function() send,
  ) async {
    try {
      final response = await send().timeout(const Duration(seconds: 15));
      return _decode(response);
    } on NdiChowApiException {
      rethrow;
    } on TimeoutException {
      throw const NdiChowApiException(
        'NETWORK_TIMEOUT',
        'The request timed out. Please try again.',
      );
    } on SocketException {
      throw const NdiChowApiException(
        'NETWORK_UNAVAILABLE',
        'Check your internet connection and try again.',
      );
    } on http.ClientException {
      throw const NdiChowApiException(
        'NETWORK_UNAVAILABLE',
        'The server could not be reached.',
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode == HttpStatus.noContent) return const {};
    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const NdiChowApiException(
        'INVALID_RESPONSE',
        'The server returned an invalid response.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const NdiChowApiException(
        'INVALID_RESPONSE',
        'The server returned an invalid response.',
      );
    }
    final error = decoded['error'];
    if (response.statusCode >= 400 || error is Map<String, dynamic>) {
      final errorMap =
          error is Map<String, dynamic> ? error : const <String, dynamic>{};
      final exception = NdiChowApiException(
        errorMap['code'] as String? ?? 'HTTP_${response.statusCode}',
        errorMap['message'] as String? ?? 'The request could not be completed.',
        statusCode: response.statusCode,
      );
      if (exception.isUnauthenticated) onUnauthorized?.call();
      throw exception;
    }
    return decoded;
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const NdiChowApiException(
        'INVALID_RESPONSE',
        'The server returned invalid data.',
      );
    }
    return data;
  }

  List<T> _dataList<T>(
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) fromJson,
    String label,
  ) {
    final data = body['data'];
    if (data is! List<dynamic>) {
      throw NdiChowApiException(
        'INVALID_RESPONSE',
        'The server returned invalid $label data.',
      );
    }
    return data
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  void close() => _client.close();
}

class NdiChowApiException implements Exception {
  const NdiChowApiException(this.code, this.message, {this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  bool get isUnauthenticated =>
      statusCode == HttpStatus.unauthorized || code == 'UNAUTHENTICATED';

  @override
  String toString() => message;
}
