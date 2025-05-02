// ignore: file_names
import 'package:demo_app/pages/ProfileScreen.dart';
import 'package:demo_app/pages/SettingsScreen.dart';
import 'package:demo_app/pages/messages.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// HomeScreen Codes:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

//Appbar Codes for home screen:
class HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false; // check if search is active
  final TextEditingController _searchController = TextEditingController(); 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.blue[800],
  centerTitle: !_isSearching,
  title: _isSearching
      ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
        )
      : const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
  actions: [
    IconButton(
      onPressed: () {
        Navigator.push(
          context,
           MaterialPageRoute(builder: (context)=>const MessageScreen()),
           );
      },
      icon: const Icon(Icons.message),
    ),

    // IconButton(
    //   onPressed: () {
    //     Navigator.push(
    //       context,
    //        MaterialPageRoute(builder: (context)=>const NotificationsScreen()),
    //        );
    //   },
    //   icon: const Icon(Icons.notifications),
    // ),
    IconButton(
      onPressed: () {
        setState(() {
          if (_isSearching) {
            _searchController.clear();
          }
          _isSearching = !_isSearching;
        });
      },
      icon: Icon(_isSearching ? Icons.cancel : Icons.search),
    ),
  ],
),


// drawer codes
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[800]),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Username: Esther",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "email: user@example.com",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text("Home"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
              },
            ),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to log out?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text("Logout", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),

      //Home Screen with Boxes Codes
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hi! Welcome,',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

    // Grid of Boxes Codes
 Expanded(
  child: GridView.count(
    crossAxisCount: 2, // 2 boxes per row
    crossAxisSpacing: 10,
    mainAxisSpacing:10,
   
    children: [
      _buildInfoBox(
        "Courses and Programmes",
        Icons.book,
        "Active Courses",
        Colors.blue,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CoursesScreen(),
            ),
          );
        },
      ),

      _buildInfoBox(
        "Lecture notes",
        Icons.assignment,
        "Notes",
        Colors.green,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotesScreen(),
            ),
          );
        },
      ),
      _buildInfoBox(
        "Assignments",
        Icons.notes,
        "3 Pending",
        Colors.purple,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AssignmentsScreen(),
            ),
          );
        },
      ),
    ],
  ),
),
           ],
          ),
        ),
      ),
    );
  }

  //Function to Build Each Box Codes
  Widget _buildInfoBox(String title, IconData icon, String subtitle, Color color, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color, width: 2),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    ),
  );
}
 }
 
 




 // CourseScreen Codes:
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses and Schedule Management'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Courses and Schedule Content',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

 // NotesScreen Codes:
class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecture Notes'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Notes Content',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}

 //  AssignmentsScreen Codes:
class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: Colors.purple,
      ),
      body: const Center(
        child: Text(
          'Assignments Content',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}




