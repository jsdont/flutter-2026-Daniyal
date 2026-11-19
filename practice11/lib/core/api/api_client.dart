import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get headers => {'Accept': 'application/json'};

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(host, path, queryParameters);
    final response = await _send(() => _client.get(uri, headers: headers));
    _check(response, 200);
    return _decode(response);
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.https(host, path);
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(response, 201);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));
      if (kDebugMode) {
        log(
          '${response.request?.method} ${response.request?.url.path}'
          ' → ${response.statusCode}',
          name: 'api',
        );
      }
      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response, int expectedStatus) {
    final status = response.statusCode;
    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);
    if (status != expectedStatus) {
      throw BadResponseException('HTTP $status, expected $expectedStatus');
    }
  }

  dynamic _decode(http.Response response) {
    try {
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      throw BadResponseException(error.message);
    }
  }

  void close() {
    _client.close();
  }
}
