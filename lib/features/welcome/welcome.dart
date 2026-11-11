// features/welcome/welcome.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jtrips_app/core/theme/app_colors.dart';
import 'package:jtrips_app/features/welcome/widgets/onboarding_parts.dart';

/// The three onboarding slides.
/// 👉 Replace the `image` paths with your three background images.
const _slides = <OnboardingSlide>[
  OnboardingSlide(
    image: 'assets/welcome/onboarding_1.png',
    titleTop: 'Plan Ahead,',
    titleBottom: 'Travel on Time',
    body: 'Browse available trips\nand check schedules.',
  ),
  OnboardingSlide(
    image: 'assets/welcome/onboarding_2.png',
    titleTop: 'Choose Your',
    titleBottom: 'Preferred Vehicle',
    body: 'Compare available vehicles\nand select your ride.',
    overlay: OnboardingOverlay.selectVehicle,
  ),
  OnboardingSlide(
    image: 'assets/welcome/onboarding_3.png',
    titleTop: 'Book Your Trip',
    titleBottom: 'with Ease',
    body: 'Reserve your seat, access\nyour ticket, and track your journey.',
    overlay: OnboardingOverlay.bookingConfirmed,
  ),
];

class Welcome extends StatefulWidget {
  /// Called when "Get Started" is tapped on the last slide
  /// (e.g. go to the login screen).
  final VoidCallback? onFinish;

  const Welcome({super.key, this.onFinish});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final PageController _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int page) => _controller.animateToPage(
    page,
    duration: const Duration(milliseconds: 450),
    curve: Curves.easeOutCubic,
  );

  void _next() {
    if (_isLast) {
      widget.onFinish?.call();
      return;
    }
    _goTo(_index + 1);
  }

  /// Lets the user swipe on the white panel too, not only on the picture.
  void _onPanelSwipe(DragEndDetails d) {
    final v = d.primaryVelocity ?? 0;
    if (v < -200 && !_isLast) _goTo(_index + 1);
    if (v > 200 && _index > 0) _goTo(_index - 1);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.homeNavyDark,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: LayoutBuilder(
          builder: (context, c) {
            final h = c.maxHeight;
            final topInset = MediaQuery.paddingOf(context).top;
            final panelTop = h * 0.50;

            return Stack(
              children: [
                // 1 ── Sliding hero pictures (+ Flutter-built cards).
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: panelTop + 90,
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemBuilder: (_, i) => OnboardingHero(
                      slide: _slides[i],
                      topInset: topInset + 92,
                      bottomInset: 100,
                    ),
                  ),
                ),

                // 2 ── Fixed logo header with a soft shade for readability.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Container(
                      padding: EdgeInsets.only(top: topInset + 14, bottom: 40),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.homeNavyDark.withOpacity(0.55),
                            AppColors.homeNavyDark.withOpacity(0.0),
                          ],
                        ),
                      ),
                      child: const Center(child: BrandHeader()),
                    ),
                  ),
                ),

                // 3 ── White curved panel: title, text, dots, button.
                Positioned(
                  top: panelTop,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onHorizontalDragEnd: _onPanelSwipe,
                    child: OnboardingPanel(
                      slide: _slides[_index],
                      index: _index,
                      count: _slides.length,
                      buttonLabel: _isLast ? 'Get Started' : 'Next',
                      onNext: _next,
                      onDotTap: _goTo,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}