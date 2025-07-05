import 'package:demo_app/models/department.dart';
import 'package:demo_app/pages/course_details_screen.dart';
import 'package:flutter/material.dart';

class DepartmentScreenContent extends StatelessWidget {
  final List<Course> courses;
  final String departmentName;

  const DepartmentScreenContent({
    super.key,
    required this.courses,
    required this.departmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$departmentName Courses'),
        centerTitle: true,
      ),
      body: courses.isEmpty
          ? _buildEmptyCourses()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return CourseListItem(
                  course: course,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseDetailsScreen(course: course),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyCourses() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            'No courses available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This department has no courses at the moment',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class CourseListItem extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const CourseListItem({
    super.key,
    required this.course,
    required this.onTap,
  });

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

  @override
  Widget build(BuildContext context) {
    final courseColor = _getColorFromHex(course.colorCode);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Course icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: courseColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconData(course.iconName),
                  color: courseColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Course info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course.courseCode,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
