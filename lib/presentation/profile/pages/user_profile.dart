import 'package:flutter/material.dart';
import 'package:my_project/domain/repository/sheet.dart';
import 'package:my_project/main.dart';
import 'package:my_project/presentation/main/main_tab_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/domain/repository/auth.dart';
import 'package:my_project/service_locator.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String fullName = '';
  String email = '';
  String userId = '';
  bool hasSheet = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final loadedUserId = prefs.getString('userId') ?? '';
    setState(() {
      fullName = prefs.getString('fullName') ?? 'Người dùng';
      email = prefs.getString('email') ?? 'Chưa có email';
      userId = loadedUserId;
    });
    if (loadedUserId.isNotEmpty) {
      await _checkSheetStatus();
    }
  }

  Future<void> _checkSheetStatus() async {
    final exists = await sl<SheetRepository>().checkSheetExists(userId);
    if (mounted) {
      setState(() => hasSheet = exists);
    }
  }

  Future<void> _showAddSheetDialog() async {
    final sheetIdController = TextEditingController();
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Google Sheet ID'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: sheetIdController,
                decoration: const InputDecoration(
                  labelText: 'Sheet ID',
                  hintText: 'Enter your Google Sheet ID',
                  border: OutlineInputBorder(),
                ),
              ),
              if (isLoading) const CircularProgressIndicator(),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setState(() => isLoading = true);
                      try {
                        final result = await sl<SheetRepository>().addSheetId(
                          sheetIdController.text,
                          userId, // Use actual userId
                        );
                        result.fold(
                          (error) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error)),
                          ),
                          (success) {
                            setState(() => hasSheet = true);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sheet ID added successfully')),
                            );
                          },
                        );
                      } finally {
                        if (mounted) {
                          setState(() => isLoading = false);
                        }
                      }
                    },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSync() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync transactions?'),
        content: const Text('Do you want to sync transactions with Google Sheet now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sync'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
      try {
        final result = await sl<SheetRepository>().syncSheet(userId);
        Navigator.pop(context); // Close loading dialog
        result.fold(
          (error) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          ),
          (success) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sync successful')),
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grayLight.withOpacity(0.3),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'My information',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainTabView()),
              (Route<dynamic> route) => false,
            );
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildMenuSection(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(
              Icons.person_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.grayLight.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.account_circle_outlined,
            title: 'Personal information',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notification',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Security',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: hasSheet ? Icons.sync : Icons.add,
            title: hasSheet ? 'Sync Now' : 'Add Google Sheet',
            onTap: hasSheet ? _handleSync : _showAddSheetDialog,
          ),
          const Divider(height: 24, color: Colors.grey),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Log out',
            onTap: _handleLogout,
            textColor: AppColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (textColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor ?? AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor ?? AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textColor ?? AppColors.textLight,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textLight)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
              final result = await sl<AuthRepository>().logout();
              if (mounted) {
                Navigator.pop(context); // Close loading
                result.fold(
                  (error) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                      backgroundColor: AppColors.error,
                    ),
                  ),
                  (success) => navigationKey.currentState
                      ?.pushNamedAndRemoveUntil('/signin', (route) => false),
                );
              }
            },
            child:
                const Text('Log out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}