// features/admin/presentation/screens/DriverScreen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/core/theme/network/api_exception.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/driver_model.dart';
import '../providers/driver_provider.dart';
import '../widgets/driver_data_source.dart';

class DriverScreen extends ConsumerStatefulWidget {
  const DriverScreen({super.key});

  @override
  ConsumerState<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends ConsumerState<DriverScreen> {
  bool _busy = false;

  // ------------------------------------------------------
  // Actions (logic unchanged)
  // ------------------------------------------------------

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.redAccent : Colors.green,
        duration: Duration(seconds: error ? 6 : 3),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action, String successMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      ref.invalidate(driverListProvider);
      _showMessage(successMessage);
    } on ApiException catch (e) {
      _showMessage(e.message, error: true);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleStatus(AdminDriverModel driver) async {
    final goingOffDuty = driver.status != DriverStatus.offDuty;
    final newStatus = goingOffDuty ? 'OFF_DUTY' : 'AVAILABLE';

    final confirmed = await _confirm(
      title: goingOffDuty ? 'Set off duty' : 'Set available',
      message: goingOffDuty
          ? '${driver.fullName} will not appear in the driver list for new trips until you set them available again.'
          : '${driver.fullName} can be assigned new trips again.',
      confirmLabel: goingOffDuty ? 'Set Off Duty' : 'Set Available',
    );
    if (!confirmed) return;

    await _run(
          () => ref.read(adminDriverRepositoryProvider).setStatus(driver.id, newStatus),
      goingOffDuty
          ? '${driver.fullName} is now off duty.'
          : '${driver.fullName} is now available.',
    );
  }

  Future<void> _changeRole(AdminDriverModel driver) async {
    final promoting = !driver.isHeadDriver;
    final newRole = promoting ? 'HEAD_DRIVER' : 'DRIVER';

    final confirmed = await _confirm(
      title: promoting ? 'Make Head Driver' : 'Demote to Driver',
      message: promoting
          ? '${driver.fullName} will approve trip requests after the admin, and will also pick a replacement when a driver declines. Only one head driver is allowed at a time.'
          : '${driver.fullName} will go back to being a normal driver and will no longer approve trips. Their assigned trips stay with them.',
      confirmLabel: promoting ? 'Make Head Driver' : 'Demote',
    );
    if (!confirmed) return;

    await _run(
          () => ref.read(adminDriverRepositoryProvider).updateRole(driver.id, newRole),
      promoting
          ? '${driver.fullName} is now the Head Driver.'
          : '${driver.fullName} is now a Driver.',
    );
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style: const TextStyle(
                color: AdminColors.navy, fontWeight: FontWeight.w800)),
        content: Text(message, style: const TextStyle(color: AdminColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: AdminColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AdminColors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ------------------------------------------------------
  // Build
  // ------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final driversAsync = ref.watch(driverListProvider);
    final filtered = ref.watch(filteredDriverListProvider);
    final headDriverExists = ref.watch(hasHeadDriverProvider);

    return ColoredBox(
      color: AdminColors.background,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            // The whole page sits in one big white card, like the mockup.
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AdminColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ─────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Driver',
                                style: TextStyle(
                                    color: AdminColors.navy,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 2),
                            Text(
                              driversAsync.when(
                                data: (drivers) => drivers.isEmpty
                                    ? 'No approved drivers yet'
                                    : '${drivers.length} approved '
                                    '${headDriverExists ? '· head driver assigned' : '· no head driver'}',
                                loading: () => 'Loading...',
                                error: (_, __) => 'Could not load drivers',
                              ),
                              style: const TextStyle(
                                  color: AdminColors.textMuted, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Refresh',
                        onPressed: () => ref.invalidate(driverListProvider),
                        icon: const Icon(Icons.refresh,
                            color: AdminColors.navy, size: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Search + filter ────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: TextField(
                            style: const TextStyle(
                                color: AdminColors.navy, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search name, code, email, vehicle...',
                              hintStyle: const TextStyle(
                                  color: AdminColors.textMuted, fontSize: 14),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 14, right: 6),
                                child: Icon(Icons.search,
                                    color: AdminColors.navy, size: 20),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF6F8FC),
                              contentPadding: EdgeInsets.zero,
                              enabledBorder: _border(AdminColors.border),
                              focusedBorder: _border(AdminColors.blue),
                            ),
                            onChanged: (val) =>
                            ref.read(driverSearchProvider.notifier).state = val,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        height: 46,
                        width: 110,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AdminColors.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: ref.watch(driverStatusFilterProvider),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            style: const TextStyle(
                                color: AdminColors.navy,
                                fontSize: 14,
                                fontWeight: FontWeight.w500),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: AdminColors.navy, size: 20),
                            items: const ['All', 'Available', 'On Trip', 'Off Duty']
                                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (val) => ref
                                .read(driverStatusFilterProvider.notifier)
                                .state = val!,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // ── Table ──────────────────────────────────────
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AdminColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: driversAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, _) => _errorView(err),
                        data: (_) => filtered.isEmpty
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No drivers match this search.\n'
                                  'New drivers appear here once you approve them in User/Driver Request.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: AdminColors.textMuted, fontSize: 13),
                            ),
                          ),
                        )
                            : SfDataGridTheme(
                          data: const SfDataGridThemeData(
                            headerColor: Color(0xFFF6F8FC),
                            gridLineColor: AdminColors.border,
                            gridLineStrokeWidth: 1,
                            rowHoverColor: Color(0xFFF9FAFD),
                          ),
                          child: SfDataGrid(
                            source: DriverDataSource(
                              drivers: filtered,
                              headDriverExists: headDriverExists,
                              busy: _busy,
                              onToggleStatus: _toggleStatus,
                              onChangeRole: _changeRole,
                            ),
                            gridLinesVisibility: GridLinesVisibility.horizontal,
                            headerGridLinesVisibility:
                            GridLinesVisibility.horizontal,
                            columnWidthMode: ColumnWidthMode.fill,
                            headerRowHeight: 46,
                            rowHeight: 50,
                            columns: [
                              _column('code', 'Driver Code', width: 130),
                              _column('name', 'Name'),
                              _column('contact', 'Contact', width: 140),
                              _column('role', 'Role', width: 120),
                              _column('vehicle', 'Usual Vehicle'),
                              _column('trips', 'Trips', width: 75),
                              _column('rating', 'Rating', width: 110),
                              _column('status', 'Status',
                                  alignCenter: true, width: 120),
                              _column('action', 'Action',
                                  alignCenter: true, width: 230),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_busy)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );

  Widget _errorView(Object error) {
    final message = error is ApiException ? error.message : 'Could not load drivers.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 14)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => ref.invalidate(driverListProvider),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AdminColors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Retry'),
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
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF5B6582), fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}