import 'package:flutter/material.dart';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:intl/intl.dart';

// Enhanced Message model with additional fields for better display
class Message {
  final String id;
  final String title;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String senderName;
  final String senderRole;
  final String? imageUrl;

  Message({
    required this.id,
    required this.title,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    required this.senderName,
    required this.senderRole,
    this.imageUrl,
  });
}

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
  
  // Example messages with more details
  late List<Message> _messages;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initializeMessages();
  }

  void _initializeMessages() {
    _messages = [
      Message(
        id: "1",
        title: "Welcome Back to School",
        content: "Dear student, Welcome to the Uni Schooling Platform. This application is designed to help you manage your academic life. We hope you find it useful and engaging throughout your academic journey.\n\nThe platform offers various features including course registration, grade tracking, schedule management, and direct communication with faculty and administration.\n\nIf you have any questions or feedback, please don't hesitate to reach out to our support team.",
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        senderName: "Admin Office",
        senderRole: "Administration",
        isRead: false,
      ),
      Message(
        id: "2",
        title: "Upcoming Maintenance",
        content: "Please be informed that our systems will undergo scheduled maintenance this weekend from Saturday 8 PM to Sunday 2 AM. During this time, the application and some university services may be temporarily unavailable.\n\nWe apologize for any inconvenience this may cause and appreciate your understanding.",
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        senderName: "IT Department",
        senderRole: "Technical Support",
        isRead: false,
      ),
      Message(
        id: "3",
        title: "Library Hours Extended",
        content: "Good news! The university library has extended its operating hours during the exam period. Starting next week, the library will be open from 7 AM to midnight on weekdays, and 9 AM to 10 PM on weekends.\n\nAdditional study spaces have also been arranged in the Student Center to accommodate more students during this busy period.",
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        senderName: "Library Services",
        senderRole: "Academic Support",
        isRead: true,
      ),
    ];

    // Count unread messages
    _unreadCount = _messages.where((message) => !message.isRead).length;
  }

  _loadUserData() async {
    User user = await _userPreferences.getUser();
    setState(() {
      _currentUser = user;
      _isLoading = false;
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

  void _markAsRead(String messageId) {
    setState(() {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1 && !_messages[index].isRead) {
        // Create a new message object with isRead set to true
        final updatedMessage = Message(
          id: _messages[index].id,
          title: _messages[index].title,
          content: _messages[index].content,
          timestamp: _messages[index].timestamp,
          isRead: true,
          senderName: _messages[index].senderName,
          senderRole: _messages[index].senderRole,
          imageUrl: _messages[index].imageUrl,
        );
        
        // Replace the old message with the updated one
        _messages[index] = updatedMessage;
        _unreadCount = _messages.where((message) => !message.isRead).length;
      }
    });
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
                              _buildFilterChip("Academic", false),
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
                      : ListView.separated(
                          itemCount: _messages.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, indent: 76),
                          itemBuilder: (context, index) {
                            return _buildMessageTile(_messages[index]);
                          },
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
        _markAsRead(message.id);
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
                  
                  // Message title
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Archive functionality coming soon")),
                          );
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: "Delete",
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Delete functionality coming soon")),
                          );
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