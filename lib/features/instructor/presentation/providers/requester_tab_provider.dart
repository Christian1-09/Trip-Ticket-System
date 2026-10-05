// features/instructor/presentation/providers/requester_tab_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which tab of the requester's BottonNavBar is showing.
///
/// This used to be `_selectedIndex` inside `_BottonNavBarState`, which meant
/// only the nav bar itself could change tabs — any other screen wanting to
/// send the user to "Book Trip" had no choice but to `Navigator.push` the
/// flow, stacking a second copy of it *on top of* the nav bar (wrong screen,
/// wrong highlighted tab, no way back through the bar).
///
/// Lifting it into a provider lets any widget say "go to the Book tab" the
/// same way the bar itself does.
final requesterTabProvider = StateProvider<int>((ref) => RequesterTabs.home);

/// Named indexes so no one has to remember what `2` means.
/// These MUST stay in step with the `appScreens` list and the
/// `BottomNavigationBarItem` list in instructor_botton_bar.dart.
class RequesterTabs {
  static const int home = 0;
  static const int vehicles = 1;
  static const int book = 2;
  static const int schedule = 3;
  static const int profile = 4;

  const RequesterTabs._();
}