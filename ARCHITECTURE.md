# Progressly Flutter - Architecture Overview

## 🏗️ Project Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     PRESENTATION LAYER                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   Tasks     │  │    Meals    │  │    Water    │    │
│  │   Screen    │  │   Screen    │  │   Screen    │  ...│
│  └─────────────┘  └─────────────┘  └─────────────┘    │
│                          ↓                               │
│              Consumer<Provider>(builder)                │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                   STATE MANAGEMENT LAYER                │
│  ┌──────────────────────────────────────────────────┐  │
│  │  TaskProvider   MealProvider   WaterProvider     │  │
│  │  (ChangeNotifier - manages state & business logic)│  │
│  └──────────────────────────────────────────────────┘  │
│                          ↓↑                             │
│  ┌──────────────────────────────────────────────────┐  │
│  │         NotificationService (Singleton)           │  │
│  │  (Schedules reminders with timezone awareness)   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │  TaskRepository  MealRepository  WaterRepository │  │
│  │  (Data access abstraction + Template CRUD)       │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                         │
│  ┌────────────────┐              ┌─────────────────┐   │
│  │   DAOs         │              │  Preferences    │   │
│  │  (Database     │              │  Manager        │   │
│  │   Access)      │              │  + Notification │   │
│  └────────────────┘              │  Preferences    │   │
│         ↓                        └─────────────────┘   │
│  ┌────────────────┐                      ↓             │
│  │  SQLite DB v2  │              ┌─────────────────┐   │
│  │  Tables:       │              │ SharedPrefs     │   │
│  │  - tasks       │              │ - user profile  │   │
│  │  - meals       │              │ - notification  │   │
│  │  - meal_templates (NEW)       │   settings      │   │
│  │  - water_logs  │              │ - onboarding    │   │
│  │  - habits      │              └─────────────────┘   │
│  │  - streaks     │                                     │
│  └────────────────┘                                     │
└─────────────────────────────────────────────────────────┘
```

## 📦 Layer Responsibilities

### 1. Presentation Layer (`ui/`)
**Responsibility**: Display data and handle user interactions

- **Screens**: TasksScreen, MealsScreen, WaterScreen, HabitsScreen, ProfileScreen
- **Widgets**: Stateless/Stateful widgets for UI components
- **Consumer**: Listens to Provider changes and rebuilds UI

**Key Principle**: UI should be dumb - no business logic!

---

### 2. State Management Layer (`providers/`)
**Responsibility**: Manage application state and business logic

- **Providers**: TaskProvider, MealProvider, WaterProvider, HabitProvider, ProfileProvider
- **ChangeNotifier**: Notifies listeners when state changes
- **Business Logic**: Calculate streaks, validate data, coordinate operations

**Key Principle**: Single source of truth for each feature!

---

### 3. Business Logic Layer (`data/repositories/`)
**Responsibility**: Abstract data access and coordinate data operations

- **Repositories**: TaskRepository, MealRepository, WaterRepository, HabitRepository
- **Abstraction**: Hide implementation details from providers
- **Coordination**: Combine multiple data sources if needed

**Key Principle**: Providers should not directly access DAOs!

---

### 4. Data Layer (`data/`)
**Responsibility**: Persist and retrieve data

#### Database (`data/database/`)
- **ProgresslyDatabase**: Database initialization and schema
- **DAOs**: TaskDao, MealDao, WaterDao, HabitDao
- **CRUD Operations**: Create, Read, Update, Delete

#### Preferences (`data/preferences/`)
- **PreferencesManager**: Wrapper for SharedPreferences
- **User Settings**: Profile, onboarding status, preferences

#### Models (`data/models/`)
- **Data Classes**: TaskModel, MealModel, WaterLogModel, HabitModel, UserProfile
- **Serialization**: toMap(), fromMap() for database operations

**Key Principle**: Models should be immutable with copyWith()!

---

## � Notification System Architecture

### Components

1. **NotificationService** (`services/notification_service.dart`)
   - Singleton service for all notification operations
   - Timezone-aware scheduling using `flutter_timezone`
   - Manages notification channels and permissions
   - Schedules: Water, Meals, Tasks, Habits, Streak reminders

2. **NotificationPreferences** (`data/preferences/notification_preferences.dart`)
   - Stores notification settings in SharedPreferences
   - Master enable/disable toggle
   - Per-category enable/disable (water, meals, tasks, habits, streak)
   - Water reminder interval (2-4 hours)

3. **Integration with Providers**
   - Each provider initializes notification scheduling
   - Providers respect user preferences before scheduling
   - Dynamic rescheduling on settings changes

### Notification Flow

```
User enables notifications in settings
    ↓
NotificationSettingsScreen updates NotificationPreferences
    ↓
Provider loads new preferences
    ↓
Provider calls NotificationService.schedule*Reminders()
    ↓
NotificationService checks timezone
    ↓
NotificationService schedules notifications with flutter_local_notifications
    ↓
