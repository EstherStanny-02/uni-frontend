import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Returns a database implementation for web platforms
Future<Database> getDatabaseForPlatform() async {
  // Use databaseFactoryFfiWeb for the web
  var factory = databaseFactoryFfiWeb;
  
  // Open a database with the factory
  final db = await factory.openDatabase(
    'university_courses_web.db',
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
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
      },
    ),
  );
  
  return db;
}