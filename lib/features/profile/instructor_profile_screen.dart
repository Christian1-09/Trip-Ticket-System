/// DEPRECATED SHIM — the profile screen now lives in profile_screen.dart
/// and is shared by every role.
///
/// This file only re-exports it so the existing
///   import '.../features/profile/instructor_profile_screen.dart';
/// lines keep compiling. Once you've switched those imports over to
/// `profile_screen.dart`, delete this file.
///
/// Everything that used to be in here (ProfileScreen, _ProfileHeader,
/// AccountMenu, _prepareAvatarImage) has moved:
///   ProfileScreen        -> profile_screen.dart
///   ProfileHeader        -> widgets/profile_header.dart
///   AccountMenu          -> widgets/account_menu.dart
library;

export 'profile_screen.dart';
export 'widgets/account_menu.dart';