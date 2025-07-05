import 'package:demo_app/models/course_modal.dart';

class Department {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? logo;
  final List<Course> courses;
  final String createdAt;
  final String updatedAt;

  Department({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.logo,
    required this.courses,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    List<Course> coursesList = [];
    if (json['courses'] != null) {
      coursesList = List<Course>.from(
        json['courses'].map((course) => Course.fromJson(course)),
      );
    }

    return Department(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      logo: json['logo'],
      courses: coursesList,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'logo': logo,
      'courses': courses.map((course) => course.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
