/// Data model for a single tourist destination.
///
/// All information here is hardcoded sample data stored in memory only.
/// The project intentionally does not use any database.
class Destination {
  const Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.region,
    required this.category,
    required this.description,
    required this.highlights,
    required this.travelTips,
    required this.imageAsset,
    required this.rating,
    required this.recommendedDays,
    required this.estimatedBudget,
    required this.bestSeason,
    this.isCustom = false,
  });

  /// Short unique key, also used by the itinerary so we never store the
  /// whole object twice in the same list.
  final String id;
  final String name;
  final String location;
  final String region;
  final String category;
  final String description;

  /// Key attractions, shown as a chip row.
  final List<String> highlights;

  /// Practical advice, shown as a bulleted list.
  final List<String> travelTips;

  /// Path of a local file inside `assets/images/`.
  final String imageAsset;

  /// Average visitor rating from 1.0 to 5.0.
  final double rating;

  /// Suggested number of days for a full visit.
  final int recommendedDays;

  /// Suggested daily budget in Philippine Pesos.
  final int estimatedBudget;

  /// Best months to visit.
  final String bestSeason;

  /// True when the record was created by the user through the form screen.
  final bool isCustom;

  /// Total estimated cost of the trip, used by the plan summary screen.
  int get totalCost => recommendedDays * estimatedBudget;

  /// One-line description used on the list cards.
  String get shortDescription {
    if (description.length <= 90) return description;
    return '${description.substring(0, 87)}...';
  }
}
