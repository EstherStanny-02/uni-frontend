import 'package:demo_app/pages/department_screen_content.dart';
import 'package:demo_app/pages/login_screen.dart';
import 'package:demo_app/services/department_service.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:demo_app/pages/profile_screen.dart';
import 'package:demo_app/pages/settings_screen.dart';
import 'package:demo_app/pages/messages_screen.dart';
import 'package:demo_app/models/user_model.dart';
import 'package:demo_app/models/department.dart';
import 'package:http/http.dart' as http;
import 'package:demo_app/services/app_url.dart';
import 'dart:convert';
import 'dart:developer' as developer;

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
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DepartmentScreen(),
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
                label: 'Departments',
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

class DepartmentScreen extends StatefulWidget {
  const DepartmentScreen({super.key});

  @override
  DepartmentScreenState createState() => DepartmentScreenState();
}

class DepartmentScreenState extends State<DepartmentScreen> {
  bool _isSearching = false;
  bool _isLoading = true;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  User? _currentUser;
  final UserPreferences _userPreferences = UserPreferences();

  List<Department> _departments = [];
  List<Department> _filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add a slight delay to ensure the widget is fully initialized
    Future.delayed(Duration.zero, () {
      _loadDepartments();
    });
  }

  _loadUserData() async {
    User user = await _userPreferences.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  _loadDepartments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Check if running on web platform
      if (kIsWeb) {
        // Web platform - direct API call
        final departments = await _fetchDepartmentsDirectlyFromApi();
        developer.log(
            'Loaded ${departments.length} departments directly from API for web platform');
        setState(() {
          _departments = departments;
          _filteredDepartments = departments;
          _isLoading = false;
        });
      } else {
        // Mobile/desktop platform - use service that handles local storage
        final departmentService = DepartmentService();
        final departments = await departmentService.fetchDepartments();
        developer.log(
            'Loaded ${departments.length} departments from service (probably local storage)');
        setState(() {
          _departments = departments;
          _filteredDepartments = departments;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading departments: $e. Using mock data.');
      // Use mock data if API call fails
      final departments = _getMockDepartments();

      setState(() {
        _departments = departments;
        _filteredDepartments = departments;
        _isLoading = false;
      });
    }
  }

  // New method to fetch departments directly from API for web platforms
  Future<List<Department>> _fetchDepartmentsDirectlyFromApi() async {
    try {
      final response = await http.get(Uri.parse(AppUrl.departments));

      if (response.statusCode == 200) {
        final List<dynamic> departmentsJson = json.decode(response.body);
        return departmentsJson
            .map((json) => Department.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in direct API call: $e');
      rethrow; // Re-throw to be caught by the caller
    }
  }

  // Mock data for testing or when API is unavailable
  List<Department> _getMockDepartments() {
    // Current timestamp for created_at and updated_at fields
    final now = DateTime.now().toIso8601String();

    return [
      Department(
        id: 1,
        name: 'Computer Science',
        code: 'CS',
        description: 'Department of Computer Science and Engineering',
        logo:
            'https://example.com/cs.png', // This will fail to load and show the fallback
        courses: [
          Course(
            id: 101,
            title: 'Introduction to Programming',
            courseCode: 'CS101',
            department: 1,
            departmentName: 'Computer Science',
            description: 'Fundamentals of programming using Python',
            iconName: 'computer_outlined',
            colorCode: '#4285F4',
            documents: [],
            createdAt: now,
            updatedAt: now,
          ),
        ],
        createdAt: now,
        updatedAt: now,
      ),
      Department(
        id: 2,
        name: 'Electrical Engineering',
        code: 'EE',
        description: 'Department of Electrical Engineering',
        logo: 'https://example.com/ee.png',
        courses: [],
        createdAt: now,
        updatedAt: now,
      ),
      Department(
        id: 3,
        name: 'Business Administration',
        code: 'BA',
        description: 'Department of Business Administration',
        logo: 'https://example.com/ba.png',
        courses: [],
        createdAt: now,
        updatedAt: now,
      ),
      Department(
        id: 4,
        name: 'Mechanical Engineering',
        code: 'ME',
        description: 'Department of Mechanical Engineering',
        logo: 'https://example.com/me.png',
        courses: [],
        createdAt: now,
        updatedAt: now,
      ),
      Department(
        id: 5,
        name: 'Mathematics',
        code: 'MATH',
        description: 'Department of Mathematics',
        logo: 'https://example.com/math.png',
        courses: [],
        createdAt: now,
        updatedAt: now,
      ),
      Department(
        id: 6,
        name: 'Physics',
        code: 'PHYS',
        description: 'Department of Physics',
        logo: 'https://example.com/phys.png',
        courses: [],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  void _searchDepartments(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDepartments = _departments;
      });
      return;
    }

    setState(() {
      _filteredDepartments = _departments
          .where((department) =>
              department.name.toLowerCase().contains(query.toLowerCase()) ||
              department.code.toLowerCase().contains(query.toLowerCase()))
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
            onPressed: () {
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

  // Helper method to get a color based on department name (for demo purpose)
  Color _getDepartmentColor(String name) {
    // Simple hash function to generate color based on name
    int hash = name.codeUnits.fold(0, (a, b) => a + b);
    return Color.fromARGB(
      255,
      (hash * 33) % 255,
      (hash * 73) % 255,
      (hash * 47) % 255,
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
                  hintText: "Search departments...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  _searchDepartments(value);
                },
              )
            : const Text(
                "University Schooling",
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
                  _filteredDepartments = _departments;
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
                    'Welcome, ${_currentUser?.firstName ?? "User"}!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kIsWeb
                        ? 'Web Platform - API Direct Access'
                        : 'Explore departments and courses',
                    style: TextStyle(
                      color: Colors.blue[100],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Departments grid
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red[300], size: 60),
                              const SizedBox(height: 16),
                              const Text(
                                "Failed to load departments",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: _loadDepartments,
                                child: const Text("Try Again"),
                              ),
                            ],
                          ),
                        )
                      : _filteredDepartments.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      color: Colors.grey[400], size: 60),
                                  const SizedBox(height: 16),
                                  Text(
                                    "No departments found",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.grey[600]),
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "All Departments",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "${_filteredDepartments.length} Departments${kIsWeb ? " (Web)" : ""}",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: RefreshIndicator(
                                      onRefresh: () async {
                                        await _loadDepartments();
                                      },
                                      child: GridView.builder(
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 15,
                                          mainAxisSpacing: 15,
                                          childAspectRatio: 0.85,
                                        ),
                                        itemCount: _filteredDepartments.length,
                                        itemBuilder: (context, index) {
                                          final department =
                                              _filteredDepartments[index];
                                          return _buildDepartmentCard(
                                              department);
                                        },
                                      ),
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

  Widget _buildDepartmentCard(Department department) {
    // Use the logo if available, otherwise use a color based on name
    Color depColor = _getDepartmentColor(department.name);

    return InkWell(
      onTap: () {
        // Show a temporary message that courses would be shown here
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DepartmentScreenContent(
                departmentName: department.name,
              ),
            ));
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
            // Department logo in circular avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: depColor.withOpacity(0.2),
              child: department.logo != null && department.logo!.isNotEmpty
                  ? Image.network(
                      department.logo!,
                      errorBuilder: (context, error, stackTrace) {
                        // Show first letter of department name if logo fails to load
                        return Text(
                          department.name[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: depColor,
                          ),
                        );
                      },
                    )
                  : Text(
                      department.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: depColor,
                      ),
                    ),
            ),
            const SizedBox(height: 12),

            // Divider
            Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: depColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),

            // Department name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                department.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),

            // Department code
            Text(
              department.code,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
