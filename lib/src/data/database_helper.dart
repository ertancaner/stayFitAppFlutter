import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stay_fit/src/features/home/domain/weight_entry.dart';
// Yeni domain dosyasını import et
import 'package:stay_fit/src/features/workout_tracker/domain/exercise.dart';

class DatabaseHelper {
  static const _databaseName = "StayFit.db";
  // Veritabanı versiyonunu artıralım, çünkü şema değişiyor.
  static const _databaseVersion = 4; // Versiyon 4'e yükseltildi

  // Tartım Tablosu (Değişiklik yok)
  static const tableWeightEntries = 'weight_entries';
  static const columnId = 'id'; // Ortak ID sütunu adı
  static const columnWeight = 'weight';
  static const columnDate = 'date'; // Tartım tarihi (Milisaniye)

  // Yeni Antrenman Takip Tabloları
  static const tableWorkoutLogs = 'workout_logs';
  static const columnLogId = 'id'; // Otomatik artan
  static const columnLogDate = 'date'; // Antrenman tarihi (ISO8601 String)
  static const columnLogTitle = 'title'; // Antrenman gününün başlığı/kategorisi

  static const tableLoggedExercises = 'logged_exercises';
  static const columnLoggedExerciseId = 'id'; // Otomatik artan
  static const columnLERefLogId =
      'workout_log_id'; // workout_logs'a foreign key
  static const columnLEExerciseName = 'exercise_name'; // Egzersiz adı
  static const columnLECategory = 'category'; // Egzersiz kategorisi

  static const tableLoggedSets = 'logged_sets';
  static const columnSetId = 'id'; // Otomatik artan
  static const columnSetRefLoggedExerciseId =
      'logged_exercise_id'; // logged_exercises'e foreign key
  static const columnSetReps = 'reps';
  static const columnSetWeight = 'weight';
  static const columnSetRestTime = 'rest_time_seconds';

  // Singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Tartım tablosu
    await db.execute('''
          CREATE TABLE $tableWeightEntries (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnWeight REAL NOT NULL,
            $columnDate INTEGER NOT NULL
          )
          ''');

