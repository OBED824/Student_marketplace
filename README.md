# Student Marketplace (simple version)

A small Flutter app for university students to buy and sell items in UGX.
Written to be easy to read and revise: 16 Dart files, one state class.

**Features:** register / login (university email), search + category + university
filters, product details, post / edit / delete / mark as sold (with photos),
favorites, seller pages, notifications, contact seller by call, WhatsApp, SMS or email.

## Run
```
flutter pub get
flutter run
flutter test
```

## Demo credentials
Created automatically on first run (login screen has a "Fill demo account" button for Aisha).

| Account | Email | Password |
|---|---|---|
| Aisha Nakato (Makerere) | `aisha@students.mak.ac.ug` | `password123` |
| Brian Okello (Kyambogo) | `brian@students.kyu.ac.ug` | `password123` |
| Grace Atim (UCU) | `grace@stud.ucu.ac.ug` | `password123` |

Your own account: university email (e.g. `name@students.mak.ac.ug`), phone like `0771234567`,
password of 6+ characters with a number.

## Structure
```
lib/
  main.dart        start-up, login or main screen
  models.dart      AppUser, Product, AppNotification
  helpers.dart     constants, validators, formatters
  app_state.dart   ALL data + actions (Provider ChangeNotifier), saved with SharedPreferences
  widgets.dart     ProductCard, ProductGrid, EmptyState, Avatar
  screens/         one file per screen
```
Read `docs/Study_Notes.pdf` for a guided walkthrough, concepts to revise and practice exercises.

Data is stored only on the phone (no backend).
