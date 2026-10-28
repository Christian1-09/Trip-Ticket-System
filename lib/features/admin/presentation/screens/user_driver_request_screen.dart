// features/admin/presentation/screens/user_driver_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../providers/request_provider.dart';
import '../widgets/user_driver_data_source.dart';
import '../../data/models/request_model.dart';

/// Light admin palette (matches the Drivers screen).
class _AdminColors {
  static const pageBg = Color(0xFFF4F6FB);
  static const card = Colors.white;
  static const navy = Color(0xFF1A237E);
  static const textPrimary = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const headerBg = Color(0xFFF7F8FC);
  static const inputFill = Color(0xFFF7F8FC);
  static const danger = Color(0xFFDC2626);
}

class UserDriverRequestScreen extends ConsumerStatefulWidget {
  const UserDriverRequestScreen({super.key});

  @override
  ConsumerState<UserDriverRequestScreen> createState() => _UserDriverRequestScreenState();
}

class _UserDriverRequestScreenState extends ConsumerState<UserDriverRequestScreen> {
  Future<void> _confirmReject(RequestModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: _AdminColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reject driver application',
          style: TextStyle(color: _AdminColors.navy, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently delete ${user.fullName}\'s account. This cannot be undone.',
          style: const TextStyle(color: _AdminColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: _AdminColors.textMuted)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: _AdminColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(driverActionControllerProvider.notifier).reject(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(requestListProvider);
    final pendingCount = requestsAsync.valueOrNull?.length;

    ref.listen<DriverActionState>(driverActionControllerProvider, (previous, next) {
      if (next is DriverActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: _AdminColors.danger),
        );
      }
    });

    return Container(
      color: _AdminColors.pageBg,
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          color: _AdminColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Color(0x0F000000), blurRadius: 12, offset: Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Request',
                        style: TextStyle(
                          color: _AdminColors.navy,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pendingCount == null
                            ? 'Manage vehicle drivers'
                            : '$pendingCount pending · awaiting approval',
                        style: const TextStyle(color: _AdminColors.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(requestListProvider),
                  icon: const Icon(Icons.refresh, color: _AdminColors.navy),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Search ──────────────────────────────────────────────
            TextField(
              style: const TextStyle(color: _AdminColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search name or email...',
                hintStyle: const TextStyle(color: _AdminColors.textMuted, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: _AdminColors.navy, size: 20),
                filled: true,
                fillColor: _AdminColors.inputFill,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _AdminColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _AdminColors.navy, width: 1.2),
                ),
              ),
              onChanged: (val) => ref.read(requestSearchProvider.notifier).state = val,
            ),
            const SizedBox(height: 20),

            // ── Table ───────────────────────────────────────────────
            Expanded(
              child: requestsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _AdminColors.navy),
                ),
                error: (err, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: _AdminColors.danger, size: 32),
                      const SizedBox(height: 8),
                      const Text('Could not load driver requests',
                          style: TextStyle(color: _AdminColors.textPrimary)),
                      const SizedBox(height: 4),
                      // TEMPORARY: shows the real error while we debug.
                      Text('$err',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: _AdminColors.textMuted, fontSize: 11)),
                      TextButton(
                        onPressed: () => ref.invalidate(requestListProvider),
                        child: const Text('Retry', style: TextStyle(color: _AdminColors.navy)),
                      ),
                    ],
                  ),
                ),
                data: (users) {
                  final search = ref.watch(requestSearchProvider).toLowerCase();
                  final filtered = search.isEmpty
                      ? users
                      : users
                      .where((u) =>
                  u.fullName.toLowerCase().contains(search) ||
                      u.email.toLowerCase().contains(search))
                      .toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('No pending driver requests.',
                          style: TextStyle(color: _AdminColors.textMuted)),
                    );
                  }

                  final dataSource = UserDriverDataSource(
                    users: filtered,
                    onReject: _confirmReject,
                    onApprove: (user) =>
                        ref.read(driverActionControllerProvider.notifier).approve(user.id),
                  );

                  return Container(
                    decoration: BoxDecoration(
                      color: _AdminColors.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _AdminColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SfDataGridTheme(
                      data: const SfDataGridThemeData(
                        headerColor: _AdminColors.headerBg,
                        gridLineColor: _AdminColors.border,
                        gridLineStrokeWidth: 1,
                      ),
                      child: SfDataGrid(
                        source: dataSource,
                        columnWidthMode: ColumnWidthMode.fill,
                        gridLinesVisibility: GridLinesVisibility.horizontal,
                        headerGridLinesVisibility: GridLinesVisibility.horizontal,
                        headerRowHeight: 46,
                        rowHeight: 50,
                        columns: [
                          _column('id', 'ID', width: 110),
                          _column('name', 'Name'),
                          _column('email', 'Email'),
                          _column('phone', 'Contact'),
                          _column('date', 'Registered'),
                          _column('status', 'Status', alignCenter: true),
                          _column('action', 'Action', alignCenter: true, width: 200),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  GridColumn _column(String name, String label, {double? width, bool alignCenter = false}) {
    return GridColumn(
      columnName: name,
      width: width ?? double.nan,
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: alignCenter ? Alignment.center : Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}