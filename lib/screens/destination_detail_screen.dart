import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/destination.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/rating_stars.dart';
import '../widgets/section_header.dart';

/// Details of one destination.
///
/// This page is opened with named routing and receives the [Destination]
/// object through `Navigator.pushNamed(context, route, arguments: ...)`.
///
/// Demonstrates: SliverAppBar, Image, ListView, Column, Row, Expanded,
/// Container, Card, buttons, and a confirmation dialog.
class DestinationDetailScreen extends StatefulWidget {
  const DestinationDetailScreen({
    super.key,
    required this.data,
    required this.destination,
    required this.onChanged,
  });

  final AppData data;
  final Destination destination;
  final VoidCallback onChanged;

  @override
  State<DestinationDetailScreen> createState() =>
      _DestinationDetailScreenState();
}

class _DestinationDetailScreenState
    extends State<DestinationDetailScreen> {
  bool _planned = false;

  @override
  void initState() {
    super.initState();
    _planned = widget.data.isPlanned(widget.destination);
  }

  void _togglePlan() {
    setState(() {
      if (widget.data.isPlanned(widget.destination)) {
        widget.data.removeFromPlan(widget.destination.id);
        _planned = false;
        _showSnack('Removed from your trip plan.');
      } else {
        widget.data.addToPlan(widget.destination);
        _planned = true;
        _showSnack('Added to your trip plan.');
      }
    });
    widget.onChanged();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete destination?'),
          content: Text(
            'This will remove "${widget.destination.name}" from the guide and '
            'from your trip plan.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    widget.data.deleteDestination(widget.destination.id);
    widget.onChanged();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Destination d = widget.destination;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 240,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            actions: <Widget>[
              if (d.isCustom)
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(
                left: 56,
                right: 56,
                bottom: 14,
              ),
              title: Text(
                d.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset(
                    d.imageAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(
                      color: AppTheme.primary.withValues(alpha: 0.2),
                      child: const Icon(Icons.landscape, size: 48),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          const Color(0x33000000),
                          const Color(0xCC00343C),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      RatingStars(
                        rating: d.rating,
                        size: 17,
                        showValue: false,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '${formatRating(d.rating)} / 5.0',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            d.category,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.place_outlined,
                        size: 15,
                        color: Color(0xFF5B6B72),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${d.location} - ${d.region}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _InfoGrid(destination: d),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    icon: Icons.info_outline,
                    title: 'About this place',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    d.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    icon: Icons.local_activity_outlined,
                    title: 'Must try',
                    caption: 'Popular activities and places',
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      for (final String item in d.highlights)
                        Chip(
                          avatar: const Icon(
                            Icons.check_circle_outline,
                            size: 15,
                            color: AppTheme.primary,
                          ),
                          label: Text(item),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const SectionHeader(
                    icon: Icons.luggage_outlined,
                    title: 'Travel tips',
                    caption: 'Advice from the guide',
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: d.travelTips.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppTheme.secondary
                                    .withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFB0701C),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                d.travelTips[index],
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.savings_outlined,
                          color: Color(0xFFB0701C),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Estimated trip cost',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatPeso(d.totalCost)} '
                                '(${d.recommendedDays} days x '
                                '${formatPeso(d.estimatedBudget)}/day)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.allDestinations,
                  ),
                  icon: const Icon(Icons.explore_outlined, size: 19),
                  label: const Text('Explore'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _planned
                    ? OutlinedButton.icon(
                        onPressed: _togglePlan,
                        icon: const Icon(Icons.check_circle, size: 19),
                        label: const Text('In my plan'),
                      )
                    : ElevatedButton.icon(
                        onPressed: _togglePlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                        ),
                        icon: const Icon(Icons.add, size: 19),
                        label: const Text('Add to plan'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two-column grid of quick facts about the destination.
class _InfoGrid extends StatelessWidget {
  const _InfoGrid({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final List<List<String>> cells = <List<String>>[
      <String>['${destination.recommendedDays} day(s)', 'Suggested stay'],
      <String>[formatPeso(destination.estimatedBudget), 'Daily budget'],
      <String>[destination.bestSeason, 'Best season'],
      <String>['${destination.highlights.length}', 'Activities'],
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cells.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8EB)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                cells[index][0],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2B31),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                cells[index][1],
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF5B6B72)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }
}
