/// Route name constants.
///
/// Keeping them in one file means the screen files do not need to import the
/// main screen files, which avoids circular imports.
class AppRoutes {
  const AppRoutes._();

  static const String home = '/';
  static const String allDestinations = '/all-destinations';
  static const String details = '/destination-detail';
  static const String addDestination = '/add-destination';
  static const String tripPlan = '/trip-plan';
  static const String profile = '/profile';
  static const String settings = '/settings';
}
