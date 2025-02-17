import 'package:flutter/material.dart';
import 'package:my_project/presentation/transaction/pages/transaction_edit_add_view.dart';
import '../home/pages/home.dart';
import '../transaction/pages/transaction_list_view.dart';
import '../../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../profile/pages/user_profile.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  Widget currentTabView = const HomePage();
  String? userId;

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentTabView,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectTab = 0;
                      currentTabView = const HomePage();
                    });
                  },
                  icon: Icon(
                    Icons.home,
                    color: selectTab == 0 ? AppColors.primary : Colors.grey,
                  ),
                ),

               IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TransactionFormScreen()),
                    );

//                 IconButton(
//                   onPressed: () async {
//                     if (userId != null) {
//                       setState(() {
//                         selectTab = 1;
//                         currentTabView = TransactionListView(userId: userId!);
//                       });
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                             content:
//                                 Text('Không tìm thấy thông tin người dùng')),
//                       );
//                     }

                  },
                  icon: Icon(
                    Icons.receipt_long,
                    color: selectTab == 1 ? AppColors.primary : Colors.grey,
                  ),
                ),
                const SizedBox(width: 50),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectTab = 2;
                    });
                  },
                  icon: Icon(
                    Icons.pie_chart,
                    color: selectTab == 2 ? AppColors.primary : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectTab = 3;
                      currentTabView = const UserProfile();
                    });
                  },
                  icon: Icon(
                    Icons.person,
                    color: selectTab == 3 ? AppColors.primary : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
