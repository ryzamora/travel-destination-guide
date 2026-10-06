import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../data/sample_data.dart';
import '../models/destination.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/destination_card.dart';
import '../widgets/empty_state.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

/// Home screen: the first page the user sees.
///
/// It shows the welcome banner, the search box, the category filters, quick
/// statistics, the current trip plan, and the list of destinations.
///
/// Demonstrates: Scaffold, AppBar, TextField, ListView, GridView, Card,
/// Container, Column, Row, Expanded, Stack, and setState().
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.data, required this.onChanged});

  final AppData data;
  final VoidCallback onChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(Destination destination) {
    Navigator.pushNamed(context, AppRoutes.details, arguments: destination);
  }

  void _togglePlan(Destination destination) {
    setState(() {
      if (widget.data.isPlanned(destination)) {
        widget.data.removeFromPlan(destination.id);
        _showSnack('${destination.name} removed from your plan.');
      } else {
        widget.data.addToPlan(destination);
        _showSnack('${destination.name} added to your plan.');
      }
    });
    widget.onChanged();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final AppData data = widget.data;
    final List<Destination> results = data.filter(
      _searchController.text,
      _category,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('Travel Guide', style: TextStyle(fontSize: 18)),
            Text(
              'Destination Guide',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'My trip plan',
            icon: const Icon(Icons.map_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.tripPlan),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final Object? saved = await Navigator.pushNamed(
            context,
            AppRoutes.addDestination,
          );
          if (saved == true) _showSnack('New destination saved.');
        },
        backgroundColor: AppTheme.secondary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add place'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _WelcomeBanner(
                plannedCount: data.itinerary.length,
                totalPlaces: data.destinations.length,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                onChanged: (String _) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search place, city, or region...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.categories.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String name = data.categories[index];
                    final bool selected = name == _category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(name),
                        selected: selected,
                        showCheckmark: false,
                        avatar: Icon(
                          _categoryIcon(name),
                          size: 16,
                          color: selected ? Colors.white : AppTheme.primary,
                        ),
                        selectedColor: AppTheme.primary,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: selected ? Colors.white : const Color(0xFF3C4A50),
                        ),
                        onSelected: (bool _) =>
                            setState(() => _category = name),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(
                      icon: Icons.place_outlined,
                      value: '${data.destinations.length}',
                      label: 'Destinations',
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.star_outline,
                      value: data.averageRating.toStringAsFixed(1),
                      label: 'Avg. rating',
                      color: AppTheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      icon: Icons.event_available_outlined,
                      value: '${data.plannedDays}',
                      label: 'Planned days',
                      color: const Color(0xFF7B5EA7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (data.itinerary.isNotEmpty) ...<Widget>[
                _PlanBanner(
                  count: data.itinerary.length,
                  days: data.plannedDays,
                  total: data.estimatedTotal,
                  onView: () =>
                      Navigator.pushNamed(context, AppRoutes.tripPlan),
                ),
                const SizedBox(height: 20),
              ],
              SectionHeader(
                icon: Icons.auto_awesome_outlined,
                title: 'Top Destinations',
                caption: 'Best rated places in the guide',
                actionLabel: 'See all',
                onAction: () =>
                    Navigator.pushNamed(context, AppRoutes.allDestinations),
              ),
              const SizedBox(height: 10),
              if (data.destinations.isEmpty)
                const EmptyState(
                  icon: Icons.travel_explore,
                  title: 'No destinations yet',
                  message:
                      'Tap "Add place" to create your first destination record.',
                )
              else if (results.isEmpty)
                const EmptyState(
                  icon: Icons.search_off,
                  title: 'No match found',
                  message:
                      'Try another keyword or choose a different category.',
                )
              else ...<Widget>[
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length > 4 ? 4 : results.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.8,
                      ),
                  itemBuilder: (BuildContext context, int index) {
                    final Destination item = results[index];
                    return DestinationGridCard(
                      destination: item,
                      onTap: () => _openDetails(item),
                    );
                  },
                ),
                const SizedBox(height: 22),
                SectionHeader(
                  icon: Icons.explore_outlined,
                  title: 'All Destinations',
                  caption:
                      '${results.length} of ${data.destinations.length} shown',
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: results.length,
                  separatorBuilder: (BuildContext context, int index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final Destination item = results[index];
                    return DestinationCard(
                      destination: item,
                      isPlanned: data.isPlanned(item),
                      onTap: () => _openDetails(item),
                      onTogglePlan: () => _togglePlan(item),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    for (final DestinationCategory c in DestinationCategory.all) {
      if (c.name == category) return c.icon;
    }
    return Icons.label_outline;
  }
}

/// Banner at the top of the Home screen.
///
/// Demonstrates: Stack, Container, Image, Row, Column, and Expanded.
class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({
    required this.plannedCount,
    required this.totalPlaces,
  });

  final int plannedCount;
  final int totalPlaces;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 184,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/boracay.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      const Color(0xCC00343C),
                      const Color(0x6600343C),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Hello, Traveler! Let's Explore the Philippines!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.25,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Find your next\nPhilippine adventure',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      height: 1.25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Flexible(
                    child: Text(
                      plannedCount == 0
                          ? 'Browse $totalPlaces curated destinations and build your own itinerary.'
                          : 'You have $plannedCount place(s) in your itinerary already.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small card that summarizes the current itinerary.
class _PlanBanner extends StatelessWidget {
  const _PlanBanner({
    required this.count,
    required this.days,
    required this.total,
    required this.onView,
  });

  final int count;
  final int days;
  final int total;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final String peso = formatPeso(total);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.luggage_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'My Trip Plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  '$count place(s) - $days day(s) - about $peso',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onView,
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}
