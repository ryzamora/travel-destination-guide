import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../models/traveler.dart';

/// The category names used by the filter chips and the form dropdown.
class DestinationCategory {
  const DestinationCategory(this.name, this.icon);

  final String name;
  final IconData icon;

  static const List<DestinationCategory> all = <DestinationCategory>[
    DestinationCategory('All', Icons.grid_view_rounded),
    DestinationCategory('Beach & Island', Icons.beach_access_rounded),
    DestinationCategory('Nature & Wildlife', Icons.forest_rounded),
    DestinationCategory('Cultural & Heritage', Icons.account_balance_rounded),
    DestinationCategory('Mountain & Adventure', Icons.terrain_rounded),
    DestinationCategory('City & Shopping', Icons.location_city_rounded),
  ];
}

/// The seven sample destinations that ship with the app.
///
/// They are stored in a plain [List] of [Destination] objects, exactly as the
/// lesson requires: local variables only, no database.
List<Destination> buildSampleDestinations() {
  return <Destination>[
    const Destination(
      id: 'el-nido',
      name: 'El Nido',
      location: 'El Nido, Palawan',
      region: 'MIMAROPA',
      category: 'Beach & Island',
      description:
          'El Nido is a small town on the northern tip of Palawan known for '
          'its turquoise lagoons, towering limestone cliffs, and clear water '
          'that is perfect for island hopping. Tours A, B, and C cover Big '
          'Lagoon, Small Lagoon, Secret Beach, and the Matinloc shrine.',
      highlights: <String>['Big Lagoon', 'Small Lagoon', 'Kayaking', 'Snorkeling'],
      travelTips: <String>[
        'Book your island tour at least one week ahead during peak season.',
        'Bring reef-safe sunscreen, dry bags, and an extra shirt for the boats.',
        'Cash is still needed for entrance fees at the lagoons.',
        'The sea is rough from November to February, so check the weather first.',
      ],
      imageAsset: 'assets/images/el_nido.jpg',
      rating: 4.9,
      recommendedDays: 3,
      estimatedBudget: 4500,
      bestSeason: 'November to May',
    ),
    const Destination(
      id: 'banaue',
      name: 'Banaue Rice Terraces',
      location: 'Banaue, Ifugao',
      region: 'Cordillera Administrative Region',
      category: 'Cultural & Heritage',
      description:
          'The Banaue Rice Terraces are hand-carved stone terraces that have '
          'been shaped by the Ifugao people for over 2000 years. Batad, the '
          'best known viewpoint, is reached by a short hike and is often called '
          'the eighth wonder of the world.',
      highlights: <String>['Batad Viewpoint', 'Banggaan Village', 'Homestay', 'Handicrafts'],
      travelTips: <String>[
        'Hire a local guide in Bontoc for the Batad and Bangaan hike.',
        'Stay in a homestay so the tourism fee goes directly to the village.',
        'Wear shoes with good grip; the terraces are steep and slippery.',
        'Best photo light is early morning, before the clouds cover the ridges.',
      ],
      imageAsset: 'assets/images/banaue.jpg',
      rating: 4.8,
      recommendedDays: 2,
      estimatedBudget: 2500,
      bestSeason: 'November to March',
    ),
    const Destination(
      id: 'chocolate-hills',
      name: 'Chocolate Hills',
      location: 'Bohol',
      region: 'Central Visayas',
      category: 'Nature & Wildlife',
      description:
          'More than 1200 cone-shaped hills spread across the interior of Bohol. '
          'The area is also home to the Philippine tarsier, one of the smallest '
          'primates in the world, and the Loboc River for river activities.',
      highlights: <String>['Chocolate Hills', 'Tarsier Sanctuary', 'Loboc River', 'Hills View Deck'],
      travelTips: <String>[
        'The viewing deck gets crowded by mid-morning; go before 9 AM.',
        'No flash photography is allowed near the tarsiers.',
        'Rent a tricycle or join a shared van tour from Tagbilaran.',
        'The steps to the viewing deck can be wet, so watch your footing.',
      ],
      imageAsset: 'assets/images/chocolate_hills.jpg',
      rating: 4.6,
      recommendedDays: 2,
      estimatedBudget: 3000,
      bestSeason: 'December to May',
    ),
    const Destination(
      id: 'boracay',
      name: 'Boracay White Beach',
      location: 'Malay, Aklan',
      region: 'Western Visayas',
      category: 'Beach & Island',
      description:
          'Boracay is famous for its four kilometer stretch of fine white sand. '
          'After the rehabilitation project, the area is divided into numbered '
          'sectors, each with its own calm water zone, restaurants, and shops.',
      highlights: <String>['White Beach', 'Island Hopping', 'Sunset Sailing', 'Night Market'],
      travelTips: <String>[
        'Book an accredited accommodation so you get a clean water zone.',
        'Motorized water sports are only allowed in designated zones.',
        'The night market along White Beach is open from about 5 PM.',
        'From October to June, the sea is calmer and prices are lower.',
      ],
      imageAsset: 'assets/images/boracay.jpg',
      rating: 4.7,
      recommendedDays: 3,
      estimatedBudget: 4000,
      bestSeason: 'November to May',
    ),
    const Destination(
      id: 'mayon',
      name: 'Mayon Volcano and Albay',
      location: 'Albay',
      region: 'Bicol Region',
      category: 'Mountain & Adventure',
      description:
          'Mayon is one of the most active volcanoes in the Philippines and is '
          'famous for its perfect cone shape. Albay also offers the Cagsawa '
          'Ruins, the Mayon Volcano Observatory, and a short trek to the summit.',
      highlights: <String>['Mayon Viewpoint', 'Cagsawa Ruins', 'Sumuray Adventure', 'Local Bicol Food'],
      travelTips: <String>[
        'Check the PHIVOLCS bulletin before scheduling a climb.',
        'Summit hikes start before dawn, so confirm the time with your guide.',
        'Try the local dish "pinakbet" when you are in Albay town.',
        'Save one day for Daraga Church and the Albay Provincial Museum.',
      ],
      imageAsset: 'assets/images/mayon.jpg',
      rating: 4.7,
      recommendedDays: 3,
      estimatedBudget: 3500,
      bestSeason: 'November to March',
    ),
    const Destination(
      id: 'hundred-islands',
      name: 'Hundred Islands',
      location: 'Almeria, Pangasinan',
      region: 'Ilocos Region',
      category: 'Beach & Island',
      description:
          'Hundred Islands National Park is a protected marine area made of '
          'around 124 islands. You can island hop between small beaches, visit '
          'the Spanish era church on Asin Island, and see giant clams underwater.',
      highlights: <String>['Island Hopping', 'Snorkeling', 'Asin Island Church', 'Giant Clams'],
      travelTips: <String>[
        'Enter through Lucau Point and register at the visitor center.',
        'Life jackets are required; the boats can be crowded.',
        'Collect only shells you find loose; coral and live clams are protected.',
        'Combine the trip with Lingayen Beach on the way back.',
      ],
      imageAsset: 'assets/images/hundred_islands.jpg',
      rating: 4.5,
      recommendedDays: 2,
      estimatedBudget: 2800,
      bestSeason: 'November to May',
    ),
    const Destination(
      id: 'intramuros',
      name: 'Intramuros',
      location: 'Manila',
      region: 'National Capital Region',
      category: 'City & Shopping',
      description:
          'The walled city of Intramuros is the historic heart of Manila. It '
          'keeps Spanish era churches, the San Agustin Church, Fort Santiago, '
          'and the many kalesa rides that run along the cobblestone streets.',
      highlights: <String>['San Agustin Church', 'Fort Santiago', 'Kalesa Ride', 'Street Murals'],
      travelTips: <String>[
        'Start at the Casa Manila museum to understand the history first.',
        'The kalesa route ends near Fort Santiago and takes about 30 minutes.',
        'Late afternoon light is best for photographing the church facades.',
        'The area is close to the MRT, so it is a good last day of the trip.',
      ],
      imageAsset: 'assets/images/intramuros.jpg',
      rating: 4.4,
      recommendedDays: 1,
      estimatedBudget: 1500,
      bestSeason: 'December to May',
    ),
  ];
}

/// The default profile shown before the user edits it.
Traveler buildDefaultTraveler() {
  return const Traveler(
    name: 'Ryza and Justin',
    homeCity: 'Tarlac',
    travelStyle: 'College Student',
    bio: 'College student exploring new places and making memories.',
    interests: <String>['Travel', 'Food', 'Adventure'],
    tripsCompleted: 4,
  );
}

/// A simple [Map] that stores the about-page information.
///
/// This is included to show that the project also uses the Map data
/// structure, as required by the lesson.
Map<String, dynamic> buildAppInfo() {
  return <String, dynamic>{
    'appName': 'Travel Destination Guide',
    'version': '1.0.0',
    'subject': 'CSE101 / Elective 1 - Fundamentals of Mobile App Development',
    'school': 'Concepcion Holy Cross College, Inc.',
    'college': 'School of Computer Studies',
    'instructor': 'Mr. Patrick Jason L. Torres',
    'modules': 'Flutter Module 14 and Module 15',
    'dataSource': 'Hardcoded local sample data (no database)',
  };
}
