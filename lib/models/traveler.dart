/// Profile of the person using the app.
///
/// The profile is simulated: it is held in a local variable and cleared when
/// the app closes. No database is used.
class Traveler {
  const Traveler({
    required this.name,
    required this.homeCity,
    required this.travelStyle,
    required this.bio,
    required this.interests,
    this.tripsCompleted = 0,
  });

  final String name;
  final String homeCity;
  final String travelStyle;
  final String bio;
  final List<String> interests;
  final int tripsCompleted;

  /// First name only, used for greetings such as "Hi, Miguel".
  String get firstName {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Initials shown on the profile avatar, for example "MT".
  String get initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'TG';
    final parts = trimmed.split(RegExp(r'\s+'))
      ..removeWhere((p) => p.isEmpty);
    if (parts.isEmpty) return 'TG';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    if (parts.length >= 2) {
      return (parts.first.substring(0, 1) + parts[1].substring(0, 1))
          .toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Traveler copyWith({
    String? name,
    String? homeCity,
    String? travelStyle,
    String? bio,
    List<String>? interests,
    int? tripsCompleted,
  }) {
    return Traveler(
      name: name ?? this.name,
      homeCity: homeCity ?? this.homeCity,
      travelStyle: travelStyle ?? this.travelStyle,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
    );
  }
}
