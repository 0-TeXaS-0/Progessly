# 📊 Progressly - Flutter Edition

A modern, clean, and fully functional cross-platform app that helps users track progress, build habits, stay hydrated, stay productive, and stay motivated. Built with **Flutter**, **Provider State Management**, **Material Design 3**, and **SQLite** for offline-first functionality.

## ✨ Features

### 🎯 **5 Main Sections**
1. **Tasks** - Track productivity and complete tasks
2. **Meals** - Log meals with smart templates and quick-add
3. **Water** - Smart hydration tracking with goal calculation
4. **Habits** - Build consistency with daily habits
5. **Profile** - View progress, stats, and streaks

### 🔔 **Smart Notifications**
- Customizable reminders for all tracking categories
- Timezone-aware scheduling
- Water reminders (2-4 hour intervals, 8 AM - 10 PM)
- Meal reminders (Breakfast 8 AM, Lunch 1 PM, Dinner 7 PM)
- Task reminders (Morning 9 AM, Evening 6 PM)
- Habit reminders (Daily 9 AM per habit)
- Streak reminders (Daily 8 PM)
- Master toggle and per-category controls

### 🍽️ **Meal Template System**
- Create reusable meal templates by type (Breakfast, Lunch, Dinner, Snack)
- One-tap logging from saved templates
- Automatic calorie tracking
- Smart time-based meal suggestions
- Template usage statistics
- Favorite templates
- Quick Log + History tabs

### 🔥 **Gamification: Streak System**
- Daily streaks for all tracking categories
- Weekly streak tracking
- Longest streak records
- Streaks reset if you miss a day
- Visual progress indicators

### 🚀 **Onboarding Flow**
- User name setup
- Age selection
- Gender selection
- Weight input (optional, for water goal calculation)
- Notification preferences

### 💧 **Smart Water Goal System**
- Automatically calculates daily water intake based on:
  - Age, Gender, Weight
  - Formula: `weight * 35 ml` with gender adjustments
- Quick-add water buttons (250ml, 500ml, 750ml)
- Custom amount logging
- Progress visualization

### 🎨 **Profile Customization**
- **Theme Colors**: 8 color options (Purple, Blue, Green, Orange, Pink, Teal, Red, Indigo)
- **Dark/Light Mode**: Toggle between themes
- **Live Preview**: Real-time theme changes
- Persistent theme preferences

### 💡 **Smart Insights**
- AI-like pattern analysis of your 7-day activity
- Productivity insights (best days, consistency tracking)
- Hydration tracking & goal achievement alerts
- Meal pattern analysis & reminders
- Habit tracking & perfect day detection
- Streak milestone celebrations
- Color-coded insight cards by priority

### 📅 **Activity Calendar**
- GitHub-style heatmap visualization
- Last 12 weeks of activity
- Color intensity based on daily completion (0-100%)
- Tap any day for detailed breakdown
- Smart scoring across all categories

### 💬 **Daily Motivation**
- Daily rotating inspirational quotes
- 21+ quotes across 7 categories
- Special milestone quotes for streaks
- Beautiful gradient card display

### 🎨 **Modern UI/UX**
- Material Design 3 components
- Dark/Light mode with theme customization
- Smooth page transitions & animations
- Celebration animations & confetti effects
- Loading skeleton screens
- Clean typography & modern icons
- Cross-platform support

### 📱 **Offline-First Architecture**
- No internet required
- All data stored locally using SQLite
- SharedPreferences for user settings
- Complete data persistence
- Works on iOS, Android, Web, Desktop

## 🛠️ Tech Stack

- **Language**: Dart
- **Framework**: Flutter
- **Architecture**: MVVM with Provider
- **Database**: SQLite (sqflite v2.4.1) - version 2 schema
- **Storage**: SharedPreferences v2.3.5
- **State Management**: Provider
- **Notifications**: flutter_local_notifications v19.0.1
- **Timezone**: timezone v0.10.1, flutter_timezone v3.0.1
- **Charts**: fl_chart v1.1.1
- **Internationalization**: intl v0.20.2

## 📁 Project Structure

```
lib/
├── core/
│   └── theme.dart
├── data/
│   ├── models/
│   │   ├── meal_template_model.dart
│   │   ├── quote_model.dart            # NEW: Phase 3
│   │   └── ...
│   ├── database/
│   │   └── progressly_database.dart    # v2 schema
│   ├── preferences/
│   │   ├── notification_preferences.dart
│   │   ├── theme_preferences.dart      # NEW: Phase 3
│   │   └── ...
│   └── repositories/
│       ├── meal_repository.dart        # Templates support
│       └── ...
├── providers/
│   ├── meal_provider.dart              # Templates support
│   ├── theme_provider.dart             # NEW: Phase 3
│   ├── profile_provider.dart           # Insights & heatmap
│   └── ...
├── services/
│   ├── notification_service.dart
│   └── insights_service.dart           # NEW: Polish & Delight
├── ui/
│   ├── animations/
│   │   └── page_transitions.dart       # NEW: Polish & Delight
│   ├── onboarding/
│   ├── home/
│   ├── screens/
│   │   ├── notification_settings_screen.dart
│   │   ├── meal_templates_screen.dart
│   │   ├── theme_customization_screen.dart  # NEW: Phase 3
│   │   ├── meals_screen.dart           # Redesigned
│   │   └── ...
│   └── widgets/
│       ├── calendar_heatmap.dart       # NEW: Phase 3
│       ├── celebration_animation.dart  # NEW: Polish & Delight
│       └── skeleton_loader.dart        # NEW: Polish & Delight
└── main.dart
```

## 🚀 Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Build release
flutter build apk --release  # Android
flutter build ios --release  # iOS
flutter build web --release  # Web
```

## 📊 Usage Guide

- **Tasks**: Add, complete, delete tasks with streak tracking
- **Water**: Quick-add or custom amounts, auto-calculated daily goals
- **Meals**: Log meals with calories and meal types
- **Habits**: Create daily habits and track completion streaks
- **Profile**: View comprehensive stats and streaks

## 🎯 Key Features

### Smart Water Goal Calculation
```dart
dailyGoal = weight * 35 ml
// 5% lower for females
```

### Streak System
- Daily, weekly, and longest streaks
- Automatic reset on missed days
- Visual progress tracking

## 🛡️ Data Privacy

- ✅ All data stored locally
- ✅ No internet required
- ✅ No tracking or ads
- ✅ Open source

## 📱 Platform Support

- ✅ Android (API 21+)
- ✅ iOS (iOS 11+)
- ✅ Web
- ✅ Windows/macOS/Linux


**Built with ❤️ in Flutter**
