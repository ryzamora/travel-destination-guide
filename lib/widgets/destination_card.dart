import 'package:flutter/material.dart';

import '../models/destination.dart';
import '../utils/app_theme.dart';
import 'rating_stars.dart';

/// Horizontal list card used on the Home screen and the search screen.
///
/// Demonstrates: Card, Image, Container, Row, Column, Text, Icon, buttons.
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
    this.isPlanned = false,
    this.onTogglePlan,
  });

  final Destination destination;
  final VoidCallback onTap;
  final bool isPlanned;
  final VoidCallback? onTogglePlan;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  destination.imageAsset,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 110,
                    height: 110,
                    color: AppTheme.primary.withValues(alpha: 0.12),
                    child: const Icon(Icons.landscape, size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      destination.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Color(0xFF5B6B72),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            destination.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    RatingStars(rating: destination.rating, size: 14),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _MiniTag(
                            icon: Icons.calendar_today_outlined,
                            label: '${destination.recommendedDays} day(s)',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _MiniTag(
                            icon: Icons.payments_outlined,
                            label:
                                'P${destination.estimatedBudget} / day',
                          ),
                        ),
                      ],
                    ),
                    if (onTogglePlan != null) ...<Widget>[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 34,
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onTogglePlan,
                          icon: Icon(
                            isPlanned
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            size: 17,
                          ),
                          label: Text(
                            isPlanned ? 'In my plan' : 'Add to plan',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical card used inside the [GridView] on the Home screen.
class DestinationGridCard extends StatelessWidget {
  const DestinationGridCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  final Destination destination;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Image.asset(
                destination.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: AppTheme.primary.withValues(alpha: 0.12),
                  child: const Icon(Icons.landscape, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    destination.name,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontSize: 14.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.location,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontSize: 11.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  RatingStars(rating: destination.rating, size: 13),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 13, color: const Color(0xFF5B6B72)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF3C4A50)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
