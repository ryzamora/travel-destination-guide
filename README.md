# Travel Destination Guide

**Course:** CSE101 / Elective 1 - Fundamentals of Mobile App Development
**Modules:** Flutter Module 14 (Project Development) and Module 15 (Testing & APK)
**College:** Concepcion Holy Cross College, Inc. - School of Computer Studies

A beginner-level Flutter Android application that lists local Philippine tourist
destinations with an image, location, description and travel tips, and lets the
user build a personal itinerary.

---

## 1. Project Concept

| Item | Value |
| --- | --- |
| App title | Travel Destination Guide |
| Problem | Students and beginners planning a trip do not have one simple place to compare destinations, costs and travel tips before going. |
| Target user | College students and first-time travellers in the Philippines. |
| Expected output | An installable Android app that works offline. |
| Data source | Hardcoded local sample data. **No database is used.** |

## 2. Screens (5 total, requirement is 3+)

| Screen | File | Purpose |
| --- | --- | --- |
| Home | `lib/screens/home_screen.dart` | Welcome banner, search, category filters, statistics, top destinations grid, full list. |
| All Destinations | `lib/screens/all_destinations_screen.dart` | Search + filter + sort list of every destination. |
| Destination Details | `lib/screens/destination_detail_screen.dart` | Image header, description, quick facts, highlights, travel tips, cost estimate. |
| Add Destination (Form) | `lib/screens/add_destination_screen.dart` | Form with 8 fields, dropdowns and validation. |
| Trip Plan Summary | `lib/screens/plan_summary_screen.dart` | Reorderable itinerary, day and cost totals, remove/clear, finish trip. |
| Profile | `lib/screens/profile_screen.dart` | Simulated traveler profile, edit form, interests, About box built from a `Map`. |

## 3. Requirement Compliance

| Requirement | How it is satisfied |
| --- | --- |
| Minimum 3 screens | 6 screens (see table above). |
| Page navigation | Named routes in `MaterialApp.routes` plus `onGenerateRoute` for the details screen (`lib/main.dart`). |
| UI widgets used | `Text`, `Icon`, `Image`, `Container`, `Card`, `ElevatedButton`, `OutlinedButton`, `TextButton`, `IconButton`, `TextField`, `TextFormField`, `AppBar`, `Chip`, `FilterChip`, `ChoiceChip`, `DropdownButtonFormField`, `FloatingActionButton`. |
| Layout widgets used | `Column`, `Row`, `ListView`, `GridView`, `Expanded`, `Stack`, `Wrap`, `SliverAppBar`, `ReorderableListView`. |
| Local data only | `List<Destination>`, `List<String>`, and `Map<String, dynamic>` in `lib/data/`. No database package. |
| Form feature | Add Destination screen with `Form`, controllers and validators. |
| Validation | Required-field, min-length, numeric range, and comma-format validators with red error text. |
| Responsive design | `Expanded`, `Flexible`, `SingleChildScrollView`, `shrinkWrap` lists, `maxLines` + ellipsis, `FittedBox`, and a tall-phone widget test at 420 x 1800. |
| Testing | 18 automated tests in `test/widget_test.dart`; `flutter analyze` reports 0 issues. |
| Final output | Source folder, screenshots, and APK (see Section 7). |

## 4. Project Structure

```
travel_destination_guide/
├── assets/
│   └── images/              # 9 local PNG images (no internet needed)
├── lib/
│   ├── main.dart            # Entry point, theme, named routes
│   ├── data/
│   │   ├── app_data.dart    # In-memory state (List + Map + profile)
│   │   └── sample_data.dart # 7 sample destinations, categories, about Map
│   ├── models/
│   │   ├── destination.dart
│   │   └── traveler.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── all_destinations_screen.dart
│   │   ├── destination_detail_screen.dart
│   │   ├── add_destination_screen.dart
│   │   ├── plan_summary_screen.dart
│   │   └── profile_screen.dart
│   ├── utils/
│   │   ├── app_theme.dart   # Colors, fonts, widget styles
│   │   ├── app_routes.dart  # Route name constants
│   │   └── formatters.dart  # Peso / rating formatting
│   └── widgets/
│       ├── destination_card.dart
│       ├── rating_stars.dart
│       ├── section_header.dart
│       ├── stat_card.dart
│       └── empty_state.dart
├── test/
│   └── widget_test.dart
├── tool/
│   └── generate_assets.dart # Optional: regenerates the PNG images
├── docs/
│   ├── Consultation_Log.md
│   ├── Testing_Checklist.md
│   └── Submission_Checklist.md
└── pubspec.yaml
```

## 5. How to Run

```bash
flutter pub get          # install packages
flutter analyze          # static analysis (expected: No issues found)
flutter test             # run the 18 automated tests
flutter run              # run on emulator or Android device
```

## 6. Optional: regenerate the images

The 9 images in `assets/images/` were created offline with a small Dart script,
so the project never depends on the internet.

```bash
dart run tool/generate_assets.dart
```

## 7. How to Build the APK

> Requires the Android SDK. If `flutter build apk` says
> "No Android SDK found", install Android Studio (SDK Manager) or the
> command-line tools, then set `ANDROID_HOME` and run
> `flutter doctor` until the Android toolchain turns green.

```bash
flutter build apk --split-per-abi   # smaller files, one per CPU
# or
flutter build apk                   # single universal APK
```

Output folder: `build/app/outputs/flutter-apk/`

## 8. Screenshots Needed for Submission

1. Home screen (banner, stats, grid, list)
2. All Destinations screen with a search keyword
3. Destination Details screen
4. Add Destination form - **empty submission showing validation errors**
5. Add Destination form - **filled successfully**
6. Trip Plan Summary with at least 2 destinations
7. Trip Plan "Finish this trip" dialog
8. Profile screen with the About box
9. Terminal showing `flutter analyze` -> *No issues found!*
10. Terminal showing `flutter test` -> *All tests passed!*
11. File Explorer showing `build/app/outputs/flutter-apk/`
12. The installed app running on the device