OS delivers notifications at scheduled times
```

### Meal Template System

**New Tables**:
- `meal_templates` - stores reusable meal templates

**New Models**:
- `MealTemplateModel` - template data with usage tracking

**Repository Methods**:
- `addTemplate()`, `getTemplatesByMealType()`, `updateTemplate()`
- `deleteTemplate()`, `logFromTemplate()`, `incrementTemplateUsage()`

**Provider Methods**:
- `getTemplatesByType()` - filter templates by meal type
- `getSuggestedMealType()` - time-based meal suggestions
- `logFromTemplate()` - one-tap logging from template
- `toggleTemplateFavorite()` - favorite system

**UI Screens**:
- `MealTemplatesScreen` - manage templates (CRUD)
- `MealsScreen` - redesigned with Quick Log + History tabs

## 🎨 Theme System Architecture

### Components

1. **ThemeProvider** (`providers/theme_provider.dart`)
   - ChangeNotifier for theme state management
   - Dynamic theme switching (Material 3)
   - Persists user preferences
   - 8 color options + dark/light mode

2. **ThemePreferences** (`data/preferences/theme_preferences.dart`)
   - Stores theme color and brightness in SharedPreferences
   - Available colors: Purple, Blue, Green, Orange, Pink, Teal, Red, Indigo
   - Toggle dark/light mode

3. **Theme Flow**
```
User selects color/mode
    ↓
ThemeCustomizationScreen updates ThemeProvider
    ↓
ThemeProvider updates preferences
    ↓
ThemeProvider.notifyListeners()
    ↓
MaterialApp rebuilds with new theme
    ↓
All screens update with new colors
```

## 💡 Smart Insights System

### InsightsService (`services/insights_service.dart`)

**Pattern Analysis**:
- Analyzes last 7 days of user activity
- Generates up to 5 prioritized insights
- Categories: Achievement, Warning, Motivation, Productivity, Health

**Insight Types**:
1. **Productivity**: Best performing days, consistency tracking
2. **Hydration**: Goal achievement, daily averages
3. **Meals**: Tracking patterns, skipped days
4. **Habits**: Perfect days, completion rates
5. **Streaks**: Milestone celebrations

**Scoring Algorithm**:
```dart
totalScore = 0
totalScore += (tasks * 20).clamp(0, 20)     // Max 20 points
totalScore += (meals * 13).clamp(0, 40)     // Max 40 points
totalScore += (waterGoalMet ? 20 : 0)       // 20 points
totalScore += (habits * 7).clamp(0, 20)     // Max 20 points
intensity = totalScore.clamp(0, 100)        // 0-100%
```

## 📅 Activity Heatmap System

### CalendarHeatmap Widget
- GitHub-style contribution graph
- 12 weeks of historical data
- Color intensity based on daily score (0-100%)
- Interactive: tap for day details
- 7 rows (days) × 12 columns (weeks)

**Color Coding**:
- 0%: Base color (no activity)
- 1-24%: 30% opacity
- 25-49%: 50% opacity
- 50-74%: 70% opacity
- 75-100%: 100% opacity (primary color)

## 🎉 Animation & Polish Features

### 1. Celebration Animations
**CelebrationAnimation**: Scale animation with bounce effect
- Duration: 600ms
- Sequence: Scale up (1.0 → 1.2) → Shrink (1.2 → 0.95) → Bounce back (0.95 → 1.0)
- Curves: easeOut, easeInOut, elasticOut

**ConfettiOverlay**: Particle-based celebration
- 50 colored particles
- 3-second animation
- Random colors, sizes, rotations
- Gravity-like falling effect

### 2. Page Transitions
- **FadePageRoute**: Cross-fade transition
- **SlidePageRoute**: Directional slides (up/down/left/right)
- **ScalePageRoute**: Pop-in/out effect
- All transitions: 300ms with easing curves

### 3. Loading States
**SkeletonLoader**: Shimmer loading effect
- 1.5s animation loop
- Adapts to theme (dark/light)
- Gradient shimmer effect
- Components: ProfileSkeleton, ListSkeleton, CardSkeleton

## 💬 Quote System

**QuoteService** (`data/models/quote_model.dart`)
- 21+ motivational quotes
- 7 categories: productivity, habits, progress, perseverance, health, discipline, achievement
- Daily rotation based on day of year
- Special milestone quotes for streaks (7, 30, 50, 100 days)

---

## �🔄 Data Flow Example: Adding a Task

```
User taps "Add Task" button
         ↓
TasksScreen calls provider.addTask()
         ↓
TaskProvider.addTask() validates input
         ↓
TaskRepository.addTask() abstracts storage
         ↓
TaskDao.insertTask() executes SQL INSERT
         ↓
SQLite Database stores the task
         ↓
TaskProvider.loadTasks() refreshes state
         ↓
notifyListeners() triggers UI rebuild
         ↓
Consumer rebuilds TasksScreen
         ↓
