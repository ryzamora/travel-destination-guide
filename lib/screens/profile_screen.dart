import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/traveler.dart';
import '../utils/app_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

/// Profile page with the simulated traveler information and the about box.
///
/// Demonstrates: Form inside a modal bottom sheet, validation, ListView,
/// Container, Image, Card, and setState().
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AppData data;
  final VoidCallback onChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openEditSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return _EditProfileSheet(
          traveler: widget.data.traveler,
          onSave: (Traveler updated) {
            setState(() => widget.data.updateTraveler(updated));
            widget.onChanged();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Traveler traveler = widget.data.traveler;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            _ProfileHeader(
              traveler: traveler,
              onEdit: _openEditSheet,
            ),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: StatCard(
                    icon: Icons.luggage_outlined,
                    value: '${traveler.tripsCompleted}',
                    label: 'Trips done',
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.map_outlined,
                    value: '${widget.data.destinations.length}',
                    label: 'In guide',
                    color: AppTheme.secondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    icon: Icons.event_available_outlined,
                    value: '${widget.data.plannedDays}',
                    label: 'Days planned',
                    color: const Color(0xFF7B5EA7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              icon: Icons.favorite_border,
              title: 'Travel interests',
              caption: 'Saved with your profile',
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (final String interest in traveler.interests)
                  Chip(
                    avatar: const Icon(
                      Icons.check,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    label: Text(interest),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionHeader(
              icon: Icons.info_outline,
              title: 'About this app',
              caption: 'Project information',
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final MapEntry<String, dynamic> entry
                        in widget.data.appInfo.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: 116,
                              child: Text(
                                _prettyKey(entry.key),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${entry.value}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext dialogContext) => AlertDialog(
                    title: const Text('Data source'),
                    content: const Text(
                      'Every record in this app is stored in local variables '
                      'using List and Map. No database, network, or cloud '
                      'service is used, as required by the project.',
                    ),
                    actions: <Widget>[
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.storage_outlined, size: 19),
              label: const Text('How the data is stored'),
            ),
          ],
        ),
      ),
    );
  }

  String _prettyKey(String key) => key
      .replaceAllMapped(
        RegExp('([A-Z])'),
        (Match m) => ' ${m.group(1)!.toLowerCase()}',
      )
      .trim();
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.traveler, required this.onEdit});

  final Traveler traveler;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8EB)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Image.asset(
                  'assets/images/avatar.png',
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    width: 66,
                    height: 66,
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    alignment: Alignment.center,
                    child: Text(
                      traveler.initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.badge_outlined,
                          size: 16,
                          color: Color(0xFF5B6B72),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            traveler.name.isNotEmpty
                                ? traveler.name
                                : 'No name yet',
                            style: Theme.of(context).textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.home_outlined,
                          size: 14,
                          color: Color(0xFF5B6B72),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            traveler.homeCity.isNotEmpty
                                ? 'From ${traveler.homeCity}'
                                : 'From -',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.airplanemode_active_outlined,
                            size: 12,
                            color: Color(0xFFB0701C),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            traveler.travelStyle.isNotEmpty
                                ? traveler.travelStyle
                                : 'Travel style',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB0701C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit profile',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Icon(
                    Icons.chat_bubble_outline,
                    size: 18,
                    color: Color(0xFF5B6B72),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      traveler.bio.isNotEmpty
                          ? traveler.bio
                          : 'Tell us a little about yourself...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: traveler.bio.isNotEmpty
                                ? null
                                : Colors.grey.shade600,
                            fontStyle: traveler.bio.isNotEmpty
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet with the edit form for the profile.
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({required this.traveler, required this.onSave});

  final Traveler traveler;
  final ValueChanged<Traveler> onSave;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  late final TextEditingController _styleController;
  late final TextEditingController _bioController;
  late final TextEditingController _interestsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.traveler.name);
    _cityController = TextEditingController(text: widget.traveler.homeCity);
    _styleController = TextEditingController(text: widget.traveler.travelStyle);
    _bioController = TextEditingController(text: widget.traveler.bio);
    _interestsController = TextEditingController(
      text: widget.traveler.interests.join(', '),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _styleController.dispose();
    _bioController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final List<String> interests = _interestsController.text
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();

    widget.onSave(
      widget.traveler.copyWith(
        name: _nameController.text.trim(),
        homeCity: _cityController.text.trim(),
        travelStyle: _styleController.text.trim(),
        bio: _bioController.text.trim(),
        interests: interests,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.person_outline, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Edit Profile',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: (String? value) {
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
                    return 'Use at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Home city',
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (String? value) {
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 2) {
                    return 'Use at least 2 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _styleController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Travel style',
                  prefixIcon: Icon(Icons.style_outlined),
                ),
                validator: (String? value) {
                  if (value != null && value.trim().isNotEmpty && value.trim().length < 3) {
                    return 'Use at least 3 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 220,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Short bio',
                  alignLabelWithHint: true,
                ),
              ),
              TextFormField(
                controller: _interestsController,
                decoration: const InputDecoration(
                  labelText: 'Interests (comma separated)',
                  prefixIcon: Icon(Icons.favorite_border),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _save,
                      child: const Text('Save changes'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
