// features/admin/presentation/widgets/vehicle_map_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/admin_colors.dart';
import '../../data/models/tracking_model.dart';
import '../providers/tracking_provider.dart';

/// CARTO Positron. No API key, no sign-up, and a pale basemap so the route
/// line and markers stay the loudest things on screen.
///
/// Deliberately a single host rather than the `{s}` subdomain template:
/// flutter_map has been deprecating `subdomains`, and one host is one less
/// thing to break on a version bump.
const _tileUrl = 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';

/// Live position of one vehicle, with the route it has driven on this trip.
///
/// Opened from the vehicle card. Refreshes itself every 10 seconds for as
/// long as it is open, and stops the moment it closes — see
/// [vehicleTrackProvider].
class VehicleMapDialog extends ConsumerStatefulWidget {
  final String vehicleId;
  final String vehicleName;
  final String plateNumber;

  const VehicleMapDialog({
    required this.vehicleId,
    required this.vehicleName,
    required this.plateNumber,
    super.key,
  });

  @override
  ConsumerState<VehicleMapDialog> createState() => _VehicleMapDialogState();
}

class _VehicleMapDialogState extends ConsumerState<VehicleMapDialog> {
  final MapController _map = MapController();

  /// Moving the camera before the map has laid itself out throws, so every
  /// programmatic move waits for this.
  bool _ready = false;

  /// Keeps the camera on the vehicle as new fixes arrive. Turned off the
  /// moment the admin drags the map, so panning away to look at something
  /// isn't undone a few seconds later.
  bool _follow = true;

  void _recenter(LatLng target, {double? zoom}) {
    if (!_ready) return;
    _map.move(target, zoom ?? _map.camera.zoom);
  }

