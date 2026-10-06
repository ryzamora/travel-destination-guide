import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'models/destination.dart';
import 'screens/add_destination_screen.dart';
import 'screens/all_destinations_screen.dart';
import 'screens/destination_detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/plan_summary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

/// Entry point of the Travel Destination Guide.
///
/// The app uses named routes for the simple screens and `onGenerateRoute`
/// for the details screen, because that screen needs a [Destination]
/// argument.
void main() {
  runApp(const TravelDestinationGuideApp());
}

/// Root widget. It owns the [AppData] object and rebuilds the [MaterialApp]
/// whenever the data changes, using setState().
class TravelDestinationGuideApp extends StatefulWidget {
  const TravelDestinationGuideApp({super.key});

  @override
  State<TravelDestinationGuideApp> createState() =>
      _TravelDestinationGuideAppState();
}

class _TravelDestinationGuideAppState
    extends State<TravelDestinationGuideApp> {
  /// All data used by the app while it is running (lists, map, profile).
  final AppData data = AppData();

  /// Called by the screens after they change the data, so the whole app
  /// can rebuild. The screens also call their own setState.
  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Destination Guide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.home,
      routes: <String, WidgetBuilder>{
        AppRoutes.home: (BuildContext context) => HomeScreen(
          data: data,
          onChanged: _onChanged,
        ),
        AppRoutes.allDestinations: (BuildContext context) =>
            AllDestinationsScreen(data: data, onChanged: _onChanged),
        AppRoutes.addDestination: (BuildContext context) =>
            AddDestinationScreen(data: data, onChanged: _onChanged),
        AppRoutes.tripPlan: (BuildContext context) =>
            PlanSummaryScreen(data: data, onChanged: _onChanged),
        AppRoutes.profile: (BuildContext context) =>
            ProfileScreen(data: data, onChanged: _onChanged),
        AppRoutes.settings: (BuildContext context) =>
            const SettingsScreen(),
      },
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == AppRoutes.details) {
          final Object? argument = settings.arguments;
          if (argument is! Destination) return null;
          return MaterialPageRoute<void>(
            builder: (BuildContext context) => DestinationDetailScreen(
              data: data,
              destination: argument,
              onChanged: _onChanged,
            ),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
