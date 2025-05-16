import 'package:flutter/material.dart';
import 'dart:io';
import 'package:demo_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  // Variables to store user information
  File? _profileImage;
  bool _isLoading = false;
  bool _isEditing = false;
  User? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Get user information from SharedPreferences
    String? firstName = prefs.getString("firstName");
    String? lastName = prefs.getString("lastName");
    String? email = prefs.getString("email");
    String? token = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("renewalToken");
    String? phone = prefs.getString("phone") ?? '';
    
    _user = User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      accessToken: token,
      refreshToken: refreshToken,
    );
    
    // Update controllers with user data
    _firstNameController.text = firstName ?? '';
    _lastNameController.text = lastName ?? '';
    _emailController.text = email ?? '';
    _phoneController.text = phone;
    
    setState(() {
      _isLoading = false;
    });
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  // Show options to pick image
  void _showImageSourceOptions() {
    if (!_isEditing) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Profile Picture',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  _buildImageSourceOption(
                    icon: Icons.image,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_profileImage != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _profileImage = null;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text('Remove Current Image'),
                ),
            ],
          ),
        );
      },
    );
  }

  // Build image source option button
  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade50,
            child: Icon(icon, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 10),
          Text(title),
        ],
      ),
    );
  }

  // Save profile information
  Future<void> _saveProfileInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Update user information in SharedPreferences
        await prefs.setString("firstName", _firstNameController.text);
        await prefs.setString("lastName", _lastNameController.text);
        await prefs.setString("email", _emailController.text);
        await prefs.setString("phone", _phoneController.text);
        
        // Update user object
        _user = User(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          accessToken: _user?.accessToken,
          refreshToken: _user?.refreshToken,
        );
        
        // Exit edit mode
        _toggleEditMode();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Build profile header with image and name
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            // Background decoration
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            
            // Profile image and name
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isEditing ? _showImageSourceOptions : null,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _profileImage != null
                                  ? FileImage(_profileImage!)
                                  : null,
                              child: _profileImage == null
                                  ? Text(
                                      _user?.firstName != null && _user?.firstName!.isNotEmpty == true
                                          ? _user!.firstName![0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing)
                      Text(
                        "${_user?.firstName ?? ''} ${_user?.lastName ?? ''}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (!_isEditing && _user?.email != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _user!.email!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build edit/save buttons
  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isEditing ? _saveProfileInfo : _toggleEditMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: _isEditing ? Colors.green : Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_isEditing ? Icons.save : Icons.edit),
              const SizedBox(width: 8),
              Text(
                _isEditing ? 'Save Changes' : 'Edit Profile',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build user info detail item
  Widget _buildInfoDetailItem({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: _isEditing
          ? TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: validator ?? (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            )
          : ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, color: Colors.blue),
              ),
              title: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              subtitle: Text(
                controller.text.isNotEmpty ? controller.text : 'Not provided',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleEditMode,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header with image and name
                    _buildProfileHeader(),
                    
                    const SizedBox(height: 20),
                    
                    // Personal Information Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Personal Information',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 30),
                              _buildInfoDetailItem(
                                icon: Icons.badge,
                                label: 'First Name',
                                controller: _firstNameController,
                              ),
                              _buildInfoDetailItem(
                                icon: Icons.badge_outlined,
                                label: 'Last Name',
                                controller: _lastNameController,
                              ),
                              _buildInfoDetailItem(
                                icon: Icons.email,
                                label: 'Email Address',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),
                              _buildInfoDetailItem(
                                icon: Icons.phone,
                                label: 'Phone Number',
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Action Button (Edit/Save)
                    _buildActionButton(),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}

class ImagePicker {
  Future<XFile?> pickImage({
    required ImageSource source,
    int? imageQuality,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    // Simulate image picking
    return XFile('path/to/image.jpg');
  }
}

class XFile {
  XFile(String s) : path = s;

  final String path;
}

class ImageSource {
  static const camera = ImageSource._('camera');
  static const gallery = ImageSource._('gallery');

  final String source;

  const ImageSource._(this.source);
}