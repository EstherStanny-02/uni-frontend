import 'package:demo_app/database/database_helper.dart';
import 'package:demo_app/models/department.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:demo_app/services/app_url.dart';

enum DataStatus {
  Loading,
  Loaded,
  Error,
  Empty
}

class DepartmentProvider with ChangeNotifier {
  DataStatus _dataStatus = DataStatus.Empty;
  List<Department> _departments = [];
  String _errorMessage = '';
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  DataStatus get dataStatus => _dataStatus;
  List<Department> get departments => _departments;
  String get errorMessage => _errorMessage;

  DepartmentProvider() {
    // Load data from local database on initialization
    loadDepartmentsFromDB();
  }

  // Load departments from local database
  Future<void> loadDepartmentsFromDB() async {
    _dataStatus = DataStatus.Loading;
    notifyListeners();

    try {
      final departments = await _databaseHelper.getDepartmentsWithCourses();
      
      if (departments.isEmpty) {
        // If database is empty, fetch from API
        await fetchDepartments();
      } else {
        _departments = departments;
        _dataStatus = DataStatus.Loaded;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error loading data from database: $e';
      _dataStatus = DataStatus.Error;
      notifyListeners();
    }
  }

  // Fetch departments from API
  Future<void> fetchDepartments() async {
    _dataStatus = DataStatus.Loading;
    notifyListeners();

    try {
      // Make API request
      Response response = await get(Uri.parse(AppUrl.departments));

      if (response.statusCode == 200) {
        final List<dynamic> departmentsJson = json.decode(response.body);
        
        // Clear existing data
        await _databaseHelper.clearDepartments();
        await _databaseHelper.clearCourses();
        
        // Parse departments and save to database
        for (var departmentJson in departmentsJson) {
          Department department = Department.fromJson(departmentJson);
          await _databaseHelper.insertDepartment(department);
          
          // Save courses
          for (var course in department.courses) {
            await _databaseHelper.insertCourse(course);
          }
        }
        
        // Reload from database to ensure consistency
        _departments = await _databaseHelper.getDepartmentsWithCourses();
        _dataStatus = DataStatus.Loaded;
      } else {
        _errorMessage = 'Failed to load departments: ${response.statusCode}';
        _dataStatus = DataStatus.Error;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _dataStatus = DataStatus.Error;
    }
    
    notifyListeners();
  }

  // Refresh data from API
  Future<void> refreshDepartments() async {
    await fetchDepartments();
  }

  // Get courses by department ID
  List<Course> getCoursesByDepartment(int departmentId) {
    try {
      Department? department = _departments.firstWhere((d) => d.id == departmentId);
      return department.courses;
    } catch (e) {
      return [];
    }
  }

  // Get department by name
  Department? getDepartmentByName(String name) {
    try {
      return _departments.firstWhere(
        (d) => d.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all courses across all departments
  List<Course> getAllCourses() {
    List<Course> allCourses = [];
    for (var department in _departments) {
      allCourses.addAll(department.courses);
    }
    return allCourses;
  }

  // Search courses by title or code
  List<Course> searchCourses(String query) {
    if (query.isEmpty) return getAllCourses();
    
    query = query.toLowerCase();
    return getAllCourses().where((course) {
      return course.title.toLowerCase().contains(query) || 
             course.courseCode.toLowerCase().contains(query);
    }).toList();
  }
}