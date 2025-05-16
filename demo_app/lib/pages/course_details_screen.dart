import 'package:flutter/material.dart';
import 'package:demo_app/models/department.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;
  
  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    // Convert color code from string to Color
    Color courseColor = _getColorFromHex(course.colorCode);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(course.title),
        backgroundColor: courseColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with course icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: courseColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: courseColor.withOpacity(0.2),
                    child: Icon(
                      _getIconData(course.iconName),
                      size: 50,
                      color: courseColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.courseCode,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: courseColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      course.departmentName,
                      style: TextStyle(
                        color: courseColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Course details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    course.description ?? "No description available for this course.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    "Course Materials",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Documents list
                  course.documents.isNotEmpty 
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: course.documents.length,
                          itemBuilder: (context, index) {
                            final document = course.documents[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Icon(Icons.description, color: courseColor),
                                title: Text(document['title'] ?? 'Unknown Document'),
                                subtitle: Text(document['type'] ?? 'Document'),
                                trailing: const Icon(Icons.download_rounded),
                                onTap: () {
                                  // Handle document download/view
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Document download not implemented yet')),
                                  );
                                },
                              ),
                            );
                          },
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  "No materials available yet",
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get IconData from string name
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
  
  // Helper method to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    try {
      hexColor = hexColor.replaceAll('#', '');
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Default to blue if parsing fails
      return Colors.blue;
    }
  }
}