// ignore: file_names
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:demo_app/pages/profile_screen.dart';
import 'package:demo_app/pages/settings_screen.dart';
import 'package:demo_app/pages/messages_screen.dart';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/models/department.dart';
import 'package:demo_app/services/department_service.dart';
import 'package:demo_app/pages/course_details_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const CoursesScreen(),
    const MessageScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.blue[800],
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            selectedFontSize: 12,
            unselectedFontSize: 10,
            elevation: 0,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  CoursesScreenState createState() => CoursesScreenState();
}

class CoursesScreenState extends State<CoursesScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = "All Courses";
  User? _currentUser;
  final UserPreferences _userPreferences = UserPreferences();
  final DepartmentService _departmentService = DepartmentService();
  
  List<Department> _departments = [];
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  List<String> _categories = ["All Courses"];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCourses();
  }

  _loadUserData() async {
    User user = await _userPreferences.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  _loadCourses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Fetch departments and courses
      final departments = await _departmentService.fetchDepartments();
      
      // Extract all courses from departments
      List<Course> allCourses = [];
      List<String> categories = ["All Courses"];
      
      for (var department in departments) {
        allCourses.addAll(department.courses);
        
        // Add department name to categories
        if (!categories.contains(department.name)) {
          categories.add(department.name);
        }
      }
      
      setState(() {
        _departments = departments;
        _allCourses = allCourses;
        _filteredCourses = allCourses;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _filterCourses(String category) {
    setState(() {
      _selectedCategory = category;
      
      if (category == "All Courses") {
        _filteredCourses = _allCourses;
      } else {
        _filteredCourses = _allCourses
            .where((course) => course.departmentName == category)
            .toList();
      }
    });
  }

  void _searchCourses(String query) {
    if (query.isEmpty) {
      _filterCourses(_selectedCategory);
      return;
    }
    
    setState(() {
      _filteredCourses = _allCourses
          .where((course) => 
              course.title.toLowerCase().contains(query.toLowerCase()) ||
              course.courseCode.toLowerCase().contains(query.toLowerCase()) ||
              course.departmentName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _userPreferences.removeUser(); // Clear user data
              Navigator.pop(context); // Close the dialog
              
              // Navigate to login screen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false, // This will remove all previous routes
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        centerTitle: !_isSearching,
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: "Search courses...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  _searchCourses(value);
                },
              )
            : const Text(
                "University Courses",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _searchController.clear();
                  _filterCourses(_selectedCategory);
                }
                _isSearching = !_isSearching;
              });
            },
            icon: Icon(_isSearching ? Icons.cancel : Icons.search),
          ),
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, ${_currentUser?.firstName ?? "User"}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore your academic journey',
                    style: TextStyle(
                      color: Colors.blue[100],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Categories horizontal list
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: GestureDetector(
                            onTap: () {
                              _filterCourses(_categories[index]);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: _selectedCategory == _categories[index] 
                                    ? Colors.white 
                                    : Colors.blue[700],
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: _selectedCategory == _categories[index] 
                                    ? [ 
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ] 
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _categories[index],
                                style: TextStyle(
                                  color: _selectedCategory == _categories[index] 
                                      ? Colors.blue[800] 
                                      : Colors.white,
                                  fontWeight: _selectedCategory == _categories[index] 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Courses grid
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[300], size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            "Failed to load courses",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadCourses,
                            child: const Text("Try Again"),
                          ),
                        ],
                      ),
                    )
                  : _filteredCourses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, color: Colors.grey[400], size: 60),
                            const SizedBox(height: 16),
                            Text(
                              "No courses found",
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedCategory,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${_filteredCourses.length} Courses",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: GridView.builder(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 0.85,
                                ),
                                itemCount: _filteredCourses.length,
                                itemBuilder: (context, index) {
                                  final course = _filteredCourses[index];
                                  return _buildCourseCard(course);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    // Convert color code to Flutter Color
    Color color = _getColorFromHex(course.colorCode);
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailsScreen(course: course),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.15),
              offset: const Offset(0, 5),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              child: Icon(
                _getIconData(course.iconName),
                size: 30,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                course.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              course.courseCode,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
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