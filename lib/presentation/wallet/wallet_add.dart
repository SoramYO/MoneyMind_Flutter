import 'package:flutter/material.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/data/source/wallet_api_service.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';

class WalletAddScreen extends StatefulWidget {
  final String userId;

  const WalletAddScreen({super.key, required this.userId});

  @override
  _WalletAddScreenState createState() => _WalletAddScreenState();
}

class _WalletAddScreenState extends State<WalletAddScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  WalletCategory? _selectedCategory;
  List<WalletCategory> categories = [];

  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => isLoading = true);
    try {
      // Sử dụng phương thức getWalletCategoryByUserId để lấy danh mục ví
      final result = await sl<WalletCategoryRepository>().getWalletCategoryByUserId(widget.userId, null, 1, 20);
      result.fold(
        (errorMessage) {
          setState(() => error = errorMessage);
          print("Error loading categories: $errorMessage"); // In ra console nếu có lỗi
        },
        (data) {
          setState(() => categories = data);
          print("Loaded categories: $data"); // In ra console danh mục ví đã tải
        },
      );
    } catch (e) {
      setState(() => error = "Error: $e");
      print("Exception: $e"); // In ra console nếu có ngoại lệ
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  //nhập sai thông tin hoặc chưa chọn danh mục ví
  Future<void> _createWallet() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null) {
      _showSnackbar("Please enter correct and complete information!!!");
      return;
    }

    try {
      final walletData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'balance': double.tryParse(_balanceController.text) ?? 0,
        'walletCategoryId': _selectedCategory!.id,
      };

      final result = await sl<WalletApiService>().createWallet(walletData);
      result.fold(
        (errorMessage) => _showSnackbar(errorMessage),
        (data) {
          _showSnackbar("Wallet added successfully!");
          Navigator.pop(context, data);
        },
      );
    } catch (e) {
      _showSnackbar("Error: $e");
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Wallet"),
        centerTitle: true,
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field validation
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name"),
                      validator: (value) =>
                          value?.isEmpty ?? true ? "Required field" : null,
                    ),
                    SizedBox(height: 12),
                    // Description field validation
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration("Description"),
                      validator: (value) =>
                          value?.isEmpty ?? true ? "Required field" : null,
                    ),
                    SizedBox(height: 12),
                    // Balance field validation
                    TextFormField(
                      controller: _balanceController,
                      decoration: _inputDecoration("Balance"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required field";
                        }
                        final balance = double.tryParse(value);
                        if (balance == null) {
                          return "Invalid number";
                        }
                        if (balance <= 0) {
                          return "Please enter balance greater than 0";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    // Category dropdown validation
                    DropdownButtonFormField<WalletCategory>(
                      value: _selectedCategory,
                      decoration: _inputDecoration("Category"),
                      isExpanded: true,
                      isDense: true, // Giảm chiều cao của dropdown
                      itemHeight: 48, // Chiều cao của mỗi item trong dropdown
                      items: categories.map((category) {
                        return DropdownMenuItem<WalletCategory>(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? "Required field" : null,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _createWallet,
                      child: Text("Create"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}