  void _fitRoute(List<LatLng> route) {
    if (!_ready || route.length < 2) return;
    setState(() => _follow = false);
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(route),
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keeping the camera on the vehicle happens here rather than in build,
    // so it fires once per new fix instead of on every rebuild.
    ref.listen<AsyncValue<VehicleTrackView>>(
      vehicleTrackProvider(widget.vehicleId),
          (previous, next) {
        final position = next.valueOrNull?.live?.position;
        if (_follow && position != null) _recenter(position);
      },
    );

    final async = ref.watch(vehicleTrackProvider(widget.vehicleId));
    // valueOrNull, never .value — .value re-throws while reloading and
    // would red the whole dialog on one dropped request.
    final view = async.valueOrNull;

    final size = MediaQuery.sizeOf(context);

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      insetPadding: const EdgeInsets.all(28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: (size.width - 80).clamp(320.0, 1040.0),
        height: size.height * 0.84,
        child: Column(
          children: [
            _Header(
              vehicleName: widget.vehicleName,
              plateNumber: widget.plateNumber,
              view: view,
              refreshing: async.isLoading && view != null,
            ),
            const Divider(height: 1, color: AdminColors.border),
            Expanded(child: _body(async, view)),
            if (view != null) _Footer(view: view),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------------------

  Widget _body(AsyncValue<VehicleTrackView> async, VehicleTrackView? view) {
    // First load only — a refresh keeps the old map on screen.
    if (view == null && async.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (view == null) {
      return _Empty(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load the position',
        message: '${async.error}',
        action: TextButton(
          onPressed: () => ref.invalidate(vehicleTrackProvider(widget.vehicleId)),
          child: const Text('Try again'),
        ),
      );
    }

    final live = view.live;

    if (live == null) {
      return const _Empty(
        icon: Icons.help_outline_rounded,
        title: 'Vehicle not found',
        message: 'It may have been deactivated. Refresh the vehicle list.',
      );
    }

    if (!live.hasDevice) {
      return const _Empty(
        icon: Icons.sensors_off_rounded,
        title: 'No tracker fitted',
        message:
        'Pair a GPS device to this vehicle before its position can be shown.',
      );
    }

    if (!live.hasPosition) {
      return const _Empty(
        icon: Icons.satellite_alt_outlined,
        title: 'Waiting for the first fix',
        message:
        'The tracker is paired but has not reported a position yet. A GPS '
            'module needs a clear view of the sky, and a cold start can take '
            'a minute or two.',
      );
    }

    return _map_(view, live);
  }

  Widget _map_(VehicleTrackView view, LiveVehicle live) {
    final route = view.track?.route ?? const <LatLng>[];
    final fence = view.track?.fence;
    final here = live.position!;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: here,
            initialZoom: 15,
            minZoom: 4,
            maxZoom: 18,
            onMapReady: () {
              _ready = true;
              // Opening on the whole journey reads better than opening
              // zoomed onto a dot with no context.
              if (route.length > 1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _fitRoute(route);
                  setState(() => _follow = true);
                });
              }
            },
            // Any drag means the admin wants to look somewhere specific.
            onPointerDown: (_, __) {
              if (_follow) setState(() => _follow = false);
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: 'ph.edu.jrmsu.jtrips',
              maxNativeZoom: 19,
            ),

            // The geofence the arrival time was judged against. Drawn first
            // so the route line sits on top of it.
            if (fence != null)
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: fence.center,
                    radius: fence.radiusMeters.toDouble(),
                    useRadiusInMeter: true,
                    color: AdminColors.blue.withOpacity(0.10),
                    borderColor: AdminColors.blue.withOpacity(0.55),
                    borderStrokeWidth: 1.5,
                  ),
                ],
              ),

            if (route.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route,
                    strokeWidth: 4,
                    color: AdminColors.blue,
                    borderStrokeWidth: 1.5,
                    borderColor: Colors.white,
                  ),
                ],
              ),

            MarkerLayer(
              markers: [
                if (fence != null)
                  Marker(
                    point: fence.center,
                    width: 120,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: _FenceLabel(name: fence.name),
                  ),
                if (route.isNotEmpty)
                  Marker(
                    point: route.first,
                    width: 18,
                    height: 18,
                    child: const _StartDot(),
                  ),
                Marker(
                  point: here,
                  width: 46,
                  height: 46,
                  child: _VehicleMarker(stale: live.isStale),
                ),
              ],
            ),
          ],
        ),

        // CARTO's terms require the attribution to be visible.
        const Positioned(
          left: 0,
          bottom: 0,
          child: _Attribution(),
        ),

        Positioned(
          right: 12,
          top: 12,
          child: Column(
            children: [
              _MapButton(
                icon: _follow
                    ? Icons.my_location_rounded
                    : Icons.location_searching_rounded,
                tooltip: _follow ? 'Following the vehicle' : 'Follow the vehicle',
                active: _follow,
                onTap: () {
                  setState(() => _follow = true);
                  _recenter(here, zoom: 16);
                },
              ),
              const SizedBox(height: 8),
              _MapButton(
                icon: Icons.zoom_out_map_rounded,
                tooltip: 'Fit the whole route',
                onTap: () => _fitRoute(route),
              ),
            ],
          ),
        ),

        if (live.isStale)
          const Positioned(
            left: 12,
            top: 12,
            right: 72,
            child: _StaleBanner(),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final String vehicleName;
  final String plateNumber;
  final VehicleTrackView? view;
  final bool refreshing;

  const _Header({
    required this.vehicleName,
    required this.plateNumber,
    required this.view,
    required this.refreshing,
  });

  @override
  Widget build(BuildContext context) {
    final trip = view?.live?.trip;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.map_outlined,
                color: AdminColors.blue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AdminColors.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  trip == null
                      ? 'PLATE: $plateNumber'
                      : 'PLATE: $plateNumber  ·  ${trip.ticketNumber}'
                      '${trip.driverName == null ? '' : '  ·  ${trip.driverName}'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AdminColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          if (refreshing)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded,
                color: AdminColors.textMuted, size: 22),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Footer
// ---------------------------------------------------------------------------

class _Footer extends StatelessWidget {
  final VehicleTrackView view;
  const _Footer({required this.view});

  static final _time = DateFormat('h:mm a');

  static String _ago(DateTime? moment) {
    if (moment == null) return '—';
    final seconds = DateTime.now().difference(moment).inSeconds;
    if (seconds < 60) return '${seconds}s ago';
    if (seconds < 3600) return '${seconds ~/ 60}m ago';
    if (seconds < 86400) return '${seconds ~/ 3600}h ago';
    return '${seconds ~/ 86400}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final live = view.live;
    final summary = view.track?.summary;
    final trip = live?.trip;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF6F8FC),
        border: Border(top: BorderSide(color: AdminColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Wrap(
        spacing: 28,
        runSpacing: 10,
        children: [
          _Stat(
            label: 'SPEED',
            value: live?.speedKph == null
                ? '—'
                : '${live!.speedKph!.round()} km/h',
          ),
          _Stat(
            label: 'DISTANCE (GPS)',
            value: summary?.distanceKm == null
                ? '—'
                : '${summary!.distanceKm!.toStringAsFixed(1)} km',
          ),
          _Stat(label: 'FIXES', value: '${summary?.pointCount ?? 0}'),
          _Stat(
            label: 'ARRIVED',
            value: summary?.arrivedAtDestination == null
                ? 'Not yet'
                : _time.format(summary!.arrivedAtDestination!),
            highlight: summary?.arrivedAtDestination != null,
          ),
          _Stat(
            label: 'DEPARTED DEST.',
            value: summary?.departedFromDestination == null
                ? 'Not yet'
                : _time.format(summary!.departedFromDestination!),
            highlight: summary?.departedFromDestination != null,
          ),
          _Stat(label: 'LAST FIX', value: _ago(live?.lastSeenAt)),
          if (trip?.destination != null)
            _Stat(label: 'DESTINATION', value: trip!.destination!),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _Stat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AdminColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: highlight ? const Color(0xFF16A34A) : AdminColors.navy,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Map furniture
// ---------------------------------------------------------------------------

class _VehicleMarker extends StatelessWidget {
  final bool stale;
  const _VehicleMarker({required this.stale});

  @override
  Widget build(BuildContext context) {
    final color = stale ? const Color(0xFF94A3B8) : AdminColors.blue;

    return Tooltip(
      message: stale ? 'Last known position' : 'Live position',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.18),
            ),
          ),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.navigation_rounded,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

class _StartDot extends StatelessWidget {
  const _StartDot();

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Start of the trip',
    child: Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: AdminColors.navy, width: 3),
      ),
    ),
  );
}

class _FenceLabel extends StatelessWidget {
  final String name;
  const _FenceLabel({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.place, color: AdminColors.blue, size: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AdminColors.border),
          ),
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AdminColors.navy,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AdminColors.amber : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      shadowColor: Colors.black26,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(icon, size: 19, color: AdminColors.navy),
          ),
        ),
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 16, color: Color(0xFFB45309)),
          SizedBox(width: 8),
          Flexible(
            child: Text(
              'No signal for over 15 minutes — this is the last known '
                  'position, not where the vehicle is now.',
              style: TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white70,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: const Text(
        '© OpenStreetMap contributors © CARTO',
        style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _Empty({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: const Color(0xFFC3CBDC)),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                color: AdminColors.navy,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 420,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AdminColors.textMuted, fontSize: 12.5, height: 1.45),
              ),
            ),
            if (action != null) ...[const SizedBox(height: 10), action!],
          ],
        ),
      ),
    );
  }
}