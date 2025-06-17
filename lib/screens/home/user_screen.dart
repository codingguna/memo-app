// lib/screens/home/users_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../models/user.dart';
import '../../core/theme/app_theme.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final ApiService _apiService = ApiService();
  List<User> _users = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
 
  Future<void> _loadUsers() async {
  try {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final hospitalId = authProvider.hospital?.id;

    if (hospitalId != null) {
      final response = await _apiService.getUsers(hospitalId);
      
      // Debug: Print response structure
      print('API Response type: ${response.runtimeType}');
      print('API Response: $response');
      
      List<dynamic> usersData = [];
      
      // Since API service returns Map<String, dynamic>, handle accordingly
      if (response is Map<String, dynamic>) {
        // Check various possible keys for the users array
        if (response.containsKey('results')) {
          usersData = response['results'] as List<dynamic>? ?? [];
        } else if (response.containsKey('users')) {
          usersData = response['users'] as List<dynamic>? ?? [];
        } else if (response.containsKey('data')) {
          usersData = response['data'] as List<dynamic>? ?? [];
        } else {
          // If the response itself might be the users data
          // Check if any value in the map is a list
          for (var value in response.values) {
            if (value is List<dynamic>) {
              usersData = value;
              break;
            }
          }
        }
      }
      
      print('Users data length: ${usersData.length}');
      
      setState(() {
        _users = usersData.map((json) {
          if (json is Map<String, dynamic>) {
            return User.fromJson(json);
          } else {
            throw Exception('Invalid user data format: ${json.runtimeType}');
          }
        }).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = 'Hospital ID not found';
        _isLoading = false;
      });
    }
  } catch (e) {
    print('Error loading users: $e');
    setState(() {
      _error = 'Failed to load users: ${e.toString()}';
      _isLoading = false;
    });
  }
}
  
  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    
    return _users.where((user) {
      return user.institutionId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.role.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             user.phoneNumber.contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search users...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorWidget()
                    : _filteredUsers.isEmpty
                        ? _buildEmptyWidget()
                        : _buildUsersList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComingSoon('Add User'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorColor,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _error!,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            onPressed: _loadUsers,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _searchQuery.isEmpty ? 'No users found' : 'No users match your search',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                });
              },
              child: const Text('Clear search'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getUserAvatarColor(user),
                child: Text(
                  user.institutionId.isNotEmpty 
                      ? user.institutionId[0].toUpperCase() 
                      : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                'ID: ${user.institutionId}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.role),
                  Text(
                    user.phoneNumber,
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  if (user.currentBlockName != null)
                    Text(
                      'Block: ${user.currentBlockName}',
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPermissionBadges(user),
                  PopupMenuButton<String>(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) => _handleUserAction(value, user),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPermissionBadges(User user) {
    List<String> permissions = [];
    if (user.isSuperuser) permissions.add('Super');
    if (user.isApprover) permissions.add('Approver');
    if (user.isResponder) permissions.add('Responder');
    if (user.isCreator) permissions.add('Creator');

    if (permissions.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 2,
      children: permissions.take(2).map((permission) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            permission,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getUserAvatarColor(User user) {
    if (user.isSuperuser) return Colors.red;
    if (user.isApprover) return Colors.green;
    if (user.isResponder) return Colors.blue;
    if (user.isCreator) return Colors.orange;
    return AppTheme.primaryColor;
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      case 'edit':
        _showComingSoon('Edit User');
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('User Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Institution ID:', user.institutionId),
              _buildDetailRow('Role:', user.role),
              _buildDetailRow('Phone:', user.phoneNumber),
              if (user.currentBlockName != null)
                _buildDetailRow('Current Block:', user.currentBlockName!),
              const SizedBox(height: AppSpacing.md),
              const Text('Permissions:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: [
                  if (user.isSuperuser) _buildPermissionChip('Superuser'),
                  if (user.isApprover) _buildPermissionChip('Approver'),
                  if (user.isResponder) _buildPermissionChip('Responder'),
                  if (user.isCreator) _buildPermissionChip('Creator'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildPermissionChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
      labelStyle: const TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 12,
      ),
    );
  }

  void _showDeleteConfirmation(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user ${user.institutionId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            onPressed: () {
              Navigator.of(context).pop();
              _showComingSoon('Delete User');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}