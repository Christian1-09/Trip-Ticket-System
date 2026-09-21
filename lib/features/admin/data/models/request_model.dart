// features/admin/data/models/request_model.dart

/// Represents a driver awaiting admin approval. Every row this app ever
/// fetches from GET /api/admin/drivers/pending is, by definition, pending —
/// once approved or rejected, the backend stops returning it, so there's
/// no separate "approved"/"rejected" state to track here.
class RequestModel {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final DateTime createdAt;

  const RequestModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.createdAt,
    this.phone,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}