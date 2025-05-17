import 'package:demo_app/models/department.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:demo_app/database/database_config.dart'; 
import 'package:path/path.dart';

class DatabaseHelper {
 static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    if (kIsWeb) {
      // sqflite is not supported on web; throw or handle accordingly
      throw UnsupportedError('Database is not supported on web.');
    } else {
      // Initialize database factory for non-web platforms
      initializeDatabaseFactory();
      _database = await _initDatabase();
    }
    
    return _database!;
  }



  // Department operations remain the same
  // Course operations remain the same
  // ... rest of your methods ...

  // Sample method shown below, others will be similar:
  // Future<int> insertDepartment(Department department) async {
  //   Database db = await database;
  //   return await db.insert(
  //     'departments',
  //     department.toMap(),
  //     conflictAlgorithm: ConflictAlgorithm.replace,
  //   );
  // }

  // Duplicate 'database' getter removed to avoid naming conflict.

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'university_courses.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Create departments table
    await db.execute('''
      CREATE TABLE departments(
        id INTEGER PRIMARY KEY,
        name TEXT,
        code TEXT,
        description TEXT,
        logo TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Create courses table
    await db.execute('''
      CREATE TABLE courses(
        id INTEGER PRIMARY KEY,
        title TEXT,
        course_code TEXT,
        department INTEGER,
        department_name TEXT,
        description TEXT,
        icon_name TEXT,
        color_code TEXT,
        documents TEXT,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (department) REFERENCES departments (id)
      )
    ''');
  }

  // Department operations
  Future<int> insertDepartment(Department department) async {
    Database db = await database;
    return await db.insert(
      'departments',
      department.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Department>> getDepartments() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('departments');
    
    return List.generate(maps.length, (i) {
      return Department.fromMap(maps[i]);
    });
  }

  Future<Department?> getDepartment(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Department.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteDepartment(int id) async {
    Database db = await database;
    await db.delete(
      'departments',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearDepartments() async {
    Database db = await database;
    await db.delete('departments');
  }

  // Course operations
  Future<int> insertCourse(Course course) async {
    Database db = await database;
    return await db.insert(
      'courses',
      course.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Course>> getCourses() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query('courses');
    
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<List<Course>> getCoursesByDepartment(int departmentId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'department = ?',
      whereArgs: [departmentId],
    );
    
    return List.generate(maps.length, (i) {
      return Course.fromMap(maps[i]);
    });
  }

  Future<Course?> getCourse(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Course.fromMap(maps.first);
    }
    return null;
  }

  Future<void> deleteCourse(int id) async {
    Database db = await database;
    await db.delete(
      'courses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearCourses() async {
    Database db = await database;
    await db.delete('courses');
  }

  // Get departments with their courses
  Future<List<Department>> getDepartmentsWithCourses() async {
    List<Department> departments = await getDepartments();
    
    for (var i = 0; i < departments.length; i++) {
      List<Course> courses = await getCoursesByDepartment(departments[i].id);
      departments[i] = Department(
        id: departments[i].id,
        name: departments[i].name,
        code: departments[i].code,
        description: departments[i].description,
        logo: departments[i].logo,
        courses: courses,
        createdAt: departments[i].createdAt,
        updatedAt: departments[i].updatedAt,
      );
    }
    
    return departments;
  }
}