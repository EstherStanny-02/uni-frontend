import 'package:flutter/material.dart';
import 'package:demo_app/session/user_preferences.dart';
import 'package:demo_app/pages/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Settings Screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String firstName = '';
  String lastName = '';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      firstName = prefs.getString('firstName') ?? '';
      lastName = prefs.getString('lastName') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  bool _notificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _isDarkMode = false;
  String _selectedLanguage = 'English';
  String _selectedFontSize = 'Medium';
  bool _dataUsageReduction = false;
  String _selectedAppearanceMode = 'System default';
  final UserPreferences _userPreferences = UserPreferences();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Container(
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "$firstName $lastName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account Settings
          _buildSectionHeader("Account Settings"),
          _buildSettingsTile(
            icon: Icons.lock,
            title: "Change Password",
            subtitle: "Update your security credentials",
            onTap: () {
              _showChangePasswordDialog(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.email,
            title: "Email Address",
            subtitle: email,
            onTap: () {
              _showChangeEmailDialog(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.phone_android,
            title: "Phone Number",
            subtitle: phone,
            onTap: () {
              _showChangePhoneDialog(context);
            },
          ),
          const SizedBox(height: 10),

          // Notifications
          _buildSectionHeader("Notifications"),
          SwitchListTile(
            title: const Text("Push Notifications"),
            subtitle: const Text("Receive alerts and updates"),
            secondary: const Icon(Icons.notifications),
            value: _notificationsEnabled,
            activeColor: Colors.blue[800],
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            subtitle: const Text("Receive updates via email"),
            secondary: const Icon(Icons.mail),
            value: _emailNotificationsEnabled,
            activeColor: Colors.blue[800],
            onChanged: (value) {
              setState(() {
                _emailNotificationsEnabled = value;
              });
            },
          ),
          _buildSettingsTile(
            icon: Icons.notifications_active,
            title: "Notification Preferences",
            subtitle: "Customize which notifications you receive",
            onTap: () {
              _showNotificationPreferencesDialog(context);
            },
          ),
          const SizedBox(height: 10),

          // Appearance
          _buildSectionHeader("Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode"),
            subtitle: const Text("Switch between light and dark theme"),
            secondary: const Icon(Icons.dark_mode),
            value: _isDarkMode,
            activeColor: Colors.blue[800],
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // Here you would implement theme change logic
            },
          ),
          _buildSettingsTile(
            icon: Icons.format_size,
            title: "Font Size",
            subtitle: _selectedFontSize,
            onTap: () {
              _showFontSizeSelection(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.palette,
            title: "Theme Mode",
            subtitle: _selectedAppearanceMode,
            onTap: () {
              _showAppearanceModeSelection(context);
            },
          ),
          const SizedBox(height: 10),

          // Privacy & Data
          _buildSectionHeader("Privacy & Data"),
          SwitchListTile(
            title: const Text("Data Saving Mode"),
            subtitle: const Text("Reduce data usage when on mobile network"),
            secondary: const Icon(Icons.data_saver_on),
            value: _dataUsageReduction,
            activeColor: Colors.blue[800],
            onChanged: (value) {
              setState(() {
                _dataUsageReduction = value;
              });
            },
          ),
          _buildSettingsTile(
            icon: Icons.storage,
            title: "Clear Cache",
            subtitle: "Free up storage space",
            onTap: () {
              _showClearCacheDialog(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            subtitle: "Review our privacy terms",
            onTap: () {
              // Navigate to privacy policy
              _showPrivacyPolicyDialog(context);
            },
          ),
          const SizedBox(height: 10),

          // General
          _buildSectionHeader("General"),
          _buildSettingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: _selectedLanguage,
            onTap: () {
              _showLanguageSelection(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: "Help & Support",
            subtitle: "Get assistance with the app",
            onTap: () {
              _showHelpSupportDialog(context);
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "App information and version",
            onTap: () {
              _showAboutAppDialog(context);
            },
          ),
          const SizedBox(height: 20),

          // Logout button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                _showLogoutDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Logout",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const Divider(thickness: 1.5),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Current Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Confirm New Password",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Validate and update password
              if (newPasswordController.text == confirmPasswordController.text) {
                // Update password logic would go here
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    emailController.text = email;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Email Address"),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: "Email Address",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Update email logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email updated successfully')),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showChangePhoneDialog(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    phoneController.text = phone;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Change Phone Number"),
        content: TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: "Phone Number",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Update phone logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number updated successfully')),
              );
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _showNotificationPreferencesDialog(BuildContext context) {
    bool coursesNotifications = true;
    

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Notification Preferences"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  title: const Text("Course Updates"),
                  value: coursesNotifications,
                  onChanged: (value) {
                    setState(() {
                      coursesNotifications = value!;
                    });
                  },
                ),
              ],
            ),

            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  // Save notification preferences
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification preferences updated')),
                  );
                },
                child: const Text("Save"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFontSizeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select Font Size",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const Divider(),
          _buildFontSizeOption(context, "Small"),
          _buildFontSizeOption(context, "Medium"),
          _buildFontSizeOption(context, "Large"),
          _buildFontSizeOption(context, "Extra Large"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFontSizeOption(BuildContext context, String size) {
    return ListTile(
      title: Text(size),
      trailing: _selectedFontSize == size
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _selectedFontSize = size;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showAppearanceModeSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select Appearance Mode",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          _buildAppearanceOption(context, "Light"),
          _buildAppearanceOption(context, "Dark"),
          _buildAppearanceOption(context, "System default"),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAppearanceOption(BuildContext context, String mode) {
    return ListTile(
      title: Text(mode),
      trailing: _selectedAppearanceMode == mode
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _selectedAppearanceMode = mode;
          // If light or dark is explicitly selected, update the dark mode toggle
          if (mode == "Light") {
            _isDarkMode = false;
          } else if (mode == "Dark") {
            _isDarkMode = true;
          }
        });
        Navigator.pop(context);
      },
    );
  }

  void _showLanguageSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Select Language",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(),
          _buildLanguageOption(context, "English"),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? const Icon(Icons.check, color: Colors.blue)
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Cache"),
        content: const Text(
          "This will free up storage space by clearing cached data. Your personal settings will not be affected.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear cache logic
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Privacy Policy"),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "University App Privacy Policy",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Last updated: May 15, 2025",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: 12),
              Text(
                "This privacy policy describes how University App collects, uses, and shares your information when you use our mobile application.",
              ),
              SizedBox(height: 12),
              Text(
                "The full privacy policy can be found on our website. This is just a summary for your convenience.",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.email),
              title: Text("Email Support"),
              subtitle: Text("uni@schooling.edu"),
            ),
            const ListTile(
              leading: Icon(Icons.phone),
              title: Text("Phone Support"),
              subtitle: Text("+255-688-016-108"),
            ),
            const ListTile(
              leading: Icon(Icons.help_outline),
              title: Text("FAQ"),
              subtitle: Text("View Frequently Asked Questions"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: "University App",
      applicationVersion: "2.1.0",
      applicationIcon: const FlutterLogo(size: 50),
      applicationLegalese: "© 2025 University Inc. All rights reserved.",
      children: [
        const SizedBox(height: 20),
        const Text(
          "University App is designed to help students manage their academic life, access course materials, communicate with instructors, and stay updated on campus events.",
        ),
        const SizedBox(height: 20),
        const Text(
          "Development :Esther Mollel",
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}