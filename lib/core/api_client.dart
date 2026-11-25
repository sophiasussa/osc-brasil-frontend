import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // Configure with:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  Future<dynamic> get(
    String path, {
    Map<String, String?> queryParameters = const {},
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters: {
        for (final entry in queryParameters.entries)
          if (entry.value != null && entry.value!.isNotEmpty)
            entry.key: entry.value!,
      },
    );

    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );

    final body = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'Não foi possível carregar os dados.';
      if (body is Map && body['detail'] != null) {
        message = body['detail'].toString();
      }
      throw ApiException(message, response.statusCode);
    }

    return body;
  }

  void close() => _client.close();
}

class ApiException implements Exception {
  ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
