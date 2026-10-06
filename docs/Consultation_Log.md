# Module 14 - Project Consultation Log

Project: **Travel Destination Guide**

| # | Date | Progress Shown | Issue / Concern | Instructor Advice | Next Target |
| - | ---- | -------------- | --------------- | ----------------- | ----------- |
| 1 | _(date)_ | Project title, target user, problem statement, and a list of 5 screens. | Scope was originally "all of the Philippines" which is too large for the available lab time. | Reduce to 7 well-known destinations; prioritize one complete user flow over many half-finished features. | Create the Flutter project and build the Home screen. |
| 2 | _(date)_ | Home screen with a list of destinations, search box, and category filter chips. | Layout used hardcoded pixel heights; text was cut off on a small phone. | Use `Expanded` / `Flexible` with `maxLines` and ellipsis; avoid fixed heights inside `Column`. | Add the details screen and connect it with `Navigator.pushNamed`. |
| 3 | _(date)_ | Details screen with image header, description, quick facts, highlights, and travel tips. | Bottom buttons were labelled "OK" and "Click"; no feedback after saving. | Use clear button labels and show a `SnackBar` after every action. | Build the form screen with validation. |
| 4 | _(date)_ | Add Destination form with 8 fields, 2 dropdowns, and error messages. | The form accepted a daily budget of `0` and a description of 3 characters. | Add range validators and a minimum length; test the empty submission. | Add the Trip Plan summary screen. |
| 5 | _(date)_ | Trip Plan screen with a reorderable list, day total, and peso total; Profile screen with an edit form. | Plan totals were hardcoded strings and did not update after adding a destination. | Compute totals with `fold()` from the itinerary list and call `setState()` after every change. | Run `flutter analyze` and `flutter test`, then build the APK. |

## Evidence to attach

- [x] Screenshot of the Home screen with working navigation controls
- [x] Screenshot of the form screen with validation messages
- [x] Screenshot of the list and details screens
- [x] Screenshot of local images loading from `assets/images/`
- [x] Terminal screenshot of `flutter analyze` -> *No issues found!*
- [x] Short note in `README.md` Section 2 listing the connected screens
