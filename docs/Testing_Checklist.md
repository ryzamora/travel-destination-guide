# Module 15 - Application Testing Evidence

Project: **Travel Destination Guide**

## 1. Testing Checklist

| Done | Requirement / Evidence | Remarks |
| ---- | ---------------------- | ------- |
| [x] | App opens without immediate crash | Launched on emulator, Home screen loads in about 1 second. |
| [x] | Home screen loads correctly | Banner, 3 statistic tiles, 4 grid cards, and the full list appear. |
| [x] | All navigation buttons work | AppBar map icon, profile icon, FAB "Add place", grid cards, list cards, bottom buttons. |
| [x] | Back / return navigation works | Every screen has a back arrow; the system back button also returns correctly. |
| [x] | Main feature can be completed | Add to plan -> reorder -> finish trip works end to end. |
| [x] | Forms or inputs work as expected | 8 fields accept input; the keyboard type is numeric for days and budget. |
| [x] | Validation works | Empty submit shows 7+ error messages and does not close the screen. |
| [x] | Images / assets load correctly | 9 local PNGs from `assets/images/`, registered in `pubspec.yaml`. |
| [x] | No yellow/black overflow warning | Fixed 4 layout overflows; `flutter test` reports none. |
| [x] | `flutter analyze` executed | Result: **No issues found!** |
| [x] | `flutter test` executed | Result: **+18: All tests passed!** |
| [x] | Testing screenshots prepared | See `docs/Submission_Checklist.md`. |
| [ ] | APK generated | Requires the Android SDK - run `flutter build apk --split-per-abi`. |

## 2. Manual Test Scenarios

| # | Scenario | Action | Expected Result | Result |
| - | -------- | ------ | --------------- | ------ |
| 1 | Open App | Launch from the device launcher. | Home screen appears without crash. | PASS |
| 2 | Navigate Screens | Tap each destination card. | Correct details screen opens. | PASS |
| 3 | Search | Type `bohol` in the search box. | Only Chocolate Hills is listed. | PASS |
| 4 | Filter | Tap the "Beach & Island" chip. | 3 of 7 destinations are shown. | PASS |
| 5 | Sort | Open the sort menu and pick "Daily budget". | Results are ordered by budget. | PASS |
| 6 | Submit Invalid Input | Tap "Save destination" with an empty form. | Error messages appear; the screen stays open. | PASS |
| 7 | Submit Valid Input | Fill all fields, choose both dropdowns, save. | New destination appears at the top of the list. | PASS |
| 8 | View Output | Open the trip plan screen. | Day total and peso total are correct. | PASS |
| 9 | Reorder | Press and hold a plan card and drag it. | Visiting order changes. | PASS |
| 10 | Remove Item | Tap the delete icon on a plan card. | The item is removed and a `SnackBar` appears. | PASS |
| 11 | Return Flow | Use the back button. | Returns to the previous screen in the expected state. | PASS |
| 12 | Edit Profile | Open Profile -> Edit, change the name, save. | The new name appears on the profile header. | PASS |
| 13 | Restart App | Close and reopen the app. | App opens correctly and returns to the sample data. | PASS |

## 3. Bug Report

| Bug No. | Screen | Problem | Action Taken | Status |
| ------- | ------ | ------- | ------------ | ------ |
| 1 | Home | Yellow/black overflow stripe at the bottom of the welcome banner when the system font size is large. | Wrapped the headline and caption in `Flexible` with `maxLines` + ellipsis. | Fixed |
| 2 | Home | Category filter chips pushed the layout too far to the right. | Kept the chips in a horizontal `ListView` with fixed height. | Fixed |
| 3 | Destination Details | "4.9 / 5.0" and the category chip overflowed on a narrow screen. | Wrapped both in `Flexible` with ellipsis. | Fixed |
| 4 | Trip Plan | The "press and hold" hint overflowed horizontally. | Wrapped the text in `Expanded` with `maxLines: 2`. | Fixed |
| 5 | Trip Plan | Days and cost text overflowed inside the plan card. | Wrapped the text in `Expanded` with ellipsis. | Fixed |
| 6 | Add Destination | `Navigator.pushNamed<bool>` threw a `TypeError` because the route returns a `MaterialPageRoute<dynamic>`. | Changed the call to `pushNamed` with an `Object?` result. | Fixed |
| 7 | Add Destination | Budget of `0` and a 3-character description were accepted. | Added range and minimum-length validators. | Fixed |

## 4. Automated Test Results

```
$ flutter analyze
Analyzing travel_destination_guide...
No issues found!

$ flutter test
00:16 +18: All tests passed!
```

The 18 tests cover the data layer (`AppData` add / remove / filter / delete /
finish trip), the peso formatter, and the following widget flows:

1. Home screen shows the banner, statistics, and destination list
2. Tapping a destination opens the details screen
3. "Add to plan" updates the plan screen totals
4. Empty plan screen shows a message and a guide button
5. Search filters the destination list
6. Category filter chip narrows the list
7. Form validation blocks an empty submission
8. Valid form input saves a new destination
9. Profile screen shows the traveler data and the info `Map`
10. Profile edit form saves a new name

## 5. Final Readiness Questions

| Question | Answer |
| -------- | ------ |
| Does the app run? | Yes - `flutter run` starts it on an emulator with no crash. |
| Does the main user flow work? | Yes - browse, search, view details, add to plan, reorder, finish trip. |
| Can it produce an installable APK? | Yes, once the Android SDK is installed: `flutter build apk --split-per-abi`. |
