import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/models/restaurant.dart';

class NdiChowApiClient {
  NdiChowApiClient({required this.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<Restaurant>> getRestaurants({String? query}) async {
    final uri = Uri.parse('$baseUrl/restaurants').replace(
      queryParameters:
          query == null || query.trim().isEmpty ? null : {'q': query.trim()},
    );
    final response = await _client
        .get(uri)
        .timeout(const Duration(seconds: 12));
    final body = _decode(response);
    final data = body['data'];
    if (data is! List<dynamic>) {
      throw const NdiChowApiException(
        'INVALID_RESPONSE',
        'The server returned invalid restaurant data.',
      );
    }
    return data
        .map((item) => Restaurant.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Map<String, dynamic> _decode(http.Response response) {
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
      throw NdiChowApiException(
        errorMap['code'] as String? ?? 'HTTP_${response.statusCode}',
        errorMap['message'] as String? ?? 'The request could not be completed.',
      );
    }
    return decoded;
  }

  void close() => _client.close();
}

class NdiChowApiException implements Exception {
  const NdiChowApiException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => message;
}
