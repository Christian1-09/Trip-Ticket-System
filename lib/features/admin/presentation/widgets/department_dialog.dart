// features/admin/presentation/widgets/department_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/department_model.dart';
import '../providers/department_provider.dart';

/// Add or edit a department. Pass [department] to edit, omit it to add.
class DepartmentDialog extends ConsumerStatefulWidget {
  final AdminDepartmentModel? department;
  const DepartmentDialog({super.key, this.department});

  @override
  ConsumerState<DepartmentDialog> createState() => _DepartmentDialogState();
}

class _DepartmentDialogState extends ConsumerState<DepartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;

  bool get _isEdit => widget.department != null;

  /// Frozen once the department has trips — the code is printed on tickets
  /// and nothing snapshots it, so the backend rejects a change anyway.
  bool get _codeLocked => _isEdit && !widget.department!.canEditCode;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.department?.name ?? '');
    _codeController = TextEditingController(text: widget.department?.code ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
      filled: true,
      fillColor: const Color(0xFF0D1442),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF29B6F6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
    );
  }

  Widget _label(String text, {bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: RichText(
      text: TextSpan(
        style: const TextStyle(
            color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
        children: [
          TextSpan(text: text),
          if (required)
            const TextSpan(
                text: ' *', style: TextStyle(color: Colors.amber)),
        ],
      ),
    ),
  );

  String? _nameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Required';
    if (value.trim().length > 120) return '120 characters or less';
    return null;
  }

  /// Mirrors the backend rule so the admin sees the problem before the
  /// request goes out.
  String? _codeValidator(String? value) {
    if (_codeLocked) return null;
    if (value == null || value.trim().isEmpty) return 'Required';
    final clean = value.trim().toUpperCase();
    if (clean.length > 15) return '15 characters or less';
    if (!RegExp(r'^[A-Z0-9-]+$').hasMatch(clean)) {
      return 'Letters, numbers and hyphens only';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(saveDepartmentControllerProvider.notifier).save(
      id: widget.department?.id,
      name: _nameController.text.trim(),
      // Sending null leaves the code untouched, which is what a frozen
      // code needs — sending the same value would still trip the
      // backend's "already has trips" guard.
      code: _codeLocked ? null : _codeController.text.trim().toUpperCase(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SaveDepartmentState>(saveDepartmentControllerProvider,
            (previous, next) {
          if (next is SaveDepartmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.message),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 6),
              ),
            );
          } else if (next is SaveDepartmentSuccess) {
            ref.read(saveDepartmentControllerProvider.notifier).reset();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEdit ? 'Department updated.' : 'Department added.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        });

    final isSaving =
    ref.watch(saveDepartmentControllerProvider) is SaveDepartmentLoading;

    return Dialog(
      backgroundColor: const Color(0xFF141B4D),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF29B6F6), width: 1.5),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _isEdit ? Icons.edit_outlined : Icons.apartment_outlined,
                      color: const Color(0xFF29B6F6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _isEdit ? 'Edit department' : 'Add department',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                _label('DEPARTMENT NAME'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration:
                  _fieldDecoration('e.g. College of Computer Studies'),
                  validator: _nameValidator,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),

                _label('CODE', required: !_codeLocked),
                TextFormField(
                  controller: _codeController,
                  enabled: !_codeLocked,
                  style: TextStyle(
                    color: _codeLocked ? Colors.white38 : Colors.white,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                  decoration: _fieldDecoration('e.g. CCS'),
                  validator: _codeValidator,
                  inputFormatters: [
                    // Typed lowercase becomes uppercase as you go, so what's
                    // on screen matches what gets stored.
                    TextInputFormatter.withFunction(
                          (oldValue, newValue) => newValue.copyWith(
                        text: newValue.text.toUpperCase(),
                      ),
                    ),
                  ],
                ),

                if (_codeLocked) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lock_outline,
                            color: Colors.amber, size: 15),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'The code is locked because '
                                '${widget.department!.tripCount} trip(s) already '
                                'carry it. Changing it would make printed tickets '
                                'disagree with the record. The name can still be '
                                'changed.',
                            style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 10,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D1442),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFF29B6F6), size: 15),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'A short abbreviation that appears on the printed '
                                'trip ticket. It cannot be changed once trips have '
                                'been filed under it.',
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed:
                      isSaving ? null : () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF37474F),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isSaving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF0A0F35)),
                      )
                          : Text(
                        _isEdit ? 'Save changes' : 'Add department',
                        style: const TextStyle(
                            color: Color(0xFF0A0F35),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}