// features/admin/presentation/screens/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';

import '../../data/models/settings_model.dart';
import '../providers/admin_settings_provider.dart';

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
        backgroundColor: error ? Colors.redAccent : Colors.green,
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

    return Stack(
      children: [
        async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    err is ApiException ? err.message : 'Could not load settings.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(adminSettingsProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B4EDB),
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
          data: (settings) {
            _seed(settings);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Settings',
                      style: TextStyle(
                          color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const Text('Trip ticket details and notification rules',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 24),

                  // ---------- Printed ticket ----------
                  _card(
                    title: 'PRINTED TRIP TICKET',
                    subtitle:
                    'This name and title are printed on the "Approved:" line of every '
                        'trip ticket. Update it when the GSO unit head changes.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!settings.hasApprover) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.withOpacity(0.6)),
                            ),
                            child: const Text(
                              'No approver is set, so tickets print with a blank approval line.',
                              style: TextStyle(color: Colors.amber, fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                        _field(
                          controller: _nameController,
                          label: 'Approver name',
                          hint: 'e.g. Adelfa V. Moyet, MBA',
                        ),
                        const SizedBox(height: 12),
                        _field(
                          controller: _titleController,
                          label: 'Position / title',
                          hint: 'Administrative Officer V/GSO Unit Head',
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: _busy ? null : _saveApprover,
                            icon: const Icon(Icons.save_rounded,
                                size: 16, color: Colors.white),
                            label: const Text('Save approver',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B4EDB),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Tickets printed earlier keep the name they were printed with.',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------- Notifications ----------
                  _card(
                    title: 'NOTIFICATIONS',
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
                          onChanged: (val) => _toggle('sendTripCompletionReminder', val),
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
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
        if (_busy)
          Container(
            color: Colors.black38,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141B4D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 18),
          child,
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0D1442),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF3B4EDB)),
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
            : const Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description,
                    style: const TextStyle(color: Colors.white38, fontSize: 11.5)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: _busy ? null : onChanged,
            activeColor: const Color(0xFF3B4EDB),
          ),
        ],
      ),
    );
  }
}