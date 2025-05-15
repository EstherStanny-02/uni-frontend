// ignore: file_names
import 'package:demo_app/pages/profile_screen.dart';
import 'package:demo_app/pages/settings_screen.dart';
import 'package:demo_app/pages/messages_screen.dart';
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

//appBar Codes for home screen:
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
                MaterialPageRoute(builder: (context) => const MessageScreen()),
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
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.orange),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsScreen()));
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
                        child: const Text("Logout",
                            style: TextStyle(color: Colors.red)),
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
                  mainAxisSpacing: 10,

                  children: [
                    _buildInfoBox(
                      "Bachelor Degree in Information and Technology",
                      Icons.computer,
                      "Active Course",
                      Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ItDetails(),
                          ),
                        );
                      },
                    ),
                    _buildInfoBox(
                      "Bachelor Degree in Business Administration",
                      Icons.business,
                      "Active Course",
                      Colors.green,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BaDetails(),
                          ),
                        );
                      },
                    ),
                    _buildInfoBox(
                      "Bachelor Degree in Human Resources",
                      Icons.book,
                      "Active course",
                      Colors.purple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HrDetails(),
                          ),
                        );
                      },
                    ),
                    _buildInfoBox("Bachelor Degree in Shipping", Icons.water,
                        "Active Course", Colors.blue, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ShippingDetails()));
                    }),
                    _buildInfoBox(
                        "Bachelor Degree in Railway",
                        Icons.emoji_transportation,
                        "Active Course",
                        Colors.brown, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RailwayDetails()));
                    }),
                    _buildInfoBox(
                        "Bachelor Degree in Mechanical Engineering",
                        Icons.engineering,
                        "Active Course",
                        Colors.orangeAccent, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MechanicalDetails()));
                    }),
                    _buildInfoBox(
                        "Bachelor Degree in Automobile Engineering",
                        Icons.engineering,
                        "Active Course",
                        Colors.orangeAccent, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AutoMobile()));
                    }),
                    _buildInfoBox(
                        "Bachelor Degree in Computer Science",
                        Icons.computer_outlined,
                        "Active Course",
                        Colors.blue, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Marketing(),
                        ),
                      );
                    })
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
  Widget _buildInfoBox(String title, IconData icon, String subtitle,
      Color color, VoidCallback onTap) {
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

class Marketing extends StatelessWidget {
  const Marketing({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
    );
  }
}

class AutoMobile extends StatelessWidget {
  const AutoMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
    );
  }
}

//  MEdetails codes:
class MechanicalDetails extends StatelessWidget {
  const MechanicalDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
    );
  }
}

class RailwayDetails extends StatelessWidget {
  const RailwayDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
    );
  }
}

// ITdetails Codes:
class ItDetails extends StatelessWidget {
  const ItDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
    );
  }
}

//BAdetails Codes:
class BaDetails extends StatelessWidget {
  const BaDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
      ),
    );
  }
}

//  HRdetails Codes:
class HrDetails extends StatelessWidget {
  const HrDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
      ),
    );
  }
}

// ShippingDetails codes:
class ShippingDetails extends StatelessWidget {
  const ShippingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
      ),
    );
  }
}
