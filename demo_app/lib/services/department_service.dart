import 'dart:convert';
import 'package:demo_app/services/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:demo_app/models/department.dart';
import 'package:demo_app/database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  
  // Fetch departments from API
  Future<List<Department>> fetchDepartments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get the access token - use consistent key naming
      final String accessToken = prefs.getString('access_token') ?? '';
      
      // Debug print with the correct key name
      print('Access token: $accessToken ============>');
      
      final response = await http.get(
        Uri.parse(AppUrl.departments),
        headers: {
          // Add 'Bearer' prefix if your API requires it, or use the correct format
          'Authorization': '$accessToken',
        },
      );
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print('Data received: $data');
        
        List<Department> departments = [];
        
        // Clear existing departments and courses in local database
        await _dbHelper.clearDepartments();
        await _dbHelper.clearCourses();
        
        // Process each department
        for (var item in data) {
          try {
            Department department = Department.fromJson(item);
            departments.add(department);
            
            // Insert department into local database
            await _dbHelper.insertDepartment(department);
            
            // Insert each course into local database
            for (var course in department.courses) {
              await _dbHelper.insertCourse(course);
            }
          } catch (e) {
            print('Error processing department: $e');
            // Continue processing other departments even if one fails
          }
        }
        
        if (departments.isEmpty) {
          print('No departments were processed successfully');
        } else {
          print('Successfully processed ${departments.length} departments');
        }
        
        return departments;
      } else {
        print('Server error: ${response.statusCode} - ${response.body}');
        // If server returns error, try to load from local database
        return await _getLocalDepartments();
      }
    } catch (e) {
      print('Exception in fetchDepartments: $e');
      // If there's a network error, load from local database
      return await _getLocalDepartments();
    }
  }
  
  // Get departments from local database
  Future<List<Department>> _getLocalDepartments() async {
    try {
      final departments = await _dbHelper.getDepartmentsWithCourses();
      print('Loaded ${departments.length} departments from local database');
      return departments;
    } catch (e) {
      print('Error loading from local database: $e');
      return [];
    }
  }
  
  // Get all departments with their courses from database
  Future<List<Department>> getDepartments() async {
    List<Department> departments = await _dbHelper.getDepartmentsWithCourses();
    
    if (departments.isEmpty) {
      // If database is empty, fetch from API
      return await fetchDepartments();
    }
    
    return departments;
  }
  
  // Get courses by department
  Future<List<Course>> getCoursesByDepartment(int departmentId) async {
    return await _dbHelper.getCoursesByDepartment(departmentId);
  }
  
  // Get all courses
  Future<List<Course>> getAllCourses() async {
    return await _dbHelper.getCourses();
  }
}