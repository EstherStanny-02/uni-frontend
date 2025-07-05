class CourseDocument {
  final int id;
  final String title;
  final String documentType;
  final String file;
  final String description;
  final UploadedBy uploadedBy;
  final DateTime uploadedAt;
  final DateTime updatedAt;

  CourseDocument({
    required this.id,
    required this.title,
    required this.documentType,
    required this.file,
    required this.description,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.updatedAt,
  });

  factory CourseDocument.fromJson(Map<String, dynamic> json) {
    return CourseDocument(
      id: json['id'],
      title: json['title'],
      documentType: json['document_type'],
      file: json['file'],
      description: json['description'] ?? '',
      uploadedBy: UploadedBy.fromJson(json['uploaded_by']),
      uploadedAt: DateTime.parse(json['uploaded_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document_type': documentType,
      'file': file,
      'description': description,
      'uploaded_by': uploadedBy.toJson(),
      'uploaded_at': uploadedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Convert to the format expected by the existing UI
  Map<String, dynamic> toUIFormat() {
    return {
      'title': title,
      'type': documentType,
      'url': file,
      'description': description,
      'size': _getFileSize(),
      'uploadedBy': uploadedBy.getDisplayName(),
      'uploadedAt': uploadedAt,
    };
  }

  String _getFileSize() {
    // You might want to implement actual file size calculation
    // For now, returning a placeholder
    return 'Unknown size';
  }
}

class UploadedBy {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;

  UploadedBy({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory UploadedBy.fromJson(Map<String, dynamic> json) {
    return UploadedBy(
      id: json['id'],
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }

  String getDisplayName() {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    } else if (username.isNotEmpty) {
      return username;
    } else {
      return email;
    }
  }
}