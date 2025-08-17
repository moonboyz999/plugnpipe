import 'package:flutter/material.dart';
import '../../services/local_supabase_helper.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final LocalSupabaseHelper _dbHelper = LocalSupabaseHelper();
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      setState(() => _isLoading = true);
      
      // Get all users
      final allUsers = await _dbHelper.getUsers();
      
      // Filter based on selected filter
      final filteredUsers = allUsers.where((user) {
        final role = user['role'] as String? ?? 'student';
        switch (_selectedFilter) {
          case 'students':
            return role == 'student';
          case 'technicians':
            return role == 'technician';
          case 'admins':
            return role == 'admin';
          default:
            return true;
        }
      }).toList();

      if (mounted) {
        setState(() {
          _users = filteredUsers;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addUser() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const AddUserDialog(),
    );
    
    if (result != null) {
      try {
        await _dbHelper.createUser(result);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _dbHelper.deleteUser(userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User deleted successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadUsers();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting user: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentCount = _users.where((user) => user['role'] == 'student').length;
    final technicianCount = _users.where((user) => user['role'] == 'technician').length;
    final adminCount = _users.where((user) => user['role'] == 'admin').length;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.people,
                    size: 32,
                    color: Color(0xFFFFA726),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'User Management',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _loadUsers,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                  ElevatedButton.icon(
                    onPressed: _addUser,
                    icon: const Icon(Icons.add),
                    label: const Text('Add User'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Stats Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard('Students', studentCount.toString(), Colors.blue),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Technicians', technicianCount.toString(), Colors.green),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard('Admins', adminCount.toString(), Colors.purple),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All Users'),
                    const SizedBox(width: 8),
                    _buildFilterChip('students', 'Students'),
                    const SizedBox(width: 8),
                    _buildFilterChip('technicians', 'Technicians'),
                    const SizedBox(width: 8),
                    _buildFilterChip('admins', 'Admins'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Users List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _users.isEmpty
                      ? const Center(
                          child: Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final user = _users[index];
                            return _buildUserCard(user);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilter = value;
          });
          _loadUsers();
        }
      },
      selectedColor: const Color(0xFFFFA726).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFFFFA726),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String name = user['name'] ?? 'Unknown User';
    final String email = user['email'] ?? 'No email';
    final String role = user['role'] ?? 'student';
    final String userId = user['id'] ?? '';
    final String phone = user['phone'] ?? 'No phone';
    final String roomNumber = user['room_number'] ?? 'N/A';

    Color roleColor;
    IconData roleIcon;
    switch (role) {
      case 'admin':
        roleColor = Colors.purple;
        roleIcon = Icons.admin_panel_settings;
        break;
      case 'technician':
        roleColor = Colors.green;
        roleIcon = Icons.engineering;
        break;
      default:
        roleColor = Colors.blue;
        roleIcon = Icons.school;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withValues(alpha: 0.1),
                  child: Icon(roleIcon, color: roleColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: roleColor,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteUser(userId, name);
                    } else if (value == 'edit') {
                      // TODO: Implement edit user functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit user functionality coming soon!')),
                      );
                    }
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // User Details
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (role == 'student')
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.home, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Room $roomNumber',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roomController = TextEditingController();
  String _selectedRole = 'student';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text('Student')),
                    DropdownMenuItem(value: 'technician', child: Text('Technician')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value!;
                    });
                  },
                ),
                if (_selectedRole == 'student') ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _roomController,
                    decoration: const InputDecoration(
                      labelText: 'Room Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final userData = {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text,
                'password': _passwordController.text,
                'role': _selectedRole,
                if (_selectedRole == 'student') 'room_number': _roomController.text,
              };
              Navigator.pop(context, userData);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            foregroundColor: Colors.white,
          ),
          child: const Text('Add User'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _roomController.dispose();
    super.dispose();
  }
}
