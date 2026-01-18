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

## 🔊 Sound & Haptic Feedback System

### SoundService (`services/sound_service.dart`)

**Audio System**:
- System sounds (no asset files required)
- iOS/Android platform-specific sounds
- 10+ different sound effects for various actions

**Haptic Feedback**:
- Light impact: Button taps, selections
- Medium impact: Task completion, habit completion
- Heavy impact: Streak milestones, record breaking
- Selection feedback: Swipe gestures

**Sound Effects**:
```dart
playTaskComplete()      // ✅ Task checked off
playTaskDelete()        // ❌ Task deleted
playHabitComplete()     // 🎯 Habit marked done
playWaterLog()          // 💧 Water logged
playMealLog()           // 🍽️ Meal logged
playStreakMilestone()   // 🔥 Streak achievement
playRecordBroken()      // 🏆 Personal record broken
playButtonTap()         // 📱 UI interaction
playError()             // ⚠️ Error occurred
playGenericSuccess()    // ✨ Generic success
```

**Preferences**:
- Sound effects toggle (enable/disable)
- Haptic feedback toggle (independent control)
- Persisted in SharedPreferences

## 🏆 Personal Records System

### PersonalRecordsService (`services/personal_records_service.dart`)

**Record Categories**:
1. **Most Tasks Completed** (single day)
2. **Most Water Consumed** (ml in single day)
3. **Most Meals Logged** (single day)
4. **Most Habits Completed** (single day)
5. **Longest Streak** (consecutive active days)

**Auto-Tracking**:
- Automatically checks after each action
- Compares current performance to stored records
- Updates and persists new records
- Triggers celebration sound on record break

**Data Model** (`data/models/personal_record.dart`):
```dart
class PersonalRecord {
  final String category;     // e.g., 'tasks', 'water'
  final double value;        // Numeric achievement
  final DateTime achievedAt; // When record was set
  final String unit;         // 'count', 'ml', 'days'
}
```

**UI** (`ui/screens/personal_records_screen.dart`):
- Trophy icon displays for each category
- Shows record value and achievement date
- Color-coded cards
- "Clear All Records" option

## ⚖️ Unit Preferences System

### UnitPreferencesProvider (`providers/unit_preferences_provider.dart`)

**Supported Units**:
1. **Water Units**:
   - Milliliters (ml) - default
   - Fluid Ounces (oz) - 1 ml = 0.033814 oz
   - Cups (cups) - 1 ml = 0.00422675 cups

2. **Weight Units**:
   - Kilograms (kg) - default
   - Pounds (lbs) - 1 kg = 2.20462 lbs

**Conversion Logic**:
```dart
// Water conversions
ml → oz:   value * 0.033814
ml → cups: value * 0.00422675

// Weight conversions
kg → lbs:  value * 2.20462
```

**Integration**:
- Auto-converts throughout app
- Display formatted with unit labels
- Settings screen for user selection
- Persisted in SharedPreferences

## ✨ Advanced Gesture System

### Gesture Widgets (`ui/widgets/gesture_widgets.dart`)

**1. SwipeToDismissWidget**:
- Swipe left to reveal delete action
- Confirmation dialog before deletion
- Haptic feedback on swipe
- Smooth animation

**2. LongPressMenuWidget**:
- Hold item for 500ms to show menu
- Context-aware actions
- Haptic feedback on activation
- Quick access to common actions

**3. DraggableListItem**:
- Hold and drag to reorder
- Visual elevation on drag
- Haptic feedback on pickup/drop
- Smooth reordering animation

**Usage Pattern**:
```dart
// Swipe to delete
SwipeToDismissWidget(
  onDelete: () => deleteItem(),
  child: ListTile(...),
)

// Long press menu
LongPressMenuWidget(
  menuItems: [
    MenuAction(title: 'Edit', onTap: edit),
    MenuAction(title: 'Delete', onTap: delete),
  ],
  child: Card(...),
)

// Drag to reorder
DraggableListItem(
  onReorder: (oldIndex, newIndex) => reorderList(),
  child: ListTile(...),
)
```

