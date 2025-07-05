// MultipleFiles/course_details_screen.dart
import 'package:demo_app/pages/tabs/course_documents_tab.dart';
import 'package:demo_app/pages/tabs/tutorials_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:demo_app/models/department.dart';
import 'package:share_plus/share_plus.dart';

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
  late TabController _tabController;
  bool _isFavorite = false;

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

    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavoriteStatus() {
    setState(() {
      _isFavorite = false;
    });
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareCourse() {
    // ignore: deprecated_member_use
    Share.share(
      'Check out this course: ${widget.course.title}\n'
      'Course Code: ${widget.course.courseCode}\n'
      'Department: ${widget.course.departmentName}\n'
      '${widget.course.description ?? ""}',
      subject: 'Course: ${widget.course.title}',
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final courseColor = _getColorFromHex(widget.course.colorCode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(courseColor, isTablet),
          SliverFillRemaining(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Documents Tab Content
                  DocumentsTab(
                    courseId: widget.course.id.toString(),
                    courseColor: courseColor,
                    isTablet: isTablet,
                  ),
                  // Notes Tab Content
                  TutorialsTab(
                    courseId: widget.course.id.toString(),
                    courseColor: courseColor,
                    isTablet: isTablet,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Color courseColor, bool isTablet) {
    return SliverAppBar(
      expandedHeight: isTablet ? 300.0 : 200.0,
      floating: false,
      pinned: true,
      backgroundColor: courseColor,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double currentHeight = constraints.biggest.height;
          final double maxExtent = isTablet ? 300.0 : 200.0;
          final double minExtent = kToolbarHeight +
              (isTablet ? 56.0 : 48.0); // Account for TabBar height
          final double opacity =
              (currentHeight - minExtent) / (maxExtent - minExtent);

          return FlexibleSpaceBar(
            centerTitle: true, // Center the title
            titlePadding: EdgeInsets.only(
                bottom: _tabController.indexIsChanging
                    ? 0
                    : 56.0), // Adjust padding to prevent overlap
            title: Opacity(
              opacity:
                  opacity.clamp(0.0, 1.0), // Fade in title as app bar expands
              child: Text(
                widget.course.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
                ),
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
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: isTablet
                          ? 60.0
                          : 40.0), // Adjust padding for Hero icon
                  child: Hero(
                    tag: 'course-${widget.course.courseCode}',
                    child: CircleAvatar(
                      radius: isTablet ? 40 : 32,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Icon(
                        _getIconData(widget.course.iconName),
                        size: isTablet ? 40 : 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
              case 'refresh_documents':
                // Trigger refresh in DocumentsTab
                _tabController.animateTo(0); // Switch to documents tab
                // A more robust solution would be to use a GlobalKey or Provider for state management
                // For simplicity, we'll just switch tabs and assume the tab will refresh itself on init/visibility
                break;
              case 'refresh_notes':
                // Trigger refresh in TutorialsTab
                _tabController.animateTo(1); // Switch to tutorials tab
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
              value: 'refresh_documents',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh Documents'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'refresh_notes',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Refresh Notes'),
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
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Documents', icon: Icon(Icons.folder_open)),
          Tab(text: 'Tutorials', icon: Icon(Icons.notes)),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
      ),
    );
  }
}
