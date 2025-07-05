import 'package:demo_app/models/department.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:demo_app/services/app_url.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum DataStatus { Loading, Loaded, Error, Empty }

class DepartmentProvider with ChangeNotifier {
  DataStatus _dataStatus = DataStatus.Empty;
  List<Department> _departments = [];
  String _errorMessage = '';

  DataStatus get dataStatus => _dataStatus;
  List<Department> get departments => _departments;
  String get errorMessage => _errorMessage;

  DepartmentProvider() {
    fetchDepartments();
  }

  Future<Response> fetchDepartments() async {
    final url = Uri.parse(AppUrl.departments);
    final prefs = await SharedPreferences.getInstance();
    final String accessToken = prefs.getString('accessToken') ?? '';

    _dataStatus = DataStatus.Loading;
    notifyListeners();

    try {
      final Response response = await get(url, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          _departments = [];
          _dataStatus = DataStatus.Empty;
          _errorMessage = 'No departments found';
        } else {
          _departments = data.map((item) => Department.fromJson(item)).toList();
          _dataStatus = DataStatus.Loaded;
          _errorMessage =
              'Successfully loaded ${_departments.length} departments';
        }

        notifyListeners();
        return response;
      } else {
        _errorMessage = 'Failed to load departments: ${response.statusCode}';
        _dataStatus = DataStatus.Error;
        _departments = [];
        notifyListeners();
        return response;
      }
    } catch (e) {
      _errorMessage = 'Connection error: $e';
      _dataStatus = DataStatus.Error;
      _departments = [];
      notifyListeners();

      return Response('', 500);
    }
  }

  // Refresh data from API
  Future<void> refreshDepartments() async {
    await fetchDepartments();
  }

  // Get courses by department ID
  List<Course> getCoursesByDepartment(int departmentId) {
    try {
      Department? department =
          _departments.firstWhere((d) => d.id == departmentId);
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
