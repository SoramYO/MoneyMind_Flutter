import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text('Thông tin của tôi'),
        backgroundColor: Colors.green, // Set the background color to green
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainTabView()),
              (Route<dynamic> route) => false,
            ); // Navigate directly to HomePage
          },
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildMenuSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.account_circle_outlined,
            title: 'Thông tin cá nhân',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Thông báo',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.security_outlined,
            title: 'Bảo mật',
            onTap: () {},
          ),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            onTap: _handleLogout,
            textColor: Colors.red,
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
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Đóng dialog
              
              // Hiển thị loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );
              
              // Thực hiện đăng xuất
              final result = await sl<AuthRepository>().logout();
              
              if (mounted) {
                Navigator.pop(context); // Đóng loading
                
                result.fold(
                  (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.toString())),
                    );
                  },
                  (success) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/signin',
                      (route) => false,
                    );
                  },
                );
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}