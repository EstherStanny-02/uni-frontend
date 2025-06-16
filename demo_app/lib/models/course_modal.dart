
class Course {
  final int id;
  final String title;
  final String courseCode;
  final int department;
  final String departmentName;
  final String? description;
  final String iconName;
  final String colorCode;
  final List<Map<String, dynamic>> documents;
  final DateTime createdAt;
  final DateTime updatedAt;

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
      courseCode: json['course_code'],
      department: json['department'],
      departmentName: json['department_name'],
      description: json['description'],
      iconName: json['icon_name'],
      colorCode: json['color_code'],
      documents: List<Map<String, dynamic>>.from(json['documents'] ?? []),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_code': courseCode,
      'department': department,
      'department_name': departmentName,
      'description': description,
      'icon_name': iconName,
      'color_code': colorCode,
      'documents': documents,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}