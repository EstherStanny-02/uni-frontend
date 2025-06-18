import 'package:flutter/material.dart';
import 'package:demo_app/models/message_model.dart';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:demo_app/services/message_service.dart';
import 'package:intl/intl.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  User? _currentUser;
  final UserPreferences _userPreferences = UserPreferences();
  bool _isLoading = true;
  int _unreadCount = 0;
  
  // Initialize our message service
  final MessageService _messageService = MessageService();
   
  // Messages will be loaded from API
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use the MessageService to call our API
      final messagesJson = await _messageService.getMessages();
      
      // Parse the response
      final List<Message> loadedMessages = _parseMessages(messagesJson);
      
      setState(() {
        _messages = loadedMessages;
        _unreadCount = _messages.where((message) => !message.isRead).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _messages = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading messages: $e')),
      );
    }
  }

  // This method parses the JSON data into Message objects
  List<Message> _parseMessages(List<dynamic> messagesJson) {
    return messagesJson.map((messageData) {
      // Map sender ID to name and role based on your API response
      final Map<int, Map<String, String>> senderInfo = {
        1: {'name': 'Academic Office', 'role': 'Academic Support'},
        2: {'name': 'IT Department', 'role': 'Technical Support'},
        8: {'name': 'James Michael', 'role': 'Student Support'},
        9: {'name': 'Admin Office', 'role': 'Administration'},
        // Add more mappings as needed
      };
      
      final int senderId = messageData['sender'] ?? 0;
      final senderName = messageData['sender_name']?.isNotEmpty == true 
          ? messageData['sender_name'] 
          : senderInfo[senderId]?['name'] ?? 'Unknown Sender';
      final senderRole = senderInfo[senderId]?['role'] ?? 'Unknown';
      
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
  }

  _loadUserData() async {
    User user = await _userPreferences.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return "Today ${DateFormat('h:mm a').format(date)}";
    } else if (messageDate == yesterday) {
      return "Yesterday ${DateFormat('h:mm a').format(date)}";
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  Future<void> _markAsRead(int messageId) async {
    try {
      // Call the API to mark the message as read
      bool success = await _messageService.markAsRead(messageId);
      
      if (success) {
        setState(() {
          final index = _messages.indexWhere((msg) => msg.id == messageId);
          if (index != -1 && !_messages[index].isRead) {
            // Create a new message object with isRead set to true
            final updatedMessage = Message(
              id: _messages[index].id,
              content: _messages[index].content,
              timestamp: _messages[index].timestamp,
              isRead: true,
              senderName: _messages[index].senderName,
              senderRole: _messages[index].senderRole,
              senderId: _messages[index].senderId,
              imageUrl: _messages[index].imageUrl,
            );
            
            // Replace the old message with the updated one
            _messages[index] = updatedMessage;
            _unreadCount = _messages.where((message) => !message.isRead).length;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking message as read: $e')),
      );
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    try {
      bool success = await _messageService.deleteMessage(messageId);
      
      if (success) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == messageId);
          _unreadCount = _messages.where((message) => !message.isRead).length;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message deleted")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete message: $e")),
      );
    }
  }

  Future<void> _archiveMessage(int messageId) async {
    try {
      bool success = await _messageService.archiveMessage(messageId);
      
      if (success) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == messageId);
          _unreadCount = _messages.where((message) => !message.isRead).length;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message archived")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to archive message: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // Implement search functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Search not implemented yet")),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchMessages,
            tooltip: "Refresh messages",
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // User welcome banner with unread message count
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, ${_currentUser?.firstName ?? 'Student'}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 16,
                                  color: Colors.blue[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "$_unreadCount unread",
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${_messages.length} total messages",
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Message filter options
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip("All", true),
                              _buildFilterChip("Unread", false),
                              _buildFilterChip("Administration", false),
                              _buildFilterChip("Technical Support", false),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.filter_list, color: Colors.blue[800]),
                        onPressed: () {
                          // Implement filter functionality
                        },
                        tooltip: "More filters",
                      ),
                    ],
                  ),
                ),
                
                // Message list
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _fetchMessages,
                          child: ListView.separated(
                            itemCount: _messages.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1, indent: 76),
                            itemBuilder: (context, index) {
                              return _buildMessageTile(_messages[index]);
                            },
                          ),
                        ),
                ),
                
                // Information footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        "This is a read-only message center",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        onSelected: (selected) {
          // Implement filter functionality
        },
        selectedColor: Colors.blue[100],
        checkmarkColor: Colors.blue[800],
        backgroundColor: Colors.grey[200],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "No messages",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "You don't have any messages at the moment",
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Message message) {
    return InkWell(
      onTap: () {
        _markAsRead(message.id); // Remove the type casting
        _showMessageDetails(message);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        color: message.isRead ? Colors.white : Colors.blue[50],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender avatar or icon
            CircleAvatar(
              backgroundColor: Colors.blue[800],
              radius: 24,
              child: Icon(
                _getSenderIcon(message.senderRole),
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            
            // Message content preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name and time
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.senderName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: message.isRead ? Colors.black87 : Colors.blue[800],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          if (!message.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                                shape: BoxShape.circle,
                              ),
                            ),
                          Text(
                            _formatDate(message.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Message title (extracted from content)
                  Text(
                    message.title,
                    style: TextStyle(
                      fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Message preview
                  Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getSenderIcon(String role) {
    switch (role.toLowerCase()) {
      case 'administration':
        return Icons.admin_panel_settings;
      case 'academic support':
        return Icons.school;
      case 'technical support':
        return Icons.computer;
      case 'student support':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  void _showMessageDetails(Message message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle for dragging the sheet
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  // Message header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[800],
                        radius: 24,
                        child: Icon(
                          _getSenderIcon(message.senderRole),
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.senderName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              message.senderRole,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Message title and timestamp
                  Text(
                    message.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sent on ${DateFormat('MMMM d, yyyy').format(message.timestamp)} at ${DateFormat('h:mm a').format(message.timestamp)}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const Divider(height: 32),
                  
                  // Message content
                  Text(
                    message.content,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 36),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.reply,
                        label: "Reply",
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Reply not available in read-only mode")),
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.archive,
                        label: "Archive",
                        onPressed: () {
                          Navigator.pop(context);
                          _archiveMessage(message.id); // Remove the type casting
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: "Delete",
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteMessage(message.id as String);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.blue[800]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.blue[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}