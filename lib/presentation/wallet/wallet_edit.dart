import 'package:flutter/material.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/data/models/wallet_update.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';

class WalletEditScreen extends StatefulWidget {
  final Wallet wallet;
  final String userId;

  const WalletEditScreen({super.key, required this.wallet, required this.userId});

  @override
  _WalletEditScreenState createState() => _WalletEditScreenState();
}

class _WalletEditScreenState extends State<WalletEditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  String? _selectedWalletCategoryId;
  List<WalletCategory> walletCategories = [];

  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadWalletCategories(); // Step 1: Load wallet categories
  }

  void _initializeFields() {
    _nameController.text = widget.wallet.name;
    _descriptionController.text = widget.wallet.description;
    _balanceController.text = widget.wallet.balance.toString();
    _selectedWalletCategoryId = widget.wallet.walletCategory.id;
  }

  Future<void> _loadWalletCategories() async {
    setState(() => isLoading = true);

    try {
      final result = await sl<WalletCategoryRepository>().getWalletCategoryByUserId(widget.userId, null, 1, 20);
      result.fold(
        (errorMessage) => setState(() => error = errorMessage),
        (data) => setState(() => walletCategories = data),
      );
    } catch (e) {
      setState(() => error = "System error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _updateWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final updatedWalletData = WalletUpdate(
        name: _nameController.text,
        description: _descriptionController.text,
        balance: double.tryParse(_balanceController.text) ?? 0,
        walletCategoryId: _selectedWalletCategoryId!,
      );

      final result = await sl<WalletRepository>().updateWallet(widget.wallet.id, updatedWalletData);

      result.fold(
        (errorMessage) => setState(() {
          error = errorMessage;
          isLoading = false;
          _showSnackbar("Update failed: $errorMessage");
        }),
        (data) {
          setState(() {
            isLoading = false;
            _showSnackbar("Wallet updated successfully!");
            Navigator.pop(context, data); // Return the updated wallet
          });
        },
      );
    } catch (e) {
      setState(() {
        error = "Error: $e";
        isLoading = false;
        _showSnackbar("Update failed: $e");
      });
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green, width: 2)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Wallet"), centerTitle: true, backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration("Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the name";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: _inputDecoration("Description"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the description";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _balanceController,
                      decoration: _inputDecoration("Balance"),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter the balance";
                        }
                        if (double.tryParse(value) == null) {
                          return "Please enter a valid number";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: TextEditingController(text: walletCategories.firstWhere((category) => category.id == _selectedWalletCategoryId)?.name ?? ''),
                      decoration: _inputDecoration("Wallet Category"),
                      readOnly: true,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateWallet,
                      child: Text("Update"),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}