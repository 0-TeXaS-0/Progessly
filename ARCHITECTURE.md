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
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                    BUSINESS LOGIC LAYER                 │
│  ┌──────────────────────────────────────────────────┐  │
│  │  TaskRepository  MealRepository  WaterRepository │  │
│  │  (Data access abstraction)                        │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────┐
│                      DATA LAYER                         │
│  ┌────────────────┐              ┌─────────────────┐   │
│  │   DAOs         │              │  Preferences    │   │
│  │  (Database     │              │  Manager        │   │
│  │   Access)      │              │  (Settings)     │   │
│  └────────────────┘              └─────────────────┘   │
│         ↓                                ↓              │
│  ┌────────────────┐              ┌─────────────────┐   │
│  │  SQLite DB     │              │ SharedPrefs     │   │
│  │  (progressly.db)│              │ (user settings) │   │
│  └────────────────┘              └─────────────────┘   │
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

## 🔄 Data Flow Example: Adding a Task

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
| `main.dart` | App entry, provider setup | Root |
| `theme.dart` | Material Design 3 theme | Core |
| `*_screen.dart` | UI display | Presentation |
| `*_provider.dart` | State management | State Management |
| `*_repository.dart` | Data abstraction | Business Logic |
| `*_dao.dart` | Database operations | Data |
| `*_model.dart` | Data structures | Data |
| `progressly_database.dart` | Database setup | Data |
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
