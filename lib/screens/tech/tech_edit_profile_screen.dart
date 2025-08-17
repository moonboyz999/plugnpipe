import 'package:flutter/material.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import 'tech_home_screen.dart';
import 'tech_notification_screen.dart';
import 'tech_profile_screen.dart';
import '../../services/user_data_service.dart';

class TechEditProfileScreen extends StatefulWidget {
  const TechEditProfileScreen({super.key});

  @override
  State<TechEditProfileScreen> createState() => _TechEditProfileScreenState();
}

class _TechEditProfileScreenState extends State<TechEditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  String? profileImagePath;
  final UserDataService _userDataService = UserDataService();

  @override
  void initState() {
    super.initState();
    // Load current user data
    nameController.text = _userDataService.fullName.isNotEmpty
        ? _userDataService.fullName
        : 'Tech User';
    emailController.text = _userDataService.email.isNotEmpty
        ? _userDataService.email
        : 'tech@plugnpipe.com';
    phoneController.text = _userDataService.phoneNumber.isNotEmpty
        ? _userDataService.phoneNumber
        : '+1234567890';
    idController.text = _userDataService.studentId.isNotEmpty
        ? _userDataService.studentId
        : 'TECH001';
    profileImagePath = _userDataService.profileImagePath;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    idController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    // Update user data service
    _userDataService.updateUserData(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      studentId: idController.text.trim(),
      profileImagePath: profileImagePath,
    );

    // Save logic (e.g., send to backend or local storage)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved successfully!'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'View Profile',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TechProfileScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, you would use image_picker here
                _selectMockImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, you would use image_picker here
                _selectMockImage();
              },
            ),
            if (profileImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Remove Photo'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    profileImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _selectMockImage() {
    // Mock image selection - in a real app, this would use image_picker
    setState(() {
      profileImagePath = 'assets/images/tech_avatar.png';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Image selected!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFA726), Color(0xFFFFD600)],
              begin: Alignment.topLeft,
              end: Alignment.topRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.brown),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown,
                      ),
                    ),
                    Text(
                      'Update your information',
                      style: TextStyle(fontSize: 14, color: Colors.brown),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Section
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _showImageOptions,
                      child: Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFA726),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(20),
                            child: profileImagePath != null
                                ? ClipOval(
                                    child: Image.asset(
                                      profileImagePath!,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.engineering,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFA726),
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(8),
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
                    const Text(
                      'Tap to change profile picture',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Personal Information Form
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Full Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          Icons.person,
                          color: Color(0xFFFFA726),
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFA726)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFFFFA726)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFA726)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Phone Number
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone, color: Color(0xFFFFA726)),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFA726)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Technician ID
                    TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: 'Technician ID',
                        prefixIcon: Icon(
                          Icons.engineering,
                          color: Color(0xFFFFA726),
                        ),
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFFFA726)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA726),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: TechNavBar(
        currentIndex: 2, // Profile tab
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TechHomeScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechNotificationScreen(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TechProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
