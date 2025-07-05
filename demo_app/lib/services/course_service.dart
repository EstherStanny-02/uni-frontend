import 'dart:convert';
import 'package:demo_app/models/course_document.dart';
import 'package:demo_app/models/course_notes.dart';
import 'package:demo_app/models/department.dart';
import 'package:demo_app/services/app_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CourseDetailsService {
  // Get all courses
  Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse(AppUrl.courses),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Course.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load courses: $e');
    }
  }

  // Get a specific course by ID
  Future<Course> getCourseById(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String accessToken = prefs.getString('accessToken') ?? '';
      final response = await http.get(
        Uri.parse('${AppUrl.courses}$id/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return Course.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load course details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course details: $e');
    }
  }

  // Get courses by department
  Future<List<Course>> getCoursesByDepartment(int departmentId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppUrl.departments}$departmentId/courses/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Course.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load department courses. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load department courses: $e');
    }
  }

  Future<List<CourseDocument>> getDocumentsByCourse(
      {required int courseId}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppUrl.documents}?course=$courseId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => CourseDocument.fromJson(data)).toList();
      } else {
        throw Exception(
            'Failed to load course documents. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course documents: $e');
    }
  }

  Future<List<CourseNote>> getNotesByCourse({required int courseId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String accessToken = prefs.getString('accessToken') ?? '';
      final response = await http.get(
        Uri.parse('${AppUrl.notes}?course=$courseId'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return CourseNote.listFromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load course notes. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load course notes: $e');
    }
  }
}
