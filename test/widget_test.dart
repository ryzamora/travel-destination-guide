import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_destination_guide/data/app_data.dart';
import 'package:travel_destination_guide/data/sample_data.dart';
import 'package:travel_destination_guide/main.dart';
import 'package:travel_destination_guide/models/destination.dart';
import 'package:travel_destination_guide/utils/app_routes.dart';
import 'package:travel_destination_guide/utils/formatters.dart';

/// The default test window is short, which makes lazy lists hide their
/// content. A tall phone window is used instead so every widget is built.
void useTallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(420, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  group('AppData (local data only)', () {
    test('loads the seven sample destinations', () {
      final AppData data = AppData();
      expect(data.destinations.length, 7);
      expect(data.destinations.first.name, 'El Nido');
      expect(data.itinerary, isEmpty);
    });

    test('adds and removes destinations in the itinerary', () {
      final AppData data = AppData();
      final Destination elNido = data.destinations.first;

      expect(data.addToPlan(elNido), isTrue);
      expect(data.addToPlan(elNido), isFalse, reason: 'should not add twice');
      expect(data.isPlanned(elNido), isTrue);
      expect(data.plannedDays, 3);
      expect(data.estimatedTotal, 3 * 4500);

      data.removeFromPlan(elNido.id);
      expect(data.itinerary, isEmpty);
    });

    test('filters by keyword and category', () {
      final AppData data = AppData();

      expect(data.filter('palawan', 'All').length, 1);
      expect(data.filter('BOHOL', 'All').first.name, 'Chocolate Hills');
      expect(data.filter('', 'Beach & Island').length, 3);
      expect(data.filter('nothing here', 'All'), isEmpty);
    });

    test('deletes a custom destination and removes it from the plan', () {
      final AppData data = AppData();
      final Destination custom = data.destinations.first;
      data.addToPlan(custom);
      data.deleteDestination(custom.id);

      expect(data.destinations.length, 6);
      expect(data.itinerary, isEmpty);
    });

    test('finishing a trip clears the plan and updates the profile', () {
      final AppData data = AppData();
      final int before = data.traveler.tripsCompleted;
      data.addToPlan(data.destinations.first);
      data.markTripCompleted();
      data.clearPlan();

      expect(data.itinerary, isEmpty);
      expect(data.traveler.tripsCompleted, before + 1);
    });

    test('app info is stored in a Map', () {
      final Map<String, dynamic> info = buildAppInfo();
      expect(info['appName'], 'Travel Destination Guide');
      expect(info['dataSource'], contains('no database'));
    });
  });

  group('Formatters', () {
    test('formats peso amounts with separators', () {
      expect(formatPeso(1500), 'P1,500');
      expect(formatPeso(1234567), 'P1,234,567');
      expect(formatRating(4.9), '4.9');
    });
  });

  group('Widget tests', () {
    testWidgets('Home screen shows the banner, stats and destination list', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      expect(find.text('Travel Guide'), findsOneWidget);
      expect(
        find.text("Hello, Traveler! Let's Explore the Philippines!"),
        findsOneWidget,
      );
      expect(find.text('Top Destinations'), findsOneWidget);
      expect(find.text('All Destinations'), findsOneWidget);
      expect(find.text('El Nido'), findsWidgets);
      expect(find.text('7 of 7 shown'), findsOneWidget);
    });

    testWidgets('Tapping a destination opens the details screen', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('El Nido').first);
      await tester.pumpAndSettle();

      expect(find.text('About this place'), findsOneWidget);
      expect(find.text('Travel tips'), findsOneWidget);
      expect(
        find.widgetWithText(ElevatedButton, 'Add to plan'),
        findsOneWidget,
      );
    });

    testWidgets('Add to plan updates the plan screen totals', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('El Nido').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add to plan'));
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(OutlinedButton, 'In my plan'),
        findsOneWidget,
      );

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('My trip plan'));
      await tester.pumpAndSettle();

      expect(find.text('My Trip Plan'), findsOneWidget);
      expect(find.text('P13,500'), findsOneWidget);
      expect(find.text('Est. cost'), findsOneWidget);
    });

    testWidgets('Empty plan screen shows a message and a guide button', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('My trip plan'));
      await tester.pumpAndSettle();

      expect(find.text('Your plan is empty'), findsOneWidget);
      expect(find.text('Browse destinations'), findsOneWidget);
    });

    testWidgets('Search filters the destination list', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'Search place, city, or region...'),
        'bohol',
      );
      await tester.pumpAndSettle();

      expect(find.text('Chocolate Hills'), findsWidgets);
      expect(find.text('El Nido'), findsNothing);
      expect(find.text('1 of 7 shown'), findsOneWidget);
    });

    testWidgets('Category filter chip narrows the list', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilterChip, 'Beach & Island'));
      await tester.pumpAndSettle();

      expect(find.text('3 of 7 shown'), findsOneWidget);
      expect(find.text('El Nido'), findsWidgets);
      expect(find.text('Banaue Rice Terraces'), findsNothing);
    });

    testWidgets('Form validation blocks an empty submission', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add place'));
      await tester.pumpAndSettle();
      expect(find.text('Add a Destination'), findsOneWidget);

      await tester.tap(find.text('Save destination'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter the place name.'), findsOneWidget);
      expect(find.text('Please choose a category.'), findsOneWidget);
      expect(find.text('Add a Destination'), findsOneWidget);
    });

    testWidgets('Valid form input saves a new destination', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add place'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter destination name'),
        'Siargao Island',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Enter city, town, or area',
        ),
        'General Luna, Surigao del Norte',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter region'),
        'Caraga',
      );

      await tester.tap(find.text('Choose a category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Beach & Island').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter number of days'),
        '4',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Enter estimated cost'),
        '1800',
      );

      await tester.tap(find.text('Choose the best season'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('January to March').last);
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'Describe the place in at least 20 characters so other readers '
              'know what to expect.',
        ),
        'A laid back island known for its surf breaks and lagoons.',
      );
      await tester.enterText(
        find.widgetWithText(
          TextFormField,
          'e.g. Beach, Hiking, Food',
        ),
        'Surfing, Island hopping',
      );

      await tester.tap(find.text('Save destination'));
      await tester.pumpAndSettle();

      expect(find.text('New destination saved.'), findsOneWidget);
      expect(find.text('8 of 8 shown'), findsOneWidget);
    });

    testWidgets('Profile screen shows the traveler data and the info Map', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();


      expect(find.text('Concepcion Holy Cross College, Inc.'), findsOneWidget);
      expect(find.text('Mr. Patrick Jason L. Torres'), findsOneWidget);
    });

    testWidgets('Profile edit form saves a new name', (
      WidgetTester tester,
    ) async {
      useTallPhone(tester);
      await tester.pumpWidget(const TravelDestinationGuideApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Edit profile'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Ana Dela Cruz',
      );
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();

      expect(find.text('Ana Dela Cruz'), findsOneWidget);
    });
  });

  test('route names are all different', () {
    final Set<String> routes = <String>{
      AppRoutes.home,
      AppRoutes.allDestinations,
      AppRoutes.details,
      AppRoutes.addDestination,
      AppRoutes.tripPlan,
      AppRoutes.profile,
    };
    expect(routes.length, 6);
  });
}
