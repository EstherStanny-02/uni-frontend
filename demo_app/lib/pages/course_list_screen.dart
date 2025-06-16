import 'package:demo_app/models/department.dart';
import 'package:demo_app/pages/course_details_screen.dart';
import 'package:demo_app/services/course_service.dart';
import 'package:flutter/material.dart';


class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final CourseDetailsService _courseService = CourseDetailsService();
  late Future<List<Course>> _coursesFuture;
  String _filterDepartment = 'All';
  List<String> _departments = ['All'];

  @override
  void initState() {
    super.initState();
    _coursesFuture = _fetchCourses();
  }

  Future<List<Course>> _fetchCourses() async {
    try {
      final courses = await _courseService.getCourses();
      
      // Extracting unique departments for filter
      Set<String> deptSet = {'All'};
      for (var course in courses) {
        deptSet.add(course.departmentName);
      }
      setState(() {
        _departments = deptSet.toList()..sort();
      });
      
      return courses;
    } catch (e) {
      rethrow;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Courses'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _coursesFuture = _fetchCourses();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Department filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Row(
              children: [
                const Text(
                  'Department:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filterDepartment,
                    isExpanded: true,
                    underline: Container(
                      height: 1,
                      color: Colors.grey[400],
                    ),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _filterDepartment = newValue;
                        });
                      }
                    },
                    items: _departments
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Course list
          Expanded(
            child: FutureBuilder<List<Course>>(
              future: _coursesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading courses',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No courses available'),
                      ],
                    ),
                  );
                } else {
                  // Filter courses by department if needed
                  final courses = snapshot.data!;
                  final filteredCourses = _filterDepartment == 'All'
                      ? courses
                      : courses
                          .where((c) => c.departmentName == _filterDepartment)
                          .toList();

                  return filteredCourses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No courses found for $_filterDepartment department',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCourses.length,
                      itemBuilder: (context, index) {
                        final course = filteredCourses[index];
                        final courseColor = _getColorFromHex(course.colorCode);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CourseCard(
                            course: course, 
                            courseColor: courseColor,
                            iconData: _getIconData(course.iconName),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailsScreen(course: course),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Course course;
  final Color courseColor;
  final IconData iconData;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.courseColor,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top colored section
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: courseColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: courseColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      size: 28,
                      color: courseColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Course details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.courseCode,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: courseColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            course.departmentName,
                            style: TextStyle(
                              fontSize: 12,
                              color: courseColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow indicator
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}