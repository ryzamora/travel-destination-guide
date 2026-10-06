# Final Submission Checklist

## Required items

| Item | Required Content | Status |
| ---- | ---------------- | ------ |
| Source Code ZIP | Complete project folder including `lib`, `assets`, `pubspec.yaml`, and the Android project files. | Ready |
| APK File | Generated APK from `build/app/outputs/flutter-apk/`. | Needs the Android SDK |
| Screenshots PDF | UI, main feature, testing evidence, and APK/build output. | Capture on the emulator |
| Consultation Log | Module 14 project consultation record. | `docs/Consultation_Log.md` |
| Testing Checklist | Module 15 application testing evidence. | `docs/Testing_Checklist.md` |

## How to prepare the ZIP

1. Build the APK first so the `build` folder is not empty.
2. Delete `.dart_tool/`, `build/`, and any `.iml` files from the copy.
3. Copy the remaining folder to a new folder named with your group and project.
4. Compress it as a ZIP.

```
BSCS3A_Group1_TravelDestinationGuide.zip
BSCS3A_Group1_TravelDestinationGuide.apk
BSCS3A_Group1_TravelDestinationGuide_Screenshots.pdf
```

## Screenshot list (capture in this order)

| # | Screen / Evidence | How to capture |
| - | ----------------- | -------------- |
| 1 | Home screen | Launch the app, wait for the list to load. |
| 2 | Search working | Type `bohol` in the search box. |
| 3 | Category filter | Tap the "Beach & Island" chip. |
| 4 | Details screen | Tap the El Nido card, scroll to the travel tips. |
| 5 | Form validation | Tap "Add place" then "Save destination" (empty). |
| 6 | Form success | Fill the form, choose both dropdowns, save. |
| 7 | Trip plan | Add two places, open the map icon. |
| 8 | Finish trip dialog | Tap "Finish this trip". |
| 9 | Profile | Open the profile icon, scroll to the About box. |
| 10 | `flutter analyze` | Terminal screenshot: *No issues found!* |
| 11 | `flutter test` | Terminal screenshot: *+18: All tests passed!* |
| 12 | APK build | Terminal screenshot of the `flutter build apk` output. |
| 13 | APK folder | File Explorer showing `build\app\outputs\flutter-apk\`. |
| 14 | Installed app | The app running on the physical device. |

## Rubric self-check

| Criteria | Points | Where to point the instructor |
| -------- | ------ | ----------------------------- |
| Project Concept and Scope | 10 | `README.md` Section 1, `lib/data/sample_data.dart` |
| UI Design and Layout | 15 | `lib/utils/app_theme.dart`, `lib/widgets/` |
| Functionality | 25 | All screens in `lib/screens/` |
| Application Integration | 15 | `lib/main.dart` routes, `pubspec.yaml` assets |
| Testing and Refinement | 15 | `test/widget_test.dart`, `docs/Testing_Checklist.md` |
| APK and Submission Completeness | 10 | `build/app/outputs/flutter-apk/` |
| Presentation Readiness | 10 | `README.md`, this checklist |
| **Total** | **100** | |
