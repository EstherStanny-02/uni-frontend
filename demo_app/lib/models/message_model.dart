class Message {
  final String id;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String senderName;
  final String senderRole;
  final int senderId;
  final String? imageUrl;

  Message({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.senderName,
    required this.senderRole,
    required this.senderId,
    this.imageUrl,
  });

  // Extract a title from the message content (first line or first few words)
  String get title {
    if (content.isEmpty) return "No Subject";
    
    // Try to get the first line (if there are line breaks)
    final firstLine = content.split('\n').first.trim();
    if (firstLine.length > 3) {
      return firstLine;
    }
    
    // Otherwise get the first few words
    final words = content.split(' ');
    if (words.length <= 5) {
      return content;
    } else {
      return words.take(5).join(' ') + '...';
    }
  }

  // Create a Message from JSON
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? json['sent_at'] ?? DateTime.now().toIso8601String(),
      content: json['body'] ?? json['content'] ?? '',
      timestamp: json['sent_at'] != null 
          ? DateTime.parse(json['sent_at']) 
          : DateTime.now(),
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'] ?? 'Unknown Sender',
      senderRole: json['sender_role'] ?? 'Unknown',
      senderId: json['sender_id'] ?? json['sender'] ?? 0,
      imageUrl: json['image_url'],
    );
  }


   Message copyWith({
    String? id,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? senderRole,
    // Add other fields as needed
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderName: this.senderName,
      senderRole: senderRole ?? this.senderRole,
      senderId: this.senderId,
      imageUrl: this.imageUrl,
    );
  }
}