import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:jtrips_app/core/theme/config/api_config.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

class MultipartFilePart {
  final String fieldName;
  final Uint8List bytes;
  final String filename;
  final String mimeType;

  MultipartFilePart({
    required this.fieldName,
    required this.bytes,
    required this.filename,
    this.mimeType = 'application/octet-stream',
  });
}

/// Thin wrapper around the `http` package so every call in the app:
/// - points at the same base URL
/// - sends/parses JSON automatically
/// - throws a single, consistent [ApiException] on failure
/// - never hangs forever — every call times out after 10 seconds
class ApiClient {
  final http.Client _client;
  static const _timeout = Duration(seconds: 10);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Map<String, String> _headers(String? accessToken) => {
    'Content-Type': 'application/json',
    if (accessToken != null) 'Authorization': 'Bearer $accessToken',
  };

  Future<Map<String, dynamic>> post(
      String path, {
        Map<String, dynamic>? body,
        String? accessToken,
      }) async {
    final response = await _client
        .post(
      _uri(path),
      headers: _headers(accessToken),
      body: jsonEncode(body ?? {}),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw ApiException(
        'Request timed out. Check that the backend is running and reachable.',
        408,
      ),
    );
    return _handleResponse(response);
  }

  /// JSON PATCH — used for partial updates such as changing a driver's
  /// status or role. (patchMultipart below is only for file uploads.)
  Future<Map<String, dynamic>> patch(
      String path, {
        Map<String, dynamic>? body,
        String? accessToken,
      }) async {
    final response = await _client
        .patch(
      _uri(path),
      headers: _headers(accessToken),
      body: jsonEncode(body ?? {}),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw ApiException(
        'Request timed out. Check that the backend is running and reachable.',
        408,
      ),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
      String path, {
        String? accessToken,
      }) async {
    final response = await _client
        .get(
      _uri(path),
      headers: _headers(accessToken),
    )
        .timeout(
      _timeout,
      onTimeout: () => throw ApiException(
        'Request timed out. Check that the backend is running and reachable.',
        408,
      ),
    );
    return _handleResponse(response);
  }

  /// Single-file upload — kept for the avatar feature.
  Future<Map<String, dynamic>> patchMultipart(
      String path, {
        required String fieldName,
        required Uint8List bytes,
        required String filename,
        String? accessToken,
        String mimeType = 'image/jpeg',
      }) async {
    return _sendMultipart(
      method: 'PATCH',
      path: path,
      fields: const {},
      files: [
        MultipartFilePart(fieldName: fieldName, bytes: bytes, filename: filename, mimeType: mimeType),
      ],
      accessToken: accessToken,
    );
  }

  /// General-purpose multipart POST — text [fields] plus zero or more
  /// [files]. Used for the trip request submission (several text fields,
  /// two optional file uploads).
  Future<Map<String, dynamic>> postMultipart(
      String path, {
        required Map<String, String> fields,
        List<MultipartFilePart> files = const [],
        String? accessToken,
      }) async {
    return _sendMultipart(
      method: 'POST',
      path: path,
      fields: fields,
      files: files,
      accessToken: accessToken,
    );
  }

  Future<Map<String, dynamic>> _sendMultipart({
    required String method,
    required String path,
    required Map<String, String> fields,
    required List<MultipartFilePart> files,
    String? accessToken,
  }) async {
    final request = http.MultipartRequest(method, _uri(path));
    if (accessToken != null) {
      request.headers['Authorization'] = 'Bearer $accessToken';
    }
    request.fields.addAll(fields);

    for (final file in files) {
      final parts = file.mimeType.split('/');
      request.files.add(
        http.MultipartFile.fromBytes(
          file.fieldName,
          file.bytes,
          filename: file.filename,
          contentType: MediaType(parts[0], parts.length > 1 ? parts[1] : 'octet-stream'),
        ),
      );
    }

    final streamedResponse = await request.send().timeout(
      _timeout,
      onTimeout: () => throw ApiException(
        'Upload timed out. Check that the backend is running and reachable.',
        408,
      ),
    );
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 204) return {};

    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        throw ApiException(
          'Unexpected server response (${response.statusCode})',
          response.statusCode,
        );
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded['message'] as String? ??
        'Something went wrong (${response.statusCode})';
    throw ApiException(message, response.statusCode);
  }
}