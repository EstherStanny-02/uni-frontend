import 'dart:convert';

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

class Course {
  final int id;
  final String title;
  final String courseCode;
  final int department;
  final String departmentName;
  final String? description;
  final String iconName;
  final String colorCode;
  final List<dynamic> documents;
  final String createdAt;
  final String updatedAt;

  Course({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.department,
    required this.departmentName,
    this.description,
    required this.iconName,
    required this.colorCode,
    required this.documents,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      title: json['title'],
      // FIXED: Changed from 'course_code' to 'module_code' to match API
      courseCode: json['module_code'],
      department: json['department'],
      departmentName: json['department_name'],
      description: json['description'],
      iconName: json['icon_name'],
      colorCode: json['color_code'],
      documents: json['documents'] ?? [],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'module_code': courseCode,
      'department': department,
      'department_name': departmentName,
      'description': description,
      'icon_name': iconName,
      'color_code': colorCode,
      'documents': documents,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
