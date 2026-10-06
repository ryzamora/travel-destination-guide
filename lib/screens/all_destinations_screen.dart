import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/destination.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../widgets/destination_card.dart';
import '../widgets/empty_state.dart';

/// Screen that lists every destination with search, category filter and sort.
///
/// Demonstrates: ListView.builder, TextField, FilterChip, PopupMenuButton,
/// setState(), and an empty state.
class AllDestinationsScreen extends StatefulWidget {
  const AllDestinationsScreen({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AppData data;
  final VoidCallback onChanged;

  @override
  State<AllDestinationsScreen> createState() => _AllDestinationsScreenState();
}

class _AllDestinationsScreenState extends State<AllDestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _category = 'All';
  String _sort = 'Rating';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _togglePlan(Destination destination) {
    setState(() {
      if (widget.data.isPlanned(destination)) {
        widget.data.removeFromPlan(destination.id);
      } else {
        widget.data.addToPlan(destination);
      }
    });
    widget.onChanged();
  }

  List<Destination> _sorted(List<Destination> items) {
    final List<Destination> copy = List<Destination>.from(items);
    switch (_sort) {
      case 'Name':
        copy.sort(
          (Destination a, Destination b) => a.name.compareTo(b.name),
        );
      case 'Budget':
        copy.sort(
          (Destination a, Destination b) =>
              a.estimatedBudget.compareTo(b.estimatedBudget),
        );
      case 'Days':
        copy.sort(
          (Destination a, Destination b) =>
              a.recommendedDays.compareTo(b.recommendedDays),
        );
      default:
        copy.sort(
          (Destination a, Destination b) => b.rating.compareTo(a.rating),
        );
    }
    return copy;
  }

  @override
  Widget build(BuildContext context) {
    final List<Destination> results = _sorted(
      widget.data.filter(_searchController.text, _category),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Destinations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            tooltip: 'Sort list',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (String value) => setState(() => _sort = value),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Rating',
                child: Text('Sort by rating'),
              ),
              const PopupMenuItem<String>(
                value: 'Name',
                child: Text('Sort by name'),
              ),
              const PopupMenuItem<String>(
                value: 'Budget',
                child: Text('Sort by daily budget'),
              ),
              const PopupMenuItem<String>(
                value: 'Days',
                child: Text('Sort by suggested days'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: TextField(
                controller: _searchController,
                onChanged: (String _) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search destinations...',
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
            ),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: widget.data.categories.length,
                itemBuilder: (BuildContext context, int index) {
                  final String name = widget.data.categories[index];
                  final bool selected = name == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8, top: 4),
                    child: ChoiceChip(
                      label: Text(name),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: AppTheme.primary,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${results.length} destination(s) - sorted by ${_sort.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        const SizedBox(height: 24),
                        const EmptyState(
                          icon: Icons.search_off,
                          title: 'Nothing found',
                          message:
                              'No destination matches your search and category.',
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: results.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final Destination item = results[index];
                        return DestinationCard(
                          destination: item,
                          isPlanned: widget.data.isPlanned(item),
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.details,
                            arguments: item,
                          ),
                          onTogglePlan: () => _togglePlan(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
