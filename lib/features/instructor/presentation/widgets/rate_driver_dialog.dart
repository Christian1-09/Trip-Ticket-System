// features/instructor/presentation/widgets/rate_driver_dialog.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/core/theme/config/api_config.dart';

/// Star rating plus an optional written message, shown once the trip is
/// completed. Returns (score, comment) or null when cancelled.
///
/// The return shape is unchanged, so every existing caller keeps working:
///
///   final result = await showDialog<({int score, String comment})>(...);
class RateDriverDialog extends StatefulWidget {
  final String driverName;
  final String ticketNumber;

  /// The driver's photo. Optional — falls back to their initials in a
  /// gold ring, which is what most drivers will actually have.
  final String? avatarUrl;

  const RateDriverDialog({
    super.key,
    required this.driverName,
    required this.ticketNumber,
    this.avatarUrl,
  });

  @override
  State<RateDriverDialog> createState() => _RateDriverDialogState();
}

class _RateDriverDialogState extends State<RateDriverDialog> {
  int _score = 0;
  final _controller = TextEditingController();
  String? _error;

  static const _maxLength = 300;

  static const _labels = {
    1: 'Poor',
    2: 'Fair',
    3: 'Good',
    4: 'Very good',
    5: 'Excellent',
  };

  @override
  void initState() {
    super.initState();
    // Drives the live 0/300 counter inside the message box.
    _controller.addListener(_onTyping);
  }

  void _onTyping() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTyping);
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_score == 0) {
      setState(() => _error = 'Please choose a star rating.');
      return;
    }
    Navigator.pop(context, (score: _score, comment: _controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2A54D4),
                AppColors.cardDeepBlue,
                Color(0xFF0A1358),
              ],
              stops: [0.0, 0.55, 1.0],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66000000),
                blurRadius: 30,
                offset: Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // The yellow corner sweeps. Behind everything, and clipped
              // by the card's rounded corners.
              const Positioned.fill(
                child: CustomPaint(painter: _SwooshPainter()),
              ),

              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(),
                      const SizedBox(height: 20),
                      _stars(),
                      const SizedBox(height: 12),
                      _divider(),
                      const SizedBox(height: 10),
                      _prompt(),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: Color(0xFFFFB4AB),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _messageBox(),
                      const SizedBox(height: 14),
                      _footnote(),
                      const SizedBox(height: 18),
                      _buttons(),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 10,
                right: 10,
                child: _CloseButton(onTap: () => Navigator.pop(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------

  Widget _header() {
    return Padding(
      // Room for the close button at the top right.
      padding: const EdgeInsets.only(right: 34),
      child: Row(
        children: [
          _Avatar(name: widget.driverName, avatarUrl: widget.avatarUrl),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Rate your driver',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.driverName} · ${widget.ticketNumber}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFBFD0FF),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final value = index + 1;
        final filled = value <= _score;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: GestureDetector(
            onTap: () => setState(() {
              _score = value;
              _error = null;
            }),
            // A tap target bigger than the star itself — these get
            // pressed with a thumb, often in a moving vehicle.
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: AnimatedScale(
                scale: filled ? 1.0 : 0.88,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutBack,
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_rounded,
                  size: 42,
                  color: filled
                      ? AppColors.accentYellow
                      : Colors.white.withOpacity(0.22),
                  shadows: filled
                      ? const [
                    Shadow(
                      color: Color(0x66FFC727),
                      blurRadius: 12,
                    ),
                  ]
                      : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _divider() {
    return Container(
      height: 1,
      color: Colors.white.withOpacity(0.18),
    );
  }

  Widget _prompt() {
    final rated = _score > 0;
    return Center(
      child: Text(
        rated ? _labels[_score]! : 'Tap a star to rate',
        style: TextStyle(
          color: rated ? AppColors.accentYellow : Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _messageBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5FF),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.edit_outlined,
                    size: 19, color: Color(0xFF6B8FE0)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 3,
                  minLines: 2,
                  maxLength: _maxLength,
                  style: const TextStyle(
                    color: AppColors.homeTextDark,
                    fontSize: 13.5,
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Leave a message for the driver\n(optional)',
                    hintStyle: TextStyle(
                      color: Color(0xFF8FA3CC),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                    // The built-in counter sits outside the box and in the
                    // wrong colour; ours is drawn below instead.
                    counterText: '',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          Text(
            '${_controller.text.characters.length}/$_maxLength',
            style: const TextStyle(
              color: Color(0xFF9AAAC9),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footnote() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // An emoji rather than a Material icon: it matches the mockup and
        // renders identically everywhere without depending on which icon
        // set shipped with the Flutter version.
        const Text('🤝', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Your rating helps us improve our service. Thank you! 😊',
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buttons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.75), width: 1.5),
                shape: const StadiumBorder(),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.star_rounded, size: 20),
              label: const Text(
                'Submit',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentYellow,
                foregroundColor: const Color(0xFF0A1358),
                elevation: 0,
                shape: const StadiumBorder(),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pieces
// ---------------------------------------------------------------------------

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _Avatar({required this.name, this.avatarUrl});

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final url = ApiConfig.mediaUrl(avatarUrl);

    return Container(
      width: 66,
      height: 66,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // The gold ring from the mockup.
        border: Border.all(color: AppColors.accentYellow, width: 3),
        color: AppColors.cardDark,
      ),
      padding: const EdgeInsets.all(2),
      child: ClipOval(
        child: url == null
            ? _initialsBlock()
            : Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _initialsBlock(),
        ),
      ),
    );
  }

  Widget _initialsBlock() {
    return ColoredBox(
      color: AppColors.quickActions,
      child: Center(
        child: Text(
          _initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.14),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 34,
          height: 34,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 19),
        ),
      ),
    );
  }
}

/// The yellow corner sweeps from the mockup.
///
/// Kept to the corners on purpose: a yellow band running under the Cancel
/// button would put white text on yellow, which nobody can read.
class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final yellow = Paint()..color = AppColors.accentYellow;

    // Top left
    final topLeft = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.30, 0)
      ..quadraticBezierTo(w * 0.09, h * 0.05, 0, h * 0.17)
      ..close();
    canvas.drawPath(topLeft, yellow);

    // Top right — a thin sliver, so the close button still reads.
    final topRight = Path()
      ..moveTo(w, 0)
      ..lineTo(w, h * 0.10)
      ..quadraticBezierTo(w * 0.94, h * 0.03, w * 0.82, 0)
      ..close();
    canvas.drawPath(topRight, yellow..color = AppColors.accentYellow.withOpacity(0.9));

    // Bottom left
    final bottomLeft = Path()
      ..moveTo(0, h * 0.88)
      ..quadraticBezierTo(w * 0.10, h * 0.96, w * 0.24, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(bottomLeft, Paint()..color = AppColors.accentYellow);

    // Bottom right
    final bottomRight = Path()
      ..moveTo(w, h * 0.80)
      ..quadraticBezierTo(w * 0.86, h * 0.94, w * 0.66, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(bottomRight, Paint()..color = AppColors.accentYellow);

    // The pale accent line that follows the bottom-right curve.
    final accent = Path()
      ..moveTo(w, h * 0.70)
      ..quadraticBezierTo(w * 0.80, h * 0.90, w * 0.56, h);
    canvas.drawPath(
      accent,
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}