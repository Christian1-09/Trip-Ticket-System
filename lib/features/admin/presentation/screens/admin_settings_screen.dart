// features/admin/presentation/screens/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../data/models/settings_model.dart';
import '../providers/admin_settings_provider.dart';

/// Light admin palette (matches the Drivers screen).
class _AdminColors {
  static const pageBg = Color(0xFFF4F6FB);
  static const card = Colors.white;
  static const navy = Color(0xFF1A237E);
  static const accent = Color(0xFF9C27F0);
  static const textPrimary = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);
  static const textFaint = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const inputFill = Color(0xFFF7F8FC);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const warnBg = Color(0xFFFFF4DB);
  static const warnBorder = Color(0xFFF5D38A);
  static const warnText = Color(0xFFB7791F);
}

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  final _nameController = TextEditingController();
  final _titleController = TextEditingController();
  bool _busy = false;
  bool _seeded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  /// Fills the text fields once, the first time the settings arrive, so
  /// typing is never overwritten by a later rebuild.
  void _seed(SystemSettingsModel settings) {
    if (_seeded) return;
    _seeded = true;
    _nameController.text = settings.approverName ?? '';
    _titleController.text = settings.approverTitle;
  }

  void _message(String text, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: error ? _AdminColors.danger : _AdminColors.success,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _save(Future<void> Function() action, String success) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(adminSettingsProvider);
      _message(success);
    } on ApiException catch (e) {
      _message(e.message, error: true);
    } catch (_) {
      _message('Could not save. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveApprover() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _message('Enter the approver\'s name.', error: true);
      return;
    }
    await _save(
          () => ref.read(adminSettingsRepositoryProvider).updateSettings(
        approverName: name,
        approverTitle: _titleController.text.trim(),
      ),
      'Approver saved. It will appear on newly printed tickets.',
    );
  }

  Future<void> _toggle(String field, bool value) async {
    await _save(
          () {
        final repo = ref.read(adminSettingsRepositoryProvider);
        switch (field) {
          case 'notifyRequesterOnApprovalRejection':
            return repo.updateSettings(notifyRequesterOnApprovalRejection: value);
          case 'notifyDriverWhenAssigned':
            return repo.updateSettings(notifyDriverWhenAssigned: value);
          case 'sendTripCompletionReminder':
            return repo.updateSettings(sendTripCompletionReminder: value);
          default:
            return repo.updateSettings(alertAdminOnOverdueIncompleteTrips: value);
        }
      },
      'Setting updated.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminSettingsProvider);

    return Container(
      color: _AdminColors.pageBg,
      child: Stack(
        children: [
          async.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: _AdminColors.navy),
            ),
            error: (err, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: _AdminColors.danger, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      err is ApiException ? err.message : 'Could not load settings.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: _AdminColors.textPrimary, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    _primaryButton(
                      label: 'Retry',
                      onPressed: () => ref.invalidate(adminSettingsProvider),
                    ),
                  ],
                ),
              ),
            ),
            data: (settings) {
              _seed(settings);
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  decoration: BoxDecoration(
                    color: _AdminColors.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          color: _AdminColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Trip ticket details and notification rules',
                        style: TextStyle(color: _AdminColors.textMuted, fontSize: 14),
                      ),
                      const SizedBox(height: 24),

                      // ---------- Printed ticket ----------
                      _section(
                        title: 'Printed trip ticket',
                        subtitle:
                        'This name and title are printed on the "Approved:" line of every '
                            'trip ticket. Update it when the GSO unit head changes.',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!settings.hasApprover) ...[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _AdminColors.warnBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _AdminColors.warnBorder),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded,
                                        color: _AdminColors.warnText, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'No approver is set, so tickets print with a blank approval line.',
                                        style: TextStyle(
                                            color: _AdminColors.warnText,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _field(
                              controller: _nameController,
                              label: 'Approver name',
                              hint: 'e.g. Adelfa V. Moyet, MBA',
                            ),
                            const SizedBox(height: 14),
                            _field(
                              controller: _titleController,
                              label: 'Position / title',
                              hint: 'Administrative Officer V/GSO Unit Head',
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Tickets printed earlier keep the name they were printed with.',
                                    style: TextStyle(
                                        color: _AdminColors.textFaint, fontSize: 11.5),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                _primaryButton(
                                  label: 'Save approver',
                                  icon: Icons.save_rounded,
                                  onPressed: _busy ? null : _saveApprover,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ---------- Notifications ----------
                      _section(
                        title: 'Notifications',
                        subtitle: 'These apply to everyone, not just your own account.',
                        child: Column(
                          children: [
                            _toggleRow(
                              label: 'Notify the requester on approval or rejection',
                              description:
                              'Sends a notification each time a trip is approved or rejected.',
                              value: settings.notifyRequesterOnApprovalRejection,
                              onChanged: (val) =>
                                  _toggle('notifyRequesterOnApprovalRejection', val),
                            ),
                            _toggleRow(
                              label: 'Notify the driver when assigned',
                              description:
                              'Tells the driver a trip is waiting for them to accept.',
                              value: settings.notifyDriverWhenAssigned,
                              onChanged: (val) => _toggle('notifyDriverWhenAssigned', val),
                            ),
                            _toggleRow(
                              label: 'Send trip completion reminders',
                              description:
                              'Reminds the driver to record the return after a trip ends.',
                              value: settings.sendTripCompletionReminder,
                              onChanged: (val) =>
                                  _toggle('sendTripCompletionReminder', val),
                            ),
                            _toggleRow(
                              label: 'Alert admins about overdue trips',
                              description:
                              'Flags trips still ongoing well past their return time.',
                              value: settings.alertAdminOnOverdueIncompleteTrips,
                              onChanged: (val) =>
                                  _toggle('alertAdminOnOverdueIncompleteTrips', val),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_busy)
            Container(
              color: const Color(0x80FFFFFF),
              child: const Center(
                child: CircularProgressIndicator(color: _AdminColors.navy),
              ),
            ),
        ],
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: _AdminColors.accent,
      foregroundColor: Colors.white,
      disabledBackgroundColor: const Color(0xFFD8B4FE),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
    const textStyle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600);

    if (icon == null) {
      return ElevatedButton(
        onPressed: onPressed,
        style: style,
        child: Text(label, style: textStyle),
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: style,
      icon: Icon(icon, size: 16),
      label: Text(label, style: textStyle),
    );
  }

  /// A bordered panel inside the main card, like the table on the Drivers screen.
  Widget _section({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _AdminColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _AdminColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            decoration: const BoxDecoration(
              color: _AdminColors.inputFill,
              border: Border(bottom: BorderSide(color: _AdminColors.border)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _AdminColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: const TextStyle(color: _AdminColors.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: _AdminColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: _AdminColors.textFaint, fontSize: 14),
            filled: true,
            fillColor: _AdminColors.inputFill,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _AdminColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _AdminColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: _AdminColors.navy, width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toggleRow({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: _AdminColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: _AdminColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(color: _AdminColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: _busy ? null : onChanged,
            activeColor: Colors.white,
            activeTrackColor: _AdminColors.accent,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
            trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          ),
        ],
      ),
    );
  }
}