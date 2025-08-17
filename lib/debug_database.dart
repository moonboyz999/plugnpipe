import 'package:flutter/material.dart';
import '../services/local_database.dart';

class DatabaseDebugWidget extends StatefulWidget {
  @override
  _DatabaseDebugWidgetState createState() => _DatabaseDebugWidgetState();
}

class _DatabaseDebugWidgetState extends State<DatabaseDebugWidget> {
  Map<String, List<Map<String, dynamic>>> _databaseContent = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkDatabaseContent();
  }

  Future<void> _checkDatabaseContent() async {
    try {
      final db = LocalDatabase.instance;
      
      final users = await db.select('users');
      final requests = await db.select('requests');
      final tasks = await db.select('tasks');
      final notifications = await db.select('notifications');
      
      setState(() {
        _databaseContent = {
          'users': users,
          'requests': requests,
          'tasks': tasks,
          'notifications': notifications,
        };
        _isLoading = false;
      });
      
      print('=== DATABASE CONTENT ===');
      print('Users: ${users.length}');
      print('Requests: ${requests.length}');
      print('Tasks: ${tasks.length}');
      print('Notifications: ${notifications.length}');
      
      for (var user in users) {
        print('User: ${user['name']} (${user['role']})');
      }
      
      for (var request in requests) {
        print('Request: ${request['title']} - ${request['status']}');
      }
      
    } catch (e) {
      print('Error checking database: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Database Debug')),
      body: ListView(
        children: _databaseContent.entries.map((entry) {
          return ExpansionTile(
            title: Text('${entry.key.toUpperCase()} (${entry.value.length} items)'),
            children: entry.value.map((item) {
              return ListTile(
                title: Text(item.toString()),
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}
