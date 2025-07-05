// MultipleFiles/tutorials_tab.dart
import 'package:flutter/material.dart';
import 'package:demo_app/models/course_notes.dart';
import 'package:demo_app/services/course_service.dart';

class TutorialsTab extends StatefulWidget {
  final String courseId;
  final Color courseColor;
  final bool isTablet;

  const TutorialsTab({
    super.key,
    required this.courseId,
    required this.courseColor,
    required this.isTablet,
  });

  @override
  State<TutorialsTab> createState() => _TutorialsTabState();
}

class _TutorialsTabState extends State<TutorialsTab> {
  bool _isLoadingNotes = false;
  List<CourseNote> _courseNotes = [];

  @override
  void initState() {
    super.initState();
    _loadCourseNotes();
  }

  Future<void> _loadCourseNotes() async {
    setState(() {
      _isLoadingNotes = true;
    });

    try {
      final service = CourseDetailsService();
      final response = await service.getNotesByCourse(courseId: int.parse(widget.courseId));
      setState(() {
        _courseNotes = response;
      });
    } catch (e) {
      print('Error loading course notes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load course notes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingNotes = false;
      });
    }
  }

  void _showNoteDetails(CourseNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                note.content,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Uploaded by: ${note.uploadedBy.getDisplayName()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                'Uploaded on: ${note.uploadedAt.toString().split(' ')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Course Notes",
                  style: TextStyle(
                    fontSize: widget.isTablet ? 22 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_isLoadingNotes)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadCourseNotes,
                    tooltip: 'Refresh Notes',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoadingNotes)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_courseNotes.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _courseNotes.length,
                itemBuilder: (context, index) {
                  final note = _courseNotes[index];
                  return _buildNoteCard(note);
                },
              )
            else
              _buildEmptyNotesState(),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteCard(CourseNote note) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: widget.isTablet ? 18 : 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              note.content,
              style: TextStyle(
                fontSize: widget.isTablet ? 14 : 12,
                color: Colors.grey[700],
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Uploaded by ${note.uploadedBy.getDisplayName()} on ${note.uploadedAt.toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: widget.isTablet ? 11 : 9,
                color: Colors.grey[600],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => _showNoteDetails(note),
                child: const Text('Read More'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyNotesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.notes,
              size: widget.isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No notes available yet",
              style: TextStyle(
                fontSize: widget.isTablet ? 18 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Notes uploaded by the lecturer will appear here.",
              style: TextStyle(
                fontSize: widget.isTablet ? 14 : 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}