User sees the new task in the list
```

## 🎯 Design Patterns Used

### 1. MVVM (Model-View-ViewModel)
- **Model**: Data models and database entities
- **View**: UI screens and widgets
- **ViewModel**: Providers (ChangeNotifier)

### 2. Repository Pattern
- Abstracts data sources
- Provides clean API for data access
- Allows easy switching of data sources

### 3. DAO Pattern
- Separates database operations
- Encapsulates SQL queries
- Provides type-safe database access

### 4. Observer Pattern
- ChangeNotifier notifies listeners
- Consumer listens to changes
- Automatic UI updates

### 5. Singleton Pattern
- Database instance (single connection)
- PreferencesManager (single instance)

## 📱 Screen Navigation Flow

```
App Launch
    ↓
main.dart initializes PreferencesManager
    ↓
Check: isOnboardingComplete()?
    ↓
┌─────────────────────────────┐
│ No → OnboardingScreen       │
│   → Complete 5 steps        │
│   → Save user profile       │
│   → Set onboarding complete │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│ Yes → HomeScreen            │
│   → Bottom Navigation Bar   │
│   → 5 Main Screens          │
└─────────────────────────────┘
    ↓
User selects screen from bottom nav
    ↓
┌───────────────────────────────────┐
│  Tasks  │ Meals │ Water │ Habits  │ Profile
└───────────────────────────────────┘
```

## 🔑 Key Files and Their Roles

| File | Role | Layer |
|------|------|-------|
| `main.dart` | App entry, provider setup, theme integration | Root |
| `theme.dart` | Material Design 3 base theme | Core |
| `notification_service.dart` | Notification scheduling & management | Service |
| `insights_service.dart` | **Phase 3** Smart pattern analysis | Service |
| `notification_preferences.dart` | Notification settings storage | Data |
| `theme_preferences.dart` | **Phase 3** Theme settings storage | Data |
| `meal_template_model.dart` | Meal template data structure | Data |
| `quote_model.dart` | **Phase 3** Quote data & service | Data |
| `theme_provider.dart` | **Phase 3** Dynamic theme management | State Management |
| `notification_settings_screen.dart` | Notification settings UI | Presentation |
| `theme_customization_screen.dart` | **Phase 3** Theme picker UI | Presentation |
| `meal_templates_screen.dart` | Template management UI | Presentation |
| `calendar_heatmap.dart` | **Phase 3** Activity visualization widget | Presentation |
| `celebration_animation.dart` | **Polish** Celebration & confetti effects | Presentation |
| `skeleton_loader.dart` | **Polish** Loading placeholder widgets | Presentation |
| `page_transitions.dart` | **Polish** Custom route transitions | Presentation |
| `*_screen.dart` | UI display | Presentation |
| `*_provider.dart` | State management | State Management |
| `*_repository.dart` | Data abstraction | Business Logic |
| `*_dao.dart` | Database operations | Data |
| `*_model.dart` | Data structures | Data |
| `progressly_database.dart` | Database setup (v2 schema) | Data |
| `preferences_manager.dart` | Settings storage | Data |

## 🎨 Widget Tree Example: TasksScreen

```
TasksScreen (StatefulWidget)
    └── Scaffold
        ├── AppBar
        │   └── Text("Tasks")
        └── Consumer<TaskProvider>
            └── Column
                ├── _buildHeader (Container)
                │   └── Row
                │       ├── Card (Completed)
                │       ├── Card (Total)
                │       └── Card (Streak)
                ├── _buildAddTask (Padding)
                │   └── Row
                │       ├── TextField
                │       └── IconButton
                └── ListView.builder
                    └── Card (for each task)
                        └── ListTile
                            ├── Checkbox
                            ├── Text (title)
                            └── IconButton (delete)
```

## 🚀 State Management Flow

```
Initial State (Provider Constructor)
    ↓
Provider registered in main.dart
    ↓
Screen uses Consumer<Provider>
    ↓
User interaction triggers action
    ↓
Provider method called
    ↓
Repository → DAO → Database
    ↓
Data updated in database
    ↓
Provider calls notifyListeners()
    ↓
Consumer rebuilds widget tree
    ↓
UI updated with new state
```

## 🎯 Best Practices Applied

### ✅ Separation of Concerns
- UI logic separate from business logic
- Data access abstracted from business logic
- Clear layer boundaries

### ✅ Single Responsibility
- Each class has one clear purpose
- Providers manage state only
- Repositories handle data only

### ✅ Dependency Injection
- Providers injected via MultiProvider
- PreferencesManager passed to providers
- Easy to test and mock

### ✅ Immutability
- Models are immutable
- Use copyWith() for updates
- State changes are explicit

### ✅ Type Safety
- Strict typing throughout
- No dynamic types
- Compile-time error detection

---

**This architecture ensures**:
- 📦 Easy to maintain
- 🧪 Easy to test
- 🔄 Easy to extend
- 📱 Cross-platform compatible
- 🎯 Clean and organized
