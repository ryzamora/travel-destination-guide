import '../models/destination.dart';
import '../models/traveler.dart';
import 'sample_data.dart';

/// Holds all of the data used by the app while it is running.
///
/// Everything is stored in plain local variables: two [List] objects, one
/// [Traveler] object, and one [Map] of app information. No database, no
/// network request, and no shared preferences are used, which is exactly
/// what the final project instructions require.
///
/// The screens call the methods below and then run `setState()` so the
/// interface updates immediately.
class AppData {
  AppData()
    : destinations = buildSampleDestinations(),
      appInfo = buildAppInfo();

  /// Every destination the app knows about (sample data + user entries).
  final List<Destination> destinations;

  /// The destinations the user added to the itinerary, in order.
  final List<Destination> itinerary = <Destination>[];

  /// App information shown on the profile screen.
  final Map<String, dynamic> appInfo;

  Traveler traveler = buildDefaultTraveler();

  /// Ids of the destinations the user marked as favorite.
  final List<String> favorites = <String>[];

  /// Whether the app uses the dark color scheme.
  bool isDarkMode = false;

  /// How the daily budget is divided. Stored in a [Map] on purpose so the
  /// plan summary screen can show a breakdown without hardcoding values.
  static const Map<String, double> budgetShare = <String, double>{
    'Accommodation': 0.35,
    'Food': 0.30,
    'Transport': 0.20,
    'Activities': 0.15,
  };

  /// Splits the estimated total into four categories.
  Map<String, int> get budgetBreakdown {
    final Map<String, int> result = <String, int>{
      for (final String key in budgetShare.keys) key: 0,
    };
    for (final Destination d in itinerary) {
      budgetShare.forEach((String key, double share) {
        result[key] = result[key]! + (d.totalCost * share).round();
      });
    }
    return result;
  }

  bool isFavorite(String id) => favorites.contains(id);

  /// Adds or removes a favorite. Returns true when it is now a favorite.
  bool toggleFavorite(String id) {
    if (favorites.contains(id)) {
      favorites.remove(id);
      return false;
    }
    favorites.add(id);
    return true;
  }

  /// Favorite destinations, in the same order as the main list.
  List<Destination> get favoriteDestinations => destinations
      .where((Destination d) => favorites.contains(d.id))
      .toList();

  void toggleDarkMode() => isDarkMode = !isDarkMode;

  /// Total number of days in the current itinerary.
  int get plannedDays => itinerary.fold<int>(
    0,
    (int sum, Destination d) => sum + d.recommendedDays,
  );

  /// Estimated total cost of the current itinerary in pesos.
  int get estimatedTotal => itinerary.fold<int>(
    0,
    (int sum, Destination d) => sum + d.totalCost,
  );

  /// Average rating of every destination in the app.
  double get averageRating {
    if (destinations.isEmpty) return 0;
    final double sum = destinations.fold<double>(
      0,
      (double acc, Destination d) => acc + d.rating,
    );
    return sum / destinations.length;
  }

  /// Category names taken from the sample list, used by the filter chips.
  List<String> get categories => DestinationCategory.all
      .map((DestinationCategory c) => c.name)
      .toList();

  /// Filters the destination list using a search text and a category.
  List<Destination> filter(
    String query,
    String category, {
    bool favoritesOnly = false,
  }) {
    final String q = query.trim().toLowerCase();
    return destinations.where((Destination d) {
      final bool matchesCategory =
          category == 'All' || d.category == category;
      if (!matchesCategory) return false;
      if (favoritesOnly && !favorites.contains(d.id)) return false;
      if (q.isEmpty) return true;
      return d.name.toLowerCase().contains(q) ||
          d.location.toLowerCase().contains(q) ||
          d.region.toLowerCase().contains(q) ||
          d.category.toLowerCase().contains(q);
    }).toList();
  }

  bool isPlanned(Destination destination) =>
      itinerary.any((Destination d) => d.id == destination.id);

  /// Adds a destination to the itinerary. Returns false if it is already there.
  bool addToPlan(Destination destination) {
    if (isPlanned(destination)) return false;
    itinerary.add(destination);
    return true;
  }

  void removeFromPlan(String id) {
    itinerary.removeWhere((Destination d) => d.id == id);
  }

  void clearPlan() => itinerary.clear();

  /// Saves a destination created through the form screen.
  void addDestination(Destination destination) {
    destinations.insert(0, destination);
  }

  /// Removes a user-created destination from the app and from the itinerary.
  void deleteDestination(String id) {
    destinations.removeWhere((Destination d) => d.id == id);
    removeFromPlan(id);
  }

  void updateTraveler(Traveler value) => traveler = value;

  void markTripCompleted() {
    traveler = traveler.copyWith(tripsCompleted: traveler.tripsCompleted + 1);
  }
}