## 🎯 Task Priority System

### Database Schema (v3)
**tasks table**:
```sql
CREATE TABLE tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  description TEXT,
  date TEXT NOT NULL,
  isCompleted INTEGER NOT NULL DEFAULT 0,
  priority INTEGER NOT NULL DEFAULT 0  -- NEW in v3
)
```

**Priority Levels**:
- `0` = Low Priority (🟢 Green)
- `1` = Medium Priority (🟠 Orange)
- `2` = High Priority (🔴 Red)

**Migration from v2 to v3**:
```dart
await db.execute('ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0');
```

### EnhancedTasksScreen
**Features**:
1. **Visual Indicators**:
   - Color-coded left border (4px thick)
   - Priority badge with icon
   - Border color matches priority

2. **Sorting Logic**:
   ```dart
   // Sort by completion status first
   if (a.isCompleted != b.isCompleted) {
     return a.isCompleted ? 1 : -1;
   }
   // Then by priority (high to low)
   return b.priority.compareTo(a.priority);
   ```

3. **Gesture Integration**:
   - **Drag-to-Reorder**: Hold and drag tasks
   - **Long-Press Menu**: Quick priority changes
   - **Swipe-to-Delete**: Delete with confirmation

4. **Priority Actions**:
   - Set Low/Medium/High via long-press menu
   - Drag to manually reorder
   - Auto-sort on completion toggle

### TaskProvider Updates
**New Methods**:
- `addTaskModel(TaskModel)` - Add task with priority
- `updateTask(TaskModel)` - Update existing task
- `toggleTaskCompletion(id)` - Toggle and re-sort

**TaskModel Extended**:
```dart
class TaskModel {
  final int? id;
  final String title;
  final String? description;
  final String date;
  final bool isCompleted;
  final int priority;  // NEW: 0, 1, or 2
  
  TaskModel copyWith({int? priority, ...}) { ... }
}
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

## 👤 Profile Management & Avatar System

### EditProfileScreen (`ui/screens/edit_profile_screen.dart`)

**Form Sections**:
1. **Avatar Management**:
   - Upload from camera or gallery
   - Image optimization (512×512, 85% quality)
   - Remove photo option
   - Default avatar fallback

2. **Personal Information**:
   - Name (required)
   - Email (optional)
   - Age (1-120 years)

3. **Health Information**:
   - Weight (with unit conversion)
   - Height (cm, optional)

4. **Goals**:
   - Goal description text

**Image Picker Integration**:
```dart
// Dependencies
image_picker: ^1.1.2
path_provider: ^2.1.4

// Image sources
- Camera: ImageSource.camera
- Gallery: ImageSource.gallery

// Optimization
- Max dimensions: 512×512
- Compression: 85%
- Format: JPEG
```

**Data Flow**:
```
User taps avatar → Show source dialog (Camera/Gallery)
    ↓
ImagePicker picks image
    ↓
Image optimized (resize + compress)
    ↓
Save to app documents directory
    ↓
Update ProfileProvider with file path
    ↓
Persist path in SharedPreferences
    ↓
