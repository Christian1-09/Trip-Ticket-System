// features/admin/presentation/providers/driver_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jtrips_app/features/auth/presentation/providers/auth_controller.dart'
    show apiClientProvider, tokenStorageProvider;

import '../../data/admin_driver_repository.dart';
import '../../data/models/driver_model.dart';

final adminDriverRepositoryProvider = Provider<AdminDriverRepository>((ref) {
  return AdminDriverRepository(
    apiClient: ref.watch(apiClientProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});

/// Approved drivers straight from the backend.
/// Call ref.invalidate(driverListProvider) after any change.
final driverListProvider = FutureProvider<List<AdminDriverModel>>((ref) {
  return ref.watch(adminDriverRepositoryProvider).getDrivers();
});

final driverSearchProvider = StateProvider<String>((ref) => '');
final driverStatusFilterProvider = StateProvider<String>((ref) => 'All');

final filteredDriverListProvider = Provider<List<AdminDriverModel>>((ref) {
  final drivers = ref.watch(driverListProvider).value ?? [];
  final search = ref.watch(driverSearchProvider).trim().toLowerCase();
  final statusFilter = ref.watch(driverStatusFilterProvider);

  return drivers.where((driver) {
    if (statusFilter == 'Available' && driver.status != DriverStatus.available) {
      return false;
    }
    if (statusFilter == 'On Trip' && driver.status != DriverStatus.onTrip) {
      return false;
    }
    if (statusFilter == 'Off Duty' && driver.status != DriverStatus.offDuty) {
      return false;
    }

    if (search.isEmpty) return true;

    final haystack = [
      driver.fullName,
      driver.email,
      driver.driverCode ?? '',
      driver.contact,
      driver.roleLabel,
      driver.vehicleLabel,
    ].join(' ').toLowerCase();

    return haystack.contains(search);
  }).toList();
});

/// True when someone already holds the Head Driver role, so the promote
/// option can be hidden for everyone else (only one is allowed at a time).
final hasHeadDriverProvider = Provider<bool>((ref) {
  final drivers = ref.watch(driverListProvider).value ?? [];
  return drivers.any((d) => d.isHeadDriver);
});