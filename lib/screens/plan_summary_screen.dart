import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/destination.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/rating_stars.dart';

/// Summary of the itinerary the user built.
///
/// Demonstrates: ReorderableListView, ListView, Column, Row, Expanded, Card,
/// showDialog, SnackBar, and setState().
class PlanSummaryScreen extends StatefulWidget {
  const PlanSummaryScreen({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AppData data;
  final VoidCallback onChanged;

  @override
  State<PlanSummaryScreen> createState() => _PlanSummaryScreenState();
}

class _PlanSummaryScreenState extends State<PlanSummaryScreen> {
  void _remove(Destination destination) {
    setState(() => widget.data.removeFromPlan(destination.id));
    widget.onChanged();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${destination.name} removed from the plan.')),
      );
  }

  Future<void> _clearAll() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Clear the whole plan?'),
        content: const Text(
          'Every destination will be removed from your itinerary. '
          'The destinations in the guide will stay.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep it'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => widget.data.clearPlan());
    widget.onChanged();
  }

  Future<void> _completeTrip() async {
    final int days = widget.data.plannedDays;
    final int total = widget.data.estimatedTotal;
    final int count = widget.data.itinerary.length;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Finish this trip?'),
        content: Text(
          'You planned $count destination(s) for $days day(s) with an '
          'estimated budget of ${formatPeso(total)}.\n\n'
          'The itinerary will be cleared and added to your profile.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.check, size: 18),
                SizedBox(width: 8),
                Text('Finish trip'),
              ],
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      widget.data.markTripCompleted();
      widget.data.clearPlan();
    });
    widget.onChanged();

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Trip saved to your profile. Nice work!')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final List<Destination> plan = widget.data.itinerary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trip Plan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          if (plan.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: SafeArea(
        child: plan.isEmpty
            ? ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  const SizedBox(height: 30),
                  EmptyState(
                    icon: Icons.luggage_outlined,
                    title: 'Your plan is empty',
                    message:
                        'Open any destination and tap "Add to plan" to start '
                        'building your itinerary.',
                    actionLabel: 'Browse destinations',
                    onAction: () =>
                        Navigator.pushNamed(context, AppRoutes.allDestinations),
                  ),
                ],
              )
            : Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _PlanTotals(
                      count: plan.length,
                      days: widget.data.plannedDays,
                      total: widget.data.estimatedTotal,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.drag_handle,
                          size: 18,
                          color: Color(0xFF5B6B72),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Press and hold a card to change the visiting order.',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: plan.length,
                      onReorderItem: (int oldIndex, int newIndex) {
                        setState(() {
                          final Destination moved = plan.removeAt(oldIndex);
                          plan.insert(newIndex, moved);
                        });
                        widget.onChanged();
                      },
                      itemBuilder: (BuildContext context, int index) {
                        final Destination item = plan[index];
                        return Padding(
                          key: ValueKey<String>(item.id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _PlanTile(
                            index: index,
                            destination: item,
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.details,
                              arguments: item,
                            ),
                            onRemove: () => _remove(item),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: plan.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton.icon(
                  onPressed: _completeTrip,
                  icon: const Icon(Icons.flag_outlined, size: 19),
                  label: const Text('Finish this trip'),
                ),
              ),
            ),
    );
  }
}

class _PlanTotals extends StatelessWidget {
  const _PlanTotals({
    required this.count,
    required this.days,
    required this.total,
  });

  final int count;
  final int days;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[AppTheme.primary, Color(0xFF12A0A8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: <Widget>[
          _TotalItem(value: '$count', label: 'Destinations'),
          Container(
            width: 1,
            height: 34,
            color: Colors.white24,
          ),
          _TotalItem(value: '$days', label: 'Days'),
          Container(width: 1, height: 34, color: Colors.white24),
          _TotalItem(value: formatPeso(total), label: 'Est. cost'),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  const _TotalItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.index,
    required this.destination,
    required this.onTap,
    required this.onRemove,
  });

  final int index;
  final Destination destination;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Container(
                    width: 26,
                    height: 26,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.drag_handle, size: 18, color: Color(0xFF9AA7AD)),
                ],
              ),
              const SizedBox(width: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  destination.imageAsset,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 56,
                    height: 56,
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    child: const Icon(Icons.landscape, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      destination.name,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      destination.location,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: <Widget>[
                        RatingStars(
                          rating: destination.rating,
                          size: 12,
                          showValue: false,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${destination.recommendedDays} days - '
                            '${formatPeso(destination.totalCost)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF3C4A50),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Remove',
                icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
