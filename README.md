# 📅 Habit Tracker with Streak System

A Flutter mobile application that helps users build and maintain consistent daily habits through streak tracking, milestone badges, analytics, and local notifications.

---

## 📱 Screenshots

> Add screenshots here after running the app

---

## ✨ Features

- **Habit Management** — Create, edit, and delete habits with custom title, description, category, icon, color, and frequency
- **Streak System** — Automatically tracks consecutive day streaks for each habit
- **Badge Rewards** — Unlock milestone badges as streaks grow (1, 3, 7, 14, 30, 60, 100 days)
- **Analytics** — Visual progress charts powered by fl_chart
- **Completion History** — Calendar view of past completions using table_calendar
- **Local Notifications** — Daily reminders for habit completion
- **Dark / Light Theme** — Toggle between themes, preference saved across sessions
- **Offline Storage** — All data stored locally using Hive (no internet required)

---

## 🏅 Badge Milestones

| Badge | Icon | Streak Required |
|-------|------|----------------|
| First Step | 👣 | 1 day |
| On a Roll | 🔥 | 3 days |
| Week Warrior | ⚔️ | 7 days |
| Fortnight Force | 💪 | 14 days |
| Monthly Master | 🏆 | 30 days |
| Unstoppable | 🚀 | 60 days |
| Legend | 👑 | 100 days |

---

## 🗂️ Project Structure

```
lib/
├── main.dart                   ← App entry point, theme setup, bottom nav
│
├── models/
│   ├── habit.dart              ← Habit model (id, title, streak, history...)
│   ├── habit_badge.dart        ← Badge model + badge definitions (kBadgeDefinitions)
│   └── habit_completion.dart   ← Completion record model
│
├── screens/
│   ├── home_screen.dart        ← Main habit list + today's completions
│   ├── history_screen.dart     ← Past completion history
│   ├── stats_screen.dart       ← Analytics and charts (fl_chart)
│   ├── badges_screen.dart      ← Earned and locked badges
│   ├── add_habit_screen.dart   ← Add new habit form
│   ├── edit_habit_screen.dart  ← Edit existing habit
│   └── habit_detail_screen.dart← Individual habit stats + calendar
│
├── services/
│   ├── habit_service.dart      ← CRUD operations on Hive boxes
│   ├── db_init_service.dart    ← Hive initialization and box opening
│   └── notification_service.dart ← Local notification scheduling
│
├── widgets/
│   ├── habit_card.dart         ← Habit tile with streak + complete button
│   └── badge_popup.dart        ← Popup shown when a badge is unlocked
│
└── utils/
    └── app_theme.dart          ← Light and dark ThemeData definitions
```

---

## ⚙️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| Local Storage | Hive + Hive Flutter |
| Analytics Charts | fl_chart |
| Calendar | table_calendar |
| Notifications | flutter_local_notifications |
| Fonts | google_fonts |
| Animations | animate_do |
| Progress UI | percent_indicator |
| Preferences | shared_preferences |
| ID Generation | uuid |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.0.0`
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device

### 1. Clone the repository
```bash
git clone https://github.com/your-username/habit-tracker.git
cd habit-tracker
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Run the app
```bash
flutter run
```

### Build APK
```bash
flutter build apk --release
```

---

## 📦 Key Dependencies

```yaml
fl_chart: ^0.66.0
flutter_local_notifications: ^17.0.0
shared_preferences: ^2.2.2
google_fonts: ^6.1.0
table_calendar: ^3.0.9
hive: ^2.2.3
hive_flutter: ^1.1.0
animate_do: ^3.3.4
percent_indicator: ^4.2.3
uuid: ^4.3.3
intl: ^0.19.0
```
---

## 📄 License

Developed for academic purposes under NMAMIT, Nitte Deemed to be University.
