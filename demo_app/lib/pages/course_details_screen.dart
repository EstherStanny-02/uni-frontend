import 'package:demo_app/models/course_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class CourseDetailsScreen extends StatefulWidget {
  final Course course;

  const CourseDetailsScreen({super.key, required this.course});

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  bool _isFavorite = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'PDF',
    'DOC',
    'PPT',
    'Video',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    // Load favorite status from SharedPreferences or database
    // For now, just set to false
    setState(() {
      _isFavorite = false;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // Save to SharedPreferences or database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCourse() {
    Share.share(
      'Check out this course: ${widget.course.title}\n'
      'Course Code: ${widget.course.courseCode}\n'
      'Department: ${widget.course.departmentName}\n'
      '${widget.course.description ?? ""}',
      subject: 'Course: ${widget.course.title}',
    );
  }

  Future<void> _downloadDocument(Map<String, dynamic> document) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get the downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        final fileName = document['title'] ?? 'document';
        final fileExtension = _getFileExtension(document['type'] ?? 'pdf');
        final filePath = '${downloadsDir.path}/$fileName.$fileExtension';

        // Simulate download with Dio (replace with actual URL)
        final dio = Dio();
        await dio.download(
          document['url'] ?? 'https://example.com/sample.pdf',
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              // Update progress if needed
              print(
                  'Download progress: ${(received / total * 100).toStringAsFixed(0)}%');
            }
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Downloaded: $fileName.$fileExtension'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () => _openDocument(filePath),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openDocument(String filePath) async {
    final uri = Uri.file(filePath);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot open document')),
      );
    }
  }

  String _getFileExtension(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return 'pdf';
      case 'doc':
      case 'docx':
        return 'docx';
      case 'ppt':
      case 'pptx':
        return 'pptx';
      case 'video':
        return 'mp4';
      default:
        return 'pdf';
    }
  }

  List _getFilteredDocuments() {
    if (_selectedFilter == 'All') {
      return widget.course.documents;
    }
    return widget.course.documents
        .where((doc) =>
            doc['type']?.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'video':
        return Icons.play_circle_outline;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getDocumentColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'video':
        return Colors.purple;
      case 'image':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final courseColor = _getColorFromHex(widget.course.colorCode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(courseColor, isTablet),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourseHeader(courseColor, isTablet),
                  _buildCourseStats(courseColor, isTablet),
                  _buildCourseDescription(isTablet),
                  _buildCourseMaterials(courseColor, isTablet),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActions(courseColor),
    );
  }

  Widget _buildSliverAppBar(Color courseColor, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 300.0 : 200.0,
      floating: false,
      pinned: true,
      backgroundColor: courseColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.course.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                courseColor,
                courseColor.withOpacity(0.8),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'course-${widget.course.courseCode}',
              child: CircleAvatar(
                radius: isTablet ? 60 : 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Icon(
                  _getIconData(widget.course.iconName),
                  size: isTablet ? 60 : 50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          onPressed: _toggleFavorite,
        ),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareCourse,
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'copy_code':
                Clipboard.setData(
                    ClipboardData(text: widget.course.courseCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Course code copied to clipboard')),
                );
                break;
              case 'report':
                _showReportDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'copy_code',
              child: Row(
                children: [
                  Icon(Icons.copy),
                  SizedBox(width: 8),
                  Text('Copy Course Code'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report),
                  SizedBox(width: 8),
                  Text('Report Issue'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseHeader(Color courseColor, bool isTablet) {
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   widget.course.courseCode,
                    //   style: TextStyle(
                    //     fontSize: isTablet ? 18 : 16,
                    //     fontWeight: FontWeight.bold,
                    //     color: courseColor,
                    //   ),
                    // ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: courseColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        widget.course.departmentName,
                        style: TextStyle(
                          color: courseColor,
                          fontWeight: FontWeight.w500,
                          fontSize: isTablet ? 14 : 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding: const EdgeInsets.all(8),
              //   decoration: BoxDecoration(
              //     color: courseColor.withOpacity(0.1),
              //     borderRadius: BorderRadius.circular(12),
              //   ),
              //   child: Icon(
              //     Icons.bookmark,
              //     color: courseColor,
              //     size: isTablet ? 28 : 24,
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseStats(Color courseColor, bool isTablet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Materials',
              '${widget.course.documents.length}',
              Icons.folder_open,
              courseColor,
              isTablet,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Downloads',
              '0', // You can track this
              Icons.download,
              courseColor,
              isTablet,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color, bool isTablet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isTablet ? 28 : 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: isTablet ? 12 : 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDescription(bool isTablet) {
    return Container(
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
          Text(
            "Course Description",
            style: TextStyle(
              fontSize: isTablet ? 22 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.course.description ??
                "No description available for this course.",
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseMaterials(Color courseColor, bool isTablet) {
    final filteredDocuments = _getFilteredDocuments();

    return Container(
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
                "Course Materials",
                style: TextStyle(
                  fontSize: isTablet ? 22 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.course.documents.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.download_for_offline),
                  onPressed: () => _downloadAllDocuments(),
                  tooltip: 'Download All',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Filter chips
          if (widget.course.documents.isNotEmpty) ...[
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final filter = _filterOptions[index];
                  final isSelected = _selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: courseColor.withOpacity(0.2),
                      checkmarkColor: courseColor,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Documents list
          filteredDocuments.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocuments.length,
                  itemBuilder: (context, index) {
                    final document = filteredDocuments[index];
                    return _buildDocumentCard(document, courseColor, isTablet);
                  },
                )
              : _buildEmptyState(isTablet),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
      Map<String, dynamic> document, Color courseColor, bool isTablet) {
    final documentType = document['type'] ?? 'Document';
    final documentColor = _getDocumentColor(documentType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: documentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getDocumentIcon(documentType),
            color: documentColor,
            size: isTablet ? 28 : 24,
          ),
        ),
        title: Text(
          document['title'] ?? 'Unknown Document',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isTablet ? 16 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              documentType,
              style: TextStyle(
                color: documentColor,
                fontSize: isTablet ? 12 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (document['size'] != null)
              Text(
                document['size'],
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: isTablet ? 11 : 9,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () => _previewDocument(document),
              tooltip: 'Preview',
            ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              onPressed: _isLoading ? null : () => _downloadDocument(document),
              tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No materials available yet",
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Materials will appear here when they're uploaded",
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActions(Color courseColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: "add_note",
          mini: true,
          backgroundColor: courseColor.withOpacity(0.8),
          onPressed: () => _addNote(),
          child: const Icon(Icons.note_add, color: Colors.white),
        ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: "calendar",
          backgroundColor: courseColor,
          onPressed: () => _showSchedule(),
          child: const Icon(Icons.calendar_today, color: Colors.white),
        ),
      ],
    );
  }

  void _previewDocument(Map<String, dynamic> document) {
    // Implement document preview
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document['title'] ?? 'Document Preview'),
        content: Text('Preview functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadDocument(document);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _downloadAllDocuments() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download All Documents'),
        content:
            const Text('This will download all course materials. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement bulk download
              for (var doc in widget.course.documents) {
                _downloadDocument(doc);
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  void _addNote() {
    // Navigate to note-taking screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note-taking feature coming soon!')),
    );
  }

  void _showSchedule() {
    // Show course schedule
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Course Schedule',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Monday: 9:00 AM - 10:30 AM'),
            const Text('Wednesday: 9:00 AM - 10:30 AM'),
            const Text('Friday: 9:00 AM - 10:30 AM'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Issue'),
        content: const TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe the issue...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report submitted successfully')),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  // Helper methods (same as original)
  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'computer':
      case 'computer_outlined':
        return Icons.computer_outlined;
      case 'business':
      case 'business_center':
        return Icons.business_center;
      case 'people':
      case 'people_alt_outlined':
        return Icons.people_alt_outlined;
      case 'sailing':
      case 'sailing_outlined':
        return Icons.sailing_outlined;
      case 'train':
      case 'train_outlined':
        return Icons.train_outlined;
      case 'engineering':
      case 'precision_manufacturing_outlined':
        return Icons.precision_manufacturing_outlined;
      case 'car':
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'code':
      case 'code_outlined':
        return Icons.code_outlined;
      default:
        return Icons.school;
    }
  }

  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.blue;
    }
  }
}
