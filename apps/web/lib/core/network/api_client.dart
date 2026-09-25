import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  ApiException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  final String message;
  final int? statusCode;
  final List<ApiFieldError> errors;

  @override
  String toString() => message;
}

class ApiFieldError {
  const ApiFieldError({required this.field, required this.message});

  final String field;
  final String message;

  factory ApiFieldError.fromJson(Map<String, dynamic> json) {
    return ApiFieldError(
      field: json['field']?.toString() ?? '',
      message: json['message']?.toString() ?? 'Invalid value',
    );
  }
}

typedef UnauthorizedHandler = void Function();

class ApiClient {
  ApiClient({
    required this._tokenStorage,
    http.Client? httpClient,
    this.onUnauthorized,
  }) : _http = httpClient ?? http.Client();

  final TokenStorage _tokenStorage;
  final http.Client _http;
  UnauthorizedHandler? onUnauthorized;

  Uri _uri(String path) {
    final base = AppConstants.apiBaseUrl.replaceAll(RegExp(r'/+$'), '');
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$base$normalized');
  }

  Map<String, String> _headers({bool auth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = _tokenStorage.token;
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<dynamic> get(String path, {bool auth = true}) async {
    final response = await _http.get(_uri(path), headers: _headers(auth: auth));
    return _handleResponse(response);
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers(auth: auth),
      body: body == null ? null : jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    Map<String, dynamic>? json;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        }
      } catch (_) {
        json = null;
      }
    }

    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw ApiException(
        message: _extractMessage(json) ?? 'Unauthorized',
        statusCode: 401,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (json == null) return null;
      if (json['success'] == false) {
        throw ApiException(
          message: _extractMessage(json) ?? 'Request failed',
          statusCode: response.statusCode,
          errors: _extractErrors(json),
        );
      }
      if (json.containsKey('data')) {
        return json['data'];
      }
      return json;
    }

    throw ApiException(
      message: _extractMessage(json) ?? 'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
      errors: _extractErrors(json),
    );
  }

  String? _extractMessage(Map<String, dynamic>? json) {
    if (json == null) return null;
    final message = json['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) {
      return message.map((e) => e.toString()).join(', ');
    }
    return null;
  }

  List<ApiFieldError> _extractErrors(Map<String, dynamic>? json) {
    if (json == null) return const [];
    final errors = json['errors'];
    if (errors is! List) return const [];
    return errors
        .whereType<Map<String, dynamic>>()
        .map(ApiFieldError.fromJson)
        .toList();
  }
}
