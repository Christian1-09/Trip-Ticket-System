/// Thrown by [ApiClient] whenever the backend responds with a non-2xx
/// status code. Carries the backend's own error message so the UI can
/// show something meaningful instead of a raw HTTP error.
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
