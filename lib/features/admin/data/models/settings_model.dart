// features/admin/data/models/settings_model.dart

/// The single SystemSettings row. approverName / approverTitle are printed
/// on every trip ticket's "Approved:" line.
class SystemSettingsModel {
  final bool notifyRequesterOnApprovalRejection;
  final bool notifyDriverWhenAssigned;
  final bool sendTripCompletionReminder;
  final bool alertAdminOnOverdueIncompleteTrips;
  final String? approverName;
  final String approverTitle;

  const SystemSettingsModel({
    required this.notifyRequesterOnApprovalRejection,
    required this.notifyDriverWhenAssigned,
    required this.sendTripCompletionReminder,
    required this.alertAdminOnOverdueIncompleteTrips,
    this.approverName,
    required this.approverTitle,
  });

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    bool b(String key) => json[key] as bool? ?? true;
    return SystemSettingsModel(
      notifyRequesterOnApprovalRejection: b('notifyRequesterOnApprovalRejection'),
      notifyDriverWhenAssigned: b('notifyDriverWhenAssigned'),
      sendTripCompletionReminder: b('sendTripCompletionReminder'),
      alertAdminOnOverdueIncompleteTrips: b('alertAdminOnOverdueIncompleteTrips'),
      approverName: json['approverName'] as String?,
      approverTitle: json['approverTitle'] as String? ??
          'Administrative Officer V/GSO Unit Head',
    );
  }

  bool get hasApprover => (approverName ?? '').trim().isNotEmpty;
}