    // Yeni Antrenman Takip Tabloları
    await _createWorkoutTables(db);
  }

  // Veritabanı versiyonu yükseltildiğinde çalışır
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Önceki versiyonlardan gelen yükseltmeleri yönet
    if (oldVersion < 2) {
      // Versiyon 1'den 2'ye: Eski egzersiz tablolarını ekle (artık kullanılmayacak ama geçiş için)
      try {
        await db.execute('''
              CREATE TABLE exercises (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL,
                category TEXT,
                date INTEGER NOT NULL
              )
              ''');
        await db.execute('''
              CREATE TABLE exercise_sets (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                exercise_id INTEGER NOT NULL,
                reps INTEGER NOT NULL,
                weight REAL NOT NULL,
                rest_time_seconds INTEGER DEFAULT 0,
                FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
              )
              ''');
      } catch (e) {
        // print("Error creating old exercise tables during upgrade: $e");
      }
    }
    if (oldVersion < 3) {
      // Versiyon 2'den 3'e: Yeni antrenman takip tablolarını ekle
      // Eski egzersiz tablolarını silmek isteyebiliriz (opsiyonel, veri kaybı olabilir)
      // await db.execute('DROP TABLE IF EXISTS $tableExerciseSets');
      // await db.execute('DROP TABLE IF EXISTS $tableExercises');
      await _createWorkoutTables(db);
    }
    if (oldVersion < 4) {
      // Versiyon 3'ten 4'e: workout_logs tablosuna title sütununu ekle
      try {
        await db.execute(
          'ALTER TABLE $tableWorkoutLogs ADD COLUMN $columnLogTitle TEXT',
        );
      } catch (e) {
        // print("Error adding title column to workout_logs during upgrade: $e");
      }
    }
  }

  // Yeni antrenman takip tablolarını oluşturan yardımcı metod
  Future<void> _createWorkoutTables(Database db) async {
    await db.execute('''
          CREATE TABLE $tableWorkoutLogs (
            $columnLogId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnLogDate TEXT NOT NULL,
            $columnLogTitle TEXT
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableLoggedExercises (
            $columnLoggedExerciseId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnLERefLogId INTEGER NOT NULL,
            $columnLEExerciseName TEXT NOT NULL,
            $columnLECategory TEXT,
            FOREIGN KEY ($columnLERefLogId) REFERENCES $tableWorkoutLogs ($columnLogId) ON DELETE CASCADE
          )
          ''');

    await db.execute('''
          CREATE TABLE $tableLoggedSets (
            $columnSetId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnSetRefLoggedExerciseId INTEGER NOT NULL,
            $columnSetReps INTEGER NOT NULL,
            $columnSetWeight REAL NOT NULL,
            $columnSetRestTime INTEGER DEFAULT 0,
            FOREIGN KEY ($columnSetRefLoggedExerciseId) REFERENCES $tableLoggedExercises ($columnLoggedExerciseId) ON DELETE CASCADE
          )
          ''');
  }

  // --- Tartım CRUD (Değişiklik Yok) ---
  Future<int> insertWeightEntry(WeightEntry entry) async {
    Database db = await instance.database;
    return await db.insert(tableWeightEntries, entry.toJson());
  }

  Future<List<WeightEntry>> getAllWeightEntries() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableWeightEntries,
      orderBy: '$columnDate DESC',
    );
    if (maps.isEmpty) return [];
    return List.generate(maps.length, (i) => WeightEntry.fromJson(maps[i]));
  }

  Future<int> updateWeightEntry(WeightEntry entry) async {
    Database db = await instance.database;
    return await db.update(
      tableWeightEntries,
      entry.toJson(),
      where: '$columnId = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteWeightEntry(int id) async {
    Database db = await instance.database;
    return await db.delete(
      tableWeightEntries,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
  // --- Tartım CRUD Sonu ---

  // --- Yeni Antrenman Takip CRUD ---

  // Yeni bir antrenman günlüğü (WorkoutLog) ekler ve ID'sini döndürür
  Future<int> insertWorkoutLog(WorkoutLog log) async {
    final db = await instance.database;
    // Firestore'a geçişte bu metodun ID dönüş tipi String olmalı veya hiç ID döndürmemeli.
    // Şimdilik SQLite uyumluluğu için int bırakıyoruz ama Firestore'da bu farklı işleyecek.
    return await db.insert(tableWorkoutLogs, log.toJson());
  }

  // Bir antrenman günlüğüne kaydedilmiş egzersiz (LoggedExercise) ekler ve ID'sini döndürür
  Future<int> insertLoggedExercise(LoggedExercise exercise) async {
    final db = await instance.database;
    return await db.insert(tableLoggedExercises, exercise.toJson());
  }

  // Bir kaydedilmiş egzersize set (LoggedSet) ekler ve ID'sini döndürür
  Future<int> insertLoggedSet(LoggedSet set) async {
    final db = await instance.database;
    return await db.insert(tableLoggedSets, set.toJson());
  }

  // Tüm antrenman günlüklerini (egzersizleri ve setleriyle birlikte) getirir
  Future<List<WorkoutLog>> getAllWorkoutLogs() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> logMaps = await db.query(
      tableWorkoutLogs,
      orderBy: '$columnLogDate DESC', // En son antrenmanlar önce
    );

    List<WorkoutLog> logs = [];
    for (Map<String, dynamic> logMap in logMaps) {
      // SQLite'da ID'ler int olarak kalacak, Firestore'a geçerken String olacak.
      // Bu katmanda SQLite ID'lerini kullanıyoruz.
      final int logIdAsInt = logMap[columnLogId] as int;
      final String logId = logIdAsInt.toString(); // Firestore uyumu için String'e çeviriyoruz

      final List<Map<String, dynamic>> exerciseMaps = await db.query(
        tableLoggedExercises,
        where: '$columnLERefLogId = ?',
        // SQLite'da workout_log_id int olduğu için logIdAsInt kullanıyoruz.
        whereArgs: [logIdAsInt],
      );

      List<LoggedExercise> loggedExercises = [];
      for (Map<String, dynamic> exerciseMap in exerciseMaps) {
        final int loggedExerciseIdAsInt = exerciseMap[columnLoggedExerciseId] as int;
        final String loggedExerciseId = loggedExerciseIdAsInt.toString();

        final List<Map<String, dynamic>> setMaps = await db.query(
          tableLoggedSets,
          where: '$columnSetRefLoggedExerciseId = ?',
          whereArgs: [loggedExerciseIdAsInt],
          orderBy: '$columnSetId ASC',
        );
        List<LoggedSet> sets = setMaps
            .map((setMap) => LoggedSet.fromJson(setMap, id: (setMap[columnSetId] as int).toString()))
            .toList();

        loggedExercises.add(LoggedExercise.fromJson(exerciseMap, id: loggedExerciseId, sets: sets));
      }
      logs.add(WorkoutLog.fromJson(logMap, id: logId, loggedExercises: loggedExercises));
    }
    return logs;
  }

  // Belirli bir antrenman günlüğünü siler (ilişkili egzersizler ve setler CASCADE ile silinir)
  Future<int> deleteWorkoutLog(String logId) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    // SQLite'da ID int olduğu için parse ediyoruz.
    return await db.delete(
      tableWorkoutLogs,
      where: '$columnLogId = ?',
      whereArgs: [int.tryParse(logId) ?? -1], // Hata durumunda geçersiz ID
    );
  }

  // Belirli bir kaydedilmiş egzersizi siler (ilişkili setler CASCADE ile silinir)
  Future<int> deleteLoggedExercise(String loggedExerciseId) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    return await db.delete(
      tableLoggedExercises,
      where: '$columnLoggedExerciseId = ?',
      whereArgs: [int.tryParse(loggedExerciseId) ?? -1],
    );
  }

  // Belirli bir seti siler
  Future<int> deleteLoggedSet(String setId) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    return await db.delete(
      tableLoggedSets,
      where: '$columnSetId = ?',
      whereArgs: [int.tryParse(setId) ?? -1],
    );
  }

  // Belirli bir WorkoutLog'u ID ile getirir (egzersizler ve setler olmadan)
  Future<WorkoutLog?> getWorkoutLogById(String id) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableWorkoutLogs,
      where: '$columnLogId = ?',
      whereArgs: [int.tryParse(id) ?? -1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return WorkoutLog.fromJson(maps.first, id: id, loggedExercises: []);
    }
    return null;
  }

  // Belirli bir LoggedExercise'ı ID ile getirir (setler olmadan)
  Future<LoggedExercise?> getLoggedExerciseById(String id) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableLoggedExercises,
      where: '$columnLoggedExerciseId = ?',
      whereArgs: [int.tryParse(id) ?? -1],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return LoggedExercise.fromJson(maps.first, id: id, sets: []);
    }
    return null;
  }

  // Belirli bir WorkoutLog ID'sine ait tüm LoggedExercise'ları getirir (setler olmadan)
  Future<List<LoggedExercise>> getLoggedExercisesForLog(String logId) async { // ID tipi String olarak güncellendi
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableLoggedExercises,
      where: '$columnLERefLogId = ?',
      whereArgs: [int.tryParse(logId) ?? -1],
    );
    if (maps.isNotEmpty) {
      return maps
          .map((map) => LoggedExercise.fromJson(map, id: (map[columnLoggedExerciseId] as int).toString(), sets: []))
          .toList();
    }
    return [];
  }

  // --- Güncelleme Metodları (Gerektiğinde eklenecek) ---
  Future<int> updateWorkoutLog(WorkoutLog log) async {
    final db = await instance.database;
    return await db.update(
      tableWorkoutLogs,
      log.toJson(),
      where: '$columnLogId = ?',
      whereArgs: [int.tryParse(log.id ?? "-1") ?? -1],
    );
  }
  // Future<int> updateLoggedExercise(LoggedExercise exercise) async { ... }
  // Future<int> updateLoggedSet(LoggedSet set) async { ... }

  // --- Eski Egzersiz CRUD Metodları (Kaldırıldı) ---
  /*
  Future<int> insertExercise(Exercise exercise) async { ... }
  Future<List<Exercise>> getAllExercises() async { ... }
  Future<int> updateExercise(Exercise exercise) async { ... }
  Future<int> deleteExercise(int id) async { ... }
  */
}
