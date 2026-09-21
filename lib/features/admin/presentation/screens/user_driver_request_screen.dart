// features/admin/presentation/screens/user_driver_request_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import '../providers/request_provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../widgets/user_driver_data_source.dart';
import '../../data/models/request_model.dart';

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
        backgroundColor: const Color(0xFF141B4D),
        title: const Text('Reject driver application', style: TextStyle(color: Colors.white)),
        content: Text(
          'This will permanently delete ${user.fullName}\'s account. This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
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

    ref.listen<DriverActionState>(driverActionControllerProvider, (previous, next) {
      if (next is DriverActionError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.redAccent),
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Request',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('Manage vehicle drivers',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),

          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search user...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 18),
              filled: true,
              fillColor: const Color(0xFF141B4D),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.white24),
              ),
            ),
            onChanged: (val) => ref.read(requestSearchProvider.notifier).state = val,
          ),
          const SizedBox(height: 20),

          Expanded(
            child: requestsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                    const SizedBox(height: 8),
                    const Text('Could not load driver requests',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 4),
                    // TEMPORARY: shows the real error while we debug.
                    Text('$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
                    TextButton(
                      onPressed: () => ref.invalidate(requestListProvider),
                      child: const Text('Retry'),
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
                        style: TextStyle(color: Colors.white54)),
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
                    color: const Color(0xFF141B4D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: SfDataGridTheme(
                    data: SfDataGridThemeData(
                      headerColor: const Color(0xFF1E2761),
                      gridLineColor: Colors.white12,
                      gridLineStrokeWidth: 0.5,
                    ),
                    child: SfDataGrid(
                      source: dataSource,
                      columnWidthMode: ColumnWidthMode.fill,
                      headerRowHeight: 46,
                      rowHeight: 52,
                      columns: [
                        _column('id', 'ID', width: 90),
                        _column('name', 'NAME'),
                        _column('email', 'EMAIL'),
                        _column('phone', 'PHONE'),
                        _column('date', 'REGISTERED'),
                        _column('status', 'STATUS', alignCenter: true),
                        _column('action', 'ACTION', alignCenter: true),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        child: Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}