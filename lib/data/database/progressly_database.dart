import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ProgresslyDatabase {
  static final ProgresslyDatabase instance = ProgresslyDatabase._init();
  static Database? _database;

  ProgresslyDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('progressly.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Incremented for task priority
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const intType = 'INTEGER NOT NULL';
    const textType = 'TEXT NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    // Tasks table
    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description TEXT,
        isCompleted $boolType,
        completedDate TEXT,
        createdDate $textType,
        category TEXT,
        priority INTEGER DEFAULT 0
      )
    ''');

    // Task streaks table
    await db.execute('''
      CREATE TABLE task_streaks (
        date TEXT PRIMARY KEY,
        currentStreak $intType,
        longestStreak $intType,
        weeklyStreak $intType
      )
    ''');

    // Meals table
    await db.execute('''
      CREATE TABLE meals (
        id $idType,
        name $textType,
        calories $intType,
        mealType TEXT,
        loggedDate $textType,
        time TEXT
      )
    ''');

    // Meal streaks table
    await db.execute('''
      CREATE TABLE meal_streaks (
        date TEXT PRIMARY KEY,
        currentStreak $intType,
        longestStreak $intType,
        weeklyStreak $intType
      )
    ''');

    // Water logs table
    await db.execute('''
      CREATE TABLE water_logs (
        id $idType,
        amount $intType,
        loggedDate $textType,
        time TEXT
      )
    ''');

    // Water streaks table
    await db.execute('''
      CREATE TABLE water_streaks (
        date TEXT PRIMARY KEY,
        currentStreak $intType,
        longestStreak $intType,
        weeklyStreak $intType,
        dailyGoal $intType
      )
    ''');

    // Habits table
    await db.execute('''
      CREATE TABLE habits (
        id $idType,
        name $textType,
        description TEXT,
        frequency TEXT,
        createdDate $textType,
        category TEXT
      )
    ''');

    // Habit logs table
    await db.execute('''
      CREATE TABLE habit_logs (
        id $idType,
        habitId $intType,
        completedDate $textType,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Habit streaks table
    await db.execute('''
      CREATE TABLE habit_streaks (
        habitId INTEGER PRIMARY KEY,
        currentStreak $intType,
        longestStreak $intType,
        weeklyStreak $intType,
        lastCompletedDate TEXT,
        FOREIGN KEY (habitId) REFERENCES habits (id) ON DELETE CASCADE
      )
    ''');

    // Meal templates table
    await db.execute('''
      CREATE TABLE meal_templates (
        id $idType,
        name $textType,
        calories $intType,
        mealType TEXT,
        isFavorite $boolType,
        timesLogged $intType,
        createdAt $textType
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add meal templates table for existing databases
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const intType = 'INTEGER NOT NULL';
      const textType = 'TEXT NOT NULL';
      const boolType = 'INTEGER NOT NULL';

      await db.execute('''
        CREATE TABLE meal_templates (
          id $idType,
          name $textType,
          calories $intType,
          mealType TEXT,
          isFavorite $boolType,
          timesLogged $intType,
          createdAt $textType
        )
      ''');
    }

    if (oldVersion < 3) {
      // Add priority column to tasks table
      await db.execute('''
        ALTER TABLE tasks ADD COLUMN priority INTEGER DEFAULT 0
      ''');
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
