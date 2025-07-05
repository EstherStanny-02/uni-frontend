// MultipleFiles/documents_tab.dart
import 'package:flutter/material.dart';
import 'package:demo_app/models/course_document.dart';
import 'package:demo_app/services/course_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:io';

class DocumentsTab extends StatefulWidget {
  final String courseId;
  final Color courseColor;
  final bool isTablet;

  const DocumentsTab({
    super.key,
    required this.courseId,
    required this.courseColor,
    required this.isTablet,
  });

  @override
  State<DocumentsTab> createState() => _DocumentsTabState();
}

class _DocumentsTabState extends State<DocumentsTab> {
  bool _isLoadingDocuments = false;
  bool _isDownloading = false;
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'PDF',
    'DOC',
    'PPT',
    'Video',
    'Other'
  ];
  List<CourseDocument> _courseDocuments = [];
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _loadCourseDocuments();
  }

  Future<void> _loadCourseDocuments() async {
    setState(() {
      _isLoadingDocuments = true;
    });

    try {
      final service = CourseDetailsService();
      final response = await service.getDocumentsByCourse(courseId: int.parse(widget.courseId));
      setState(() {
        _courseDocuments = response;
      });
    } catch (e) {
      print('Error loading course documents: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load course documents: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingDocuments = false;
      });
    }
  }

  Future<void> _downloadDocument(CourseDocument document) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir != null) {
        final fileName = document.title;
        final fileExtension = _getFileExtension(document.documentType);
        final filePath = '${downloadsDir.path}/$fileName.$fileExtension';

        await _dio.download(
          document.file,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
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
        _isDownloading = false;
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

  List<CourseDocument> _getFilteredDocuments() {
    if (_selectedFilter == 'All') {
      return _courseDocuments;
    }
    return _courseDocuments
        .where((doc) =>
    doc.documentType.toLowerCase() == _selectedFilter.toLowerCase())
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

  void _previewDocument(CourseDocument document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(document.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${document.documentType}'),
            const SizedBox(height: 8),
            Text('Uploaded by: ${document.uploadedBy.getDisplayName()}'),
            const SizedBox(height: 8),
            Text('Uploaded: ${document.uploadedAt.toString().split(' ')[0]}'),
            if (document.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Description: ${document.description}'),
            ],
            const SizedBox(height: 16),
            const Text('Preview functionality will be implemented here.'),
          ],
        ),
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
              for (var doc in _courseDocuments) {
                _downloadDocument(doc);
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredDocuments = _getFilteredDocuments();

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
                  "Course Materials",
                  style: TextStyle(
                    fontSize: widget.isTablet ? 22 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoadingDocuments)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _loadCourseDocuments,
                        tooltip: 'Refresh',
                      ),
                    if (_courseDocuments.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.download_for_offline),
                        onPressed: () => _downloadAllDocuments(),
                        tooltip: 'Download All',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter chips
            if (_courseDocuments.isNotEmpty) ...[
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
                        selectedColor: widget.courseColor.withOpacity(0.2),
                        checkmarkColor: widget.courseColor,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Documents list
            if (_isLoadingDocuments)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (filteredDocuments.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final document = filteredDocuments[index];
                  return _buildDocumentCard(document);
                },
              )
            else
              _buildEmptyState(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(CourseDocument document) {
    final documentColor = _getDocumentColor(document.documentType);

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
            _getDocumentIcon(document.documentType),
            color: documentColor,
            size: widget.isTablet ? 28 : 24,
          ),
        ),
        title: Text(
          document.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: widget.isTablet ? 16 : 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document.documentType,
              style: TextStyle(
                color: documentColor,
                fontSize: widget.isTablet ? 12 : 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Uploaded by ${document.uploadedBy.getDisplayName()}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: widget.isTablet ? 11 : 9,
              ),
            ),
            if (document.description.isNotEmpty)
              Text(
                document.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: widget.isTablet ? 11 : 9,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
              icon: _isDownloading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.download),
              onPressed: _isDownloading ? null : () => _downloadDocument(document),
              tooltip: 'Download',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: widget.isTablet ? 80 : 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "No materials available yet",
              style: TextStyle(
                fontSize: widget.isTablet ? 18 : 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Materials will appear here when they're uploaded",
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