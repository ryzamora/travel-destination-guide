import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/app_data.dart';
import '../data/sample_data.dart';
import '../models/destination.dart';
import '../utils/app_theme.dart';

/// Form screen where the user can add a new destination to the guide.
///
/// Demonstrates: Form, TextFormField, TextEditingController, DropdownButton,
/// validation messages, and returning a result with `Navigator.pop`.
///
/// All data stays in memory: it is only saved while the app is running.
class AddDestinationScreen extends StatefulWidget {
  const AddDestinationScreen({
    super.key,
    required this.data,
    required this.onChanged,
  });

  final AppData data;
  final VoidCallback onChanged;

  @override
  State<AddDestinationScreen> createState() => _AddDestinationScreenState();
}

class _AddDestinationScreenState extends State<AddDestinationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _highlightsController = TextEditingController();

  String? _category;
  String? _season;
  bool _saving = false;

  static const List<String> _seasonOptions = <String>[
    'January to March',
    'April to June',
    'July to September',
    'October to December',
    'All year round',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _regionController.dispose();
    _daysController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    _highlightsController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter the $fieldName.';
    }
    return null;
  }

  String? _validateName(String? value) {
    final String? error = _requiredText(value, 'place name');
    if (error != null) return error;
    if (value!.trim().length < 3) {
      return 'The name must be at least 3 characters.';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName, int maximum) {
    final String? error = _requiredText(value, fieldName);
    if (error != null) return error;
    final int? parsed = int.tryParse(value!.trim());
    if (parsed == null) {
      return 'Use numbers only for the $fieldName.';
    }
    if (parsed < 1 || parsed > maximum) {
      return 'The $fieldName must be between 1 and $maximum.';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    final String? error = _requiredText(value, 'daily budget');
    if (error != null) return error;
    final int? parsed = int.tryParse(value!.trim());
    if (parsed == null) return 'Use numbers only, for example 2500.';
    if (parsed < 100) return 'Enter a budget of at least 100 pesos.';
    if (parsed > 200000) return 'That budget is too high for this app.';
    return null;
  }

  String? _validateDescription(String? value) {
    final String? error = _requiredText(value, 'description');
    if (error != null) return error;
    if (value!.trim().length < 20) {
      return 'Please write at least 20 characters.';
    }
    return null;
  }

  String? _validateHighlights(String? value) {
    final String? error = _requiredText(value, 'highlights');
    if (error != null) return error;
    if (!value!.contains(',')) {
      return 'Separate each highlight with a comma.';
    }
    return null;
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Please fix the highlighted fields first.'),
          ),
        );
      return;
    }

    setState(() => _saving = true);

    final List<String> highlights = _highlightsController.text
        .split(',')
        .map((String e) => e.trim())
        .where((String e) => e.isNotEmpty)
        .toList();

    final List<String> tips = <String>[
      'Book or confirm your transportation at least three days before the trip.',
      'Bring cash because some entrance fees have no digital payment yet.',
      'Save an offline copy of the location in case there is no signal.',
    ];

    final Destination created = Destination(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      region: _regionController.text.trim(),
      category: _category ?? 'Cultural & Heritage',
      description: _descriptionController.text.trim(),
      highlights: highlights,
      travelTips: tips,
      imageAsset: 'assets/images/logo.png',
      rating: 4.5,
      recommendedDays: int.parse(_daysController.text.trim()),
      estimatedBudget: int.parse(_budgetController.text.trim()),
      bestSeason: _season ?? 'All year round',
      isCustom: true,
    );

    widget.data.addDestination(created);
    widget.onChanged();

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Destination'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: <Widget>[
                    Icon(Icons.info_outline, size: 19, color: AppTheme.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All fields are required. The record is saved only while '
                        'the app is open.',
                        style: TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _Label(text: 'Place name *'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter destination name',
                  prefixIcon: Icon(Icons.place_outlined),
                ),
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _Label(text: 'City / Town *'),
              TextFormField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter city, town, or area',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                validator: (String? value) =>
                    _requiredText(value, 'city or town'),
              ),
              const SizedBox(height: 16),
              _Label(text: 'Region *'),
              TextFormField(
                controller: _regionController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter region',
                  prefixIcon: Icon(Icons.public_outlined),
                ),
                validator: (String? value) => _requiredText(value, 'region'),
              ),
              const SizedBox(height: 16),
              _Label(text: 'Category *'),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                hint: const Text('Choose a category'),
                items: <DropdownMenuItem<String>>[
                  for (final DestinationCategory c in DestinationCategory.all)
                    if (c.name != 'All')
                      DropdownMenuItem<String>(
                        value: c.name,
                        child: Text(c.name),
                      ),
                ],
                onChanged: (String? value) =>
                    setState(() => _category = value),
                validator: (String? value) => (value == null || value.isEmpty)
                    ? 'Please choose a category.'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Label(text: 'Days *'),
                        TextFormField(
                          controller: _daysController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter number of days',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          validator: (String? value) =>
                              _validateNumber(value, 'number of days', 60),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _Label(text: 'Budget / day *'),
                        TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter estimated cost',
                            prefixText: 'P ',
                            prefixIcon: Icon(Icons.payments_outlined),
                          ),
                          validator: _validateBudget,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _Label(text: 'Best season *'),
              DropdownButtonFormField<String>(
                initialValue: _season,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.wb_sunny_outlined),
                ),
                hint: const Text('Choose the best season'),
                items: <DropdownMenuItem<String>>[
                  for (final String season in _seasonOptions)
                    DropdownMenuItem<String>(
                      value: season,
                      child: Text(season),
                    ),
                ],
                onChanged: (String? value) => setState(() => _season = value),
                validator: (String? value) => (value == null || value.isEmpty)
                    ? 'Please choose a season.'
                    : null,
              ),
              const SizedBox(height: 16),
              _Label(text: 'Description *'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 400,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the place in at least 20 characters so other '
                      'readers know what to expect.',
                  alignLabelWithHint: true,
                ),
                validator: _validateDescription,
              ),
              const SizedBox(height: 8),
              _Label(text: 'Highlights * (separate with commas)'),
              TextFormField(
                controller: _highlightsController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'e.g. Beach, Hiking, Food',
                  prefixIcon: Icon(Icons.star_outline),
                ),
                validator: _validateHighlights,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined, size: 19),
                  label: Text(_saving ? 'Saving...' : 'Save destination'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF3C4A50),
        ),
      ),
    );
  }
}
