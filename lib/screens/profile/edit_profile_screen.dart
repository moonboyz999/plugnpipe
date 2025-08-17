import 'package:flutter/material.dart';
import '../../widgets/main_bottom_nav_bar.dart';
import '../student/student_home_screen.dart';
import '../support/support_chat_screen.dart';
import '../common/notification_screen.dart';
import 'student_profile_screen.dart';
import '../../services/user_data_service.dart';

// To use real image picking, add this to pubspec.yaml:
// dependencies:
//   image_picker: ^1.0.4
//
// Then import: import 'package:image_picker/image_picker.dart';
// And use: final ImagePicker _picker = ImagePicker();

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
    nameController.text = _userDataService.fullName;
    emailController.text = _userDataService.email;
    phoneController.text = _userDataService.phoneNumber;
    idController.text = _userDataService.studentId;
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

  void _pickImage() async {
    // Show bottom sheet with options
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 200,
          child: Column(
            children: [
              const Text(
                'Change Profile Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(Icons.camera_alt, 'Camera', () {
                    Navigator.pop(context);
                    _selectImageFromCamera();
                  }),
                  _buildImageOption(Icons.photo_library, 'Gallery', () {
                    Navigator.pop(context);
                    _selectImageFromGallery();
                  }),
                  if (profileImagePath != null)
                    _buildImageOption(Icons.delete, 'Remove', () {
                      Navigator.pop(context);
                      _removeImage();
                    }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFA726),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _selectImageFromCamera() {
    // Simulate camera selection
    setState(() {
      profileImagePath = 'camera_image'; // Placeholder for camera image
    });
    _userDataService.updateProfileImage(profileImagePath);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo taken from camera!'),
        backgroundColor: Color(0xFFFFA726),
      ),
    );
  }

  void _selectImageFromGallery() {
    // Simulate gallery selection
    setState(() {
      profileImagePath = 'gallery_image'; // Placeholder for gallery image
    });
    _userDataService.updateProfileImage(profileImagePath);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo selected from gallery!'),
        backgroundColor: Color(0xFFFFA726),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      profileImagePath = null;
    });
    _userDataService.updateProfileImage(null);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile photo removed'),
        backgroundColor: Colors.grey,
      ),
    );
  }

  void _saveProfile() {
    // Validate email format
    if (!emailController.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate phone number (basic check)
    if (phoneController.text.trim().length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Save data to the service
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
                builder: (context) => const StudentProfileScreen(),
              ),
            );
          },
        ),
      ),
    );
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
                  icon: const Icon(Icons.arrow_back, color: Colors.brown),
                  onPressed: () => Navigator.of(context).pop(),
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
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFFFFA726),
                          backgroundImage: profileImagePath != null
                              ? null // We'll use a different approach for real images
                              : null,
                          child: profileImagePath == null
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 50,
                                )
                              : Stack(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green[100],
                                        border: Border.all(
                                          color: Colors.green,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 40,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 5,
                                      left: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          profileImagePath == 'camera_image'
                                              ? 'Camera'
                                              : 'Gallery',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA726),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Profile Picture',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Change Photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFA726),
                        side: const BorderSide(color: Color(0xFFFFA726)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(),
                      ),
                      controller: nameController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      controller: emailController,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      controller: phoneController,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Student ID',
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(),
                      ),
                      controller: idController,
                      readOnly: true,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: StudentNavBar(
        currentIndex: 3,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentHomeScreen(),
                ),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SupportChatScreen(),
                ),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationScreen(),
                ),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentProfileScreen(),
                ),
              );
              break;
          }
        },
      ),
    );
  }
}
