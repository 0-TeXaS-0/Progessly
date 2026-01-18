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

### 🏆 **Personal Records**
- Track your best performances across all categories
- Records for: Most tasks completed, water consumed, meals logged, habits completed, longest streak
- Visual trophy display with achievement dates
- Auto-updates when you break records

### 🔊 **Sound Effects & Haptics**
- System sounds for all interactions
- Haptic feedback (vibration) on actions
- Different sounds for: task completion, deletion, habits, water logging, streaks, record breaking
- Configurable in settings (enable/disable independently)

### ⚖️ **Unit Preferences**
- **Water Units**: Choose between ml, oz, or cups
- **Weight Units**: kg or lbs
- Auto-conversion throughout the app
- Persistent preferences

### ✨ **Advanced Gestures**
- **Swipe-to-Delete**: Swipe left to delete with confirmation
- **Long-Press Menus**: Hold items for quick actions
- **Drag-to-Reorder**: Hold and drag tasks to change priority
- Haptic feedback on all gestures

### 🎯 **Task Priority System**
- 3 Priority levels: Low (🟢), Medium (🟠), High (🔴)
- Visual color-coded indicators and borders
- Auto-sort by priority and completion status
- Quick priority changes via long-press menu
- Drag tasks to reorder manually
- Priority badges and icons

### 👤 **Profile Management**
- **Edit Profile**: Update name, email, age, weight, height, goal
- **Profile Avatar**: Upload photo from camera or gallery
- **Remove Photo**: Delete avatar and revert to default
- Image optimization (512x512, 85% quality)
- Persistent avatar storage
- Display avatar throughout the app

### ⚙️ **Settings Hub**
- **Unit Preferences**: Water and weight units
- **Sound & Haptics**: Toggle sound effects and vibration
- **About Section**: App version and info
- Centralized settings management

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
- **Database**: SQLite (sqflite v2.4.1) - version 3 schema
- **Storage**: SharedPreferences v2.3.5
- **State Management**: Provider
- **Notifications**: flutter_local_notifications v19.0.1
- **Timezone**: timezone v0.10.1, flutter_timezone v3.0.1
- **Charts**: fl_chart v1.1.1
- **Audio**: audioplayers v6.1.0 (sound effects)
- **Image Picker**: image_picker v1.1.2
- **Path Provider**: path_provider v2.1.4
- **Internationalization**: intl v0.20.2

## 📁 Project Structure

```
lib/
├── core/
│   └── theme.dart
├── data/
│   ├── models/
│   │   ├── meal_template_model.dart
│   │   ├── quote_model.dart            # Phase 3
│   │   ├── personal_record.dart        # NEW
│   │   ├── unit_preference.dart        # NEW
│   │   └── ...
│   ├── database/
│   │   └── progressly_database.dart    # v3 schema (tasks priority)
│   ├── preferences/
│   │   ├── notification_preferences.dart
│   │   ├── theme_preferences.dart      # Phase 3
│   │   └── ...
│   └── repositories/
│       ├── meal_repository.dart        # Templates support
│       ├── task_repository.dart        # Priority support
│       └── ...
├── providers/
│   ├── meal_provider.dart              # Templates support
│   ├── theme_provider.dart             # Phase 3
│   ├── profile_provider.dart           # Insights, heatmap, avatar
│   ├── unit_preferences_provider.dart  # NEW
│   ├── task_provider.dart              # Priority support
│   └── ...
├── services/
│   ├── notification_service.dart
│   ├── insights_service.dart           # Polish & Delight
│   ├── sound_service.dart              # NEW
│   └── personal_records_service.dart   # NEW
├── ui/
│   ├── animations/
│   │   └── page_transitions.dart       # Polish & Delight
│   ├── onboarding/
│   ├── home/
│   ├── screens/
│   │   ├── notification_settings_screen.dart
│   │   ├── meal_templates_screen.dart
│   │   ├── theme_customization_screen.dart  # Phase 3
│   │   ├── meals_screen.dart           # Redesigned
│   │   ├── enhanced_tasks_screen.dart  # NEW (priority, gestures)
│   │   ├── edit_profile_screen.dart    # NEW (avatar picker)
│   │   ├── personal_records_screen.dart # NEW
│   │   ├── settings_screen.dart        # NEW
│   │   └── ...
│   └── widgets/
│       ├── calendar_heatmap.dart       # Phase 3
│       ├── celebration_animation.dart  # Polish & Delight
│       ├── skeleton_loader.dart        # Polish & Delight
│       ├── gesture_widgets.dart        # NEW (swipe, drag, long-press)
│       └── ...
└── main.dart
```
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
