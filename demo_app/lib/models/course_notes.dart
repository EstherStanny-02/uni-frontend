class CourseNote {
  final int id;
  final String title;
  final int course;
  final String courseTitle;
  final String category;
  final String difficultyLevel;
  final String content;
  final String tags;
  final List<String> tagList;
  final bool isFeatured;
  final int order;
  final String chapter;
  final int estimatedReadTime;
  final int wordCount;
  final int createdBy;
  final String createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  CourseNote({
    required this.id,
    required this.title,
    required this.course,
    required this.courseTitle,
    required this.category,
    required this.difficultyLevel,
    required this.content,
    required this.tags,
    required this.tagList,
    required this.isFeatured,
    required this.order,
    required this.chapter,
    required this.estimatedReadTime,
    required this.wordCount,
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter for uploadedBy that returns a user object with display name
  User get uploadedBy => User(id: createdBy, name: createdByName);

  // Getter for uploadedAt that returns createdAt
  DateTime get uploadedAt => createdAt;

  factory CourseNote.fromJson(Map<String, dynamic> json) {
    return CourseNote(
      id: json['id'],
      title: json['title'],
      course: json['course'],
      courseTitle: json['course_title'],
      category: json['category'],
      difficultyLevel: json['difficulty_level'],
      content: json['content'],
      tags: json['tags'],
      tagList: List<String>.from(json['tag_list']),
      isFeatured: json['is_featured'],
      order: json['order'],
      chapter: json['chapter'],
      estimatedReadTime: json['estimated_read_time'],
      wordCount: json['word_count'],
      createdBy: json['created_by'],
      createdByName: json['created_by_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static List<CourseNote> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => CourseNote.fromJson(json)).toList();
  }
}

// Simple User class to handle the uploaded by information
class User {
  final int id;
  final String name;

  User({required this.id, required this.name});

  String getDisplayName() {
    return name.isEmpty ? 'Unknown User' : name;
  }
}
