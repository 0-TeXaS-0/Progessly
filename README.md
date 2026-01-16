# 📊 Progressly - Flutter Edition

A modern, clean, and fully functional cross-platform app that helps users track progress, build habits, stay hydrated, stay productive, and stay motivated. Built with **Flutter**, **Provider State Management**, **Material Design 3**, and **SQLite** for offline-first functionality.

## ✨ Features

### 🎯 **5 Main Sections**
1. **Tasks** - Track productivity and complete tasks
2. **Meals** - Log meals and track calories
3. **Water** - Smart hydration tracking with goal calculation
4. **Habits** - Build consistency with daily habits
5. **Profile** - View progress, stats, and streaks

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

### 🎨 **Modern UI/UX**
- Material Design 3 components
- Dark Mode support (enabled by default)
- Smooth animations and transitions
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
- **Database**: SQLite (sqflite)
- **Storage**: SharedPreferences
- **State Management**: Provider

## 📁 Project Structure

```
lib/
├── core/theme.dart
├── data/
│   ├── models/
│   ├── database/
│   ├── preferences/
│   └── repositories/
├── providers/
├── ui/
│   ├── onboarding/
│   ├── home/
│   └── screens/
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