Display File-based image in UI
```

### UserProfile Model Extended
**New Fields**:
```dart
class UserProfile {
  final String name;
  final int age;
  final String gender;
  final double weight;
  final bool notificationsEnabled;
  final String? email;           // NEW
  final double? height;          // NEW (cm)
  final String? goal;            // NEW
  final String? avatarPath;      // NEW (file path)
}
```

**ProfileProvider Updates**:
- `updateProfileFields()` - Updates all profile data including avatar
- `avatarPath` getter - Returns current avatar file path
- `loadProfile()` - Loads avatar path from SharedPreferences

**Avatar Display**:
- ProfileScreen: CircleAvatar with File image or default icon
- EditProfileScreen: Large preview with camera/gallery/remove actions
- Fallback: Person icon when no avatar set

## ⚙️ Settings Hub

### SettingsScreen (`ui/screens/settings_screen.dart`)

**Settings Categories**:

1. **Unit Preferences**:
   - Water Units: ml, oz, cups
   - Weight Units: kg, lbs
   - Visual selection with icons

2. **Sound & Haptics**:
   - Sound Effects toggle
   - Haptic Feedback toggle
   - Independent on/off controls

3. **About**:
   - App name: Progressly
   - Version: 1.0.0
   - Description

**UI Design**:
- Icon-based selection (radio_button_checked/unchecked)
- Color-coded sections
- ListTile format with trailing switches
- Immediate save on change

**Navigation**:
- Accessible from ProfileScreen
- Material 3 styling
- Settings icon in app bar

---

## 🔄 Data Flow Example: Adding a Task with Priority

```
User taps "Add Task" button
         ↓
EnhancedTasksScreen shows task form with priority selection
         ↓
User enters task details + selects priority (Low/Medium/High)
         ↓
TaskProvider.addTaskModel(TaskModel) validates input
         ↓
TaskRepository.addTask() abstracts storage
         ↓
TaskDao.insertTask() executes SQL INSERT with priority
         ↓
SQLite Database (v3) stores task with priority column
         ↓
TaskProvider.loadTasks() refreshes and sorts by priority
         ↓
notifyListeners() triggers UI rebuild
         ↓
Consumer rebuilds EnhancedTasksScreen
         ↓
User sees task with color-coded priority indicator
         ↓
User can drag to reorder or long-press to change priority
```
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
| `sound_service.dart` | **Phase 4** Sound effects & haptic feedback | Service |
| `personal_records_service.dart` | **Phase 4** Auto-track achievements | Service |
| `notification_preferences.dart` | Notification settings storage | Data |
| `theme_preferences.dart` | **Phase 3** Theme settings storage | Data |
| `meal_template_model.dart` | Meal template data structure | Data |
| `quote_model.dart` | **Phase 3** Quote data & service | Data |
| `personal_record.dart` | **Phase 4** Record data structure | Data |
| `unit_preference.dart` | **Phase 4** Unit enums & model | Data |
| `theme_provider.dart` | **Phase 3** Dynamic theme management | State Management |
| `unit_preferences_provider.dart` | **Phase 4** Unit conversion state | State Management |
| `notification_settings_screen.dart` | Notification settings UI | Presentation |
| `theme_customization_screen.dart` | **Phase 3** Theme picker UI | Presentation |
| `meal_templates_screen.dart` | Template management UI | Presentation |
| `enhanced_tasks_screen.dart` | **Phase 4** Tasks with priority & gestures | Presentation |
| `personal_records_screen.dart` | **Phase 4** Achievement display UI | Presentation |
| `edit_profile_screen.dart` | **Phase 4** Profile editor with avatar | Presentation |
| `settings_screen.dart` | **Phase 4** Settings hub | Presentation |
| `calendar_heatmap.dart` | **Phase 3** Activity visualization widget | Presentation |
| `celebration_animation.dart` | **Polish** Celebration & confetti effects | Presentation |
| `skeleton_loader.dart` | **Polish** Loading placeholder widgets | Presentation |
| `page_transitions.dart` | **Polish** Custom route transitions | Presentation |
| `gesture_widgets.dart` | **Phase 4** Swipe, long-press, drag widgets | Presentation |
| `*_screen.dart` | UI display | Presentation |
| `*_provider.dart` | State management | State Management |
| `*_repository.dart` | Data abstraction | Business Logic |
| `*_dao.dart` | Database operations | Data |
| `*_model.dart` | Data structures | Data |
| `progressly_database.dart` | Database setup (v3 schema with priority) | Data |
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
