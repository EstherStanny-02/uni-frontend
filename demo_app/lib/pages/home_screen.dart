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
import 'package:provider/provider.dart';

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
  final TextEditingController _searchController = TextEditingController();
  User? _currentUser;
  final UserPreferences _userPreferences = UserPreferences();

  List<Department> _filteredDepartments = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  _loadUserData() async {
    User user = await _userPreferences.getUser();
    setState(() {
      _currentUser = user;
    });
  }

  void _searchDepartments(String query, List<Department> departments) {
    if (query.isEmpty) {
      setState(() {
        _filteredDepartments = departments;
      });
      return;
    }

    setState(() {
      _filteredDepartments = departments
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
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              _userPreferences.removeUser();
              Navigator.pop(context);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getDepartmentColor(String name) {
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
                  final departmentProvider =
                      Provider.of<DepartmentProvider>(context, listen: false);
                  _searchDepartments(value, departmentProvider.departments);
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
                  final departmentProvider =
                      Provider.of<DepartmentProvider>(context, listen: false);
                  _filteredDepartments = departmentProvider.departments;
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
              child: Consumer<DepartmentProvider>(
                builder: (context, departmentProvider, child) {
                  // Initialize filtered departments when data is loaded
                  if (_filteredDepartments.isEmpty &&
                      departmentProvider.departments.isNotEmpty) {
                    _filteredDepartments = departmentProvider.departments;
                  }

                  switch (departmentProvider.dataStatus) {
                    case DataStatus.Loading:
                      return const Center(child: CircularProgressIndicator());

                    case DataStatus.Error:
                      return Center(
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
                            Text(
                              departmentProvider.errorMessage,
                              style: TextStyle(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                departmentProvider.refreshDepartments();
                              },
                              child: const Text("Try Again"),
                            ),
                          ],
                        ),
                      );

                    case DataStatus.Empty:
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined,
                                color: Colors.grey[400], size: 60),
                            const SizedBox(height: 16),
                            Text(
                              "No departments found",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                departmentProvider.refreshDepartments();
                              },
                              child: const Text("Refresh"),
                            ),
                          ],
                        ),
                      );

                    case DataStatus.Loaded:
                      final displayDepartments = _filteredDepartments.isEmpty
                          ? departmentProvider.departments
                          : _filteredDepartments;

                      if (displayDepartments.isEmpty &&
                          _searchController.text.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off,
                                  color: Colors.grey[400], size: 60),
                              const SizedBox(height: 16),
                              Text(
                                "No departments found for '${_searchController.text}'",
                                style: TextStyle(
                                    fontSize: 18, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "All Departments",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${displayDepartments.length} Departments${kIsWeb ? " (Web)" : ""}",
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
                                  await departmentProvider.refreshDepartments();
                                  setState(() {
                                    _filteredDepartments =
                                        departmentProvider.departments;
                                  });
                                },
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: displayDepartments.length,
                                  itemBuilder: (context, index) {
                                    final department =
                                        displayDepartments[index];
                                    return _buildDepartmentCard(department);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentCard(Department department) {
    Color depColor = _getDepartmentColor(department.name);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DepartmentScreenContent(
              courses: department.courses,
              departmentName: department.name,
            ),
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
            // Department logo in circular avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: depColor.withOpacity(0.2),
              child: department.logo != null && department.logo!.isNotEmpty
                  ? Image.network(
                      department.logo!,
                      errorBuilder: (context, error, stackTrace) {
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