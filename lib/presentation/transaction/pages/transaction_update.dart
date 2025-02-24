import 'package:flutter/material.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/data/repository/activity.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';

class TransactionUpdateScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionUpdateScreen({Key? key, required this.transaction}) : super(key: key);

  @override
  _TransactionUpdateScreenState createState() => _TransactionUpdateScreenState();
}

class _TransactionUpdateScreenState extends State<TransactionUpdateScreen> {
  List<Wallet> wallets = [];
  List<ActivityDb> activities = [];
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? _selectedWalletId;
  String? _walletCategoryId;
  String? _selectedActivityId;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _loadData();
  }

  void _initializeFields() {
    _recipientController.text = widget.transaction.recipientName;
    _amountController.text = widget.transaction.amount.toString();
    _descriptionController.text = widget.transaction.description;
    _dateController.text = widget.transaction.transactionDate.toIso8601String().split('T')[0];
    _selectedWalletId = widget.transaction.walletId;
    _selectedActivityId = widget.transaction.activyId;
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final resultListWallets = await sl<WalletRepository>().getWallets();
      resultListWallets.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
          });
        },
        (data) {
          setState(() {
            wallets = data;
          });
        },
      );
      if (_selectedWalletId != null) {
        final selectedWallet = wallets.firstWhere((wallet) => wallet.id == _selectedWalletId);
        _walletCategoryId = selectedWallet.walletCategory.id;
        _loadActivities(_walletCategoryId!);
      }
      isLoading = false;
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadActivities(String walletCategoryId) async {
    try {
      final result = await sl<ActivityRepository>().getActivityDb(walletCategoryId: walletCategoryId);
      result.fold(
        (errorMessage) {
          print("Error: $errorMessage");
        },
        (data) {
          setState(() {
            activities = data;
          });
          print("Activities: $data");
        },
      );
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> _updateTransaction() async {
    try {
      final transaction = widget.transaction.copyWith(
        recipientName: _recipientController.text,
        amount: double.parse(_amountController.text),
        description: _descriptionController.text,
        transactionDate: DateTime.parse(_dateController.text),
        lastUpdateAt: DateTime.now(),
        walletId: _selectedWalletId,
        activyId: _selectedActivityId,
      );

      final result = await sl<TransactionRepository>().updateTransaction(transaction);
      result.fold(
        (errorMessage) {
          if (errorMessage == "Update transaction successfully") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Cập nhật giao dịch thành công!!"),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Cập nhật giao dịch thất bại hãy thử lại!!"),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (data) {
          print("Transaction updated: $data");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Lưu giao dịch thành công!"),
              backgroundColor: Colors.green,
            ),
          );
        },
      );
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi hệ thống: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
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
        backgroundColor: Colors.green,
        elevation: 0,
        title: Text(
          'Cập nhật giao dịch',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 28, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _recipientController,
                          decoration: _inputDecoration("Người nhận"),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _amountController,
                          decoration: _inputDecoration("Số tiền"),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration("Mô tả"),
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _dateController,
                          decoration: _inputDecoration("Ngày giao dịch"),
                          readOnly: true,
                          onTap: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _dateController.text = pickedDate.toIso8601String().split('T')[0];
                              });
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _selectedWalletId,
                          decoration: _inputDecoration("Ví"),
                          isExpanded: true,
                          items: wallets.map((wallet) {
                            return DropdownMenuItem<String>(
                              value: wallet.id.toString(),
                              child: Text("Ví có ${wallet.balance} ${wallet.currency}"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWalletId = value;
                              final selectedWallet = wallets.firstWhere((wallet) => wallet.id == value);
                              _walletCategoryId = selectedWallet.walletCategory.id;
                              _loadActivities(_walletCategoryId!);
                            });
                          },
                        ),
                        SizedBox(height: 12),
                        if (_walletCategoryId != null)
                          DropdownButtonFormField<String>(
                            value: _selectedActivityId,
                            decoration: _inputDecoration("Hoạt động"),
                            isExpanded: true,
                            items: activities.map((activity) {
                              return DropdownMenuItem<String>(
                                value: activity.id.toString(),
                                child: Text(activity.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedActivityId = value;
                              });
                            },
                          ),
                        SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _updateTransaction();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Cập nhật",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}