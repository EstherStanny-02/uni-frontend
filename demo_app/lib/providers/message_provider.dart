import 'package:demo_app/models/message_model.dart';
import 'package:demo_app/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class MessageProvider with ChangeNotifier {
  final MessageService _messageService;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  // Map of sender IDs to sender information
  final Map<int, Map<String, String>> _senderInfo = {
    9: {'name': 'Admin Office', 'role': 'Administration'},
    2: {'name': 'IT Department', 'role': 'Technical Support'},
    // Add more mappings as needed
  };

  MessageProvider(this._messageService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _messages.where((message) => !message.isRead).length;

  // Fetch messages from the API
   Future<void> fetchMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final jsonData = await _messageService.getMessages();

      _messages = jsonData.map<Message>((messageData) {
        // Enrich the data with sender information
        final int senderId = messageData['sender'] ?? 0;
        final senderName = messageData['sender_name']?.isNotEmpty == true 
            ? messageData['sender_name'] 
            : _senderInfo[senderId]?['name'] ?? 'Unknown Sender';
        final senderRole = _senderInfo[senderId]?['role'] ?? 'Unknown';
        
        // Create additional fields needed for our Message model
        Map<String, dynamic> enrichedData = {
          ...messageData,
          'sender_name': senderName,
          'sender_role': senderRole,
          'sender_id': senderId,
          'content': messageData['body'], // Map 'body' to 'content'
        };
        
        return Message.fromJson(enrichedData);
      }).toList();

      _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      _isLoading = false;
      notifyListeners();
    
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      // For development, also print to console
      print('Error fetching messages: $e');
    }
  }

  // Mark a message as read
  Future<void> markAsRead(String messageId) async {
    try {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1 && !_messages[index].isRead) {
        // Update local state immediately for better UX
        _messages[index] = _messages[index].copyWith(isRead: true);
        notifyListeners();

        // Then update on the server
        await _messageService.markAsRead(messageId);
      }
    } catch (e) {
      print('Error marking message as read: $e');
      // Revert the change if the API call fails
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final oldMessage = _messages[index];
        _messages[index] = oldMessage.copyWith(isRead: false);
        notifyListeners();
      }
    }
  }

  // Archive a message
  Future<bool> archiveMessage(String messageId) async {
    try {
      final success = await _messageService.archiveMessage(messageId);
      if (success) {
        // Remove from local list
        _messages.removeWhere((msg) => msg.id == messageId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error archiving message: $e');
      return false;
    }
  }

  // Delete a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      final success = await _messageService.deleteMessage(messageId);
      if (success) {
        // Remove from local list
        _messages.removeWhere((msg) => msg.id == messageId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting message: $e');
      return false;
    }
  }

  // Filter messages by criteria
  List<Message> getFilteredMessages({String? filter}) {
    if (filter == null || filter == 'All') {
      return _messages;
    } else if (filter == 'Unread') {
      return _messages.where((msg) => !msg.isRead).toList();
    } else {
      // Filter by sender role
      return _messages.where((msg) => msg.senderRole == filter).toList();
    }
  }
}
