import 'package:flutter/material.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';

class TransactionUpdateScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionUpdateScreen({super.key, required this.transaction});

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
  List<String> _selectedActivitiesId = [];

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
    _selectedActivitiesId = List<String>.from(widget.transaction.activities!.map((activity) => activity.id));
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    try {
      final resultListWallets = await sl<WalletRepository>().getWallets();
      resultListWallets.fold(
        (errorMessage) => setState(() => error = errorMessage),
        (data) => setState(() => wallets = data),
      );

      if (_selectedWalletId != null) {
        final selectedWallet = wallets.firstWhere((wallet) => wallet.id == _selectedWalletId);
        _walletCategoryId = selectedWallet.walletCategory.id;
        _loadActivities(_walletCategoryId!);
      }
    } catch (e) {
      setState(() => error = "Lỗi hệ thống: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadActivities(String walletCategoryId) async {
    try {
      final result = await sl<ActivityRepository>().getActivityDb(walletCategoryId: walletCategoryId);
      result.fold(
        (errorMessage) => print("Lỗi khi tải hoạt động: $errorMessage"),
        (data) => setState(() => activities = data),
      );
    } catch (e) {
      print("Exception: $e");
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

  Future<void> _updateTransaction() async {
  if (_selectedWalletId == null || _selectedActivitiesId.isEmpty) {
    _showSnackbar("Please select wallet and activities");
    return;
  }

  try {
    final updatedTransaction = TransactionRequest(
      recipientName: _recipientController.text,
      amount: double.tryParse(_amountController.text) ?? 0,
      description: _descriptionController.text,
      transactionDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      activities: _selectedActivitiesId,
      walletId: _selectedWalletId!,
    );

    final result = await sl<TransactionRepository>().updateTransaction(widget.transaction.id, updatedTransaction);

    result.fold(
      (errorMessage) => _showSnackbar(errorMessage),
      (data) {
        _showSnackbar("Update transaction successfully!");
        Navigator.pop(context, data); // Trả về transaction đã cập nhật
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
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.green, width: 2)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _showActivitySelectionDialog() async {
    List<String> tempSelected = List.from(_selectedActivitiesId);

    final selectedIds = await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Chọn hoạt động"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: SingleChildScrollView(
                child: Column(
                  children: activities.map((activity) {
                    final activityId = activity.id.toString();
                    final isSelected = tempSelected.contains(activityId);

                    return CheckboxListTile(
                      title: Text(activity.name),
                      value: isSelected,
                      onChanged: (checked) {
                        setDialogState(() {
                          if (checked == true) {
                            tempSelected.add(activityId);
                          } else {
                            tempSelected.remove(activityId);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, null), child: Text("Cancel")),
                ElevatedButton(onPressed: () => Navigator.pop(context, tempSelected), style: ElevatedButton.styleFrom(backgroundColor: Colors.green), child: Text("OK")),
              ],
            );
          },
        );
      },
    );

    if (selectedIds != null) {
      setState(() => _selectedActivitiesId = selectedIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Transaction"), centerTitle: true, backgroundColor: Colors.green),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(controller: _recipientController, decoration: _inputDecoration("Recipient")),
                    SizedBox(height: 12),
                    TextFormField(controller: _amountController, decoration: _inputDecoration("Amount"), keyboardType: TextInputType.number),
                    SizedBox(height: 12),
                    TextFormField(
                        controller: _descriptionController,
                        decoration: _inputDecoration("Description")),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _dateController,
                      decoration: _inputDecoration("Date"),
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
                            _dateController.text =
                                pickedDate.toIso8601String().split('T')[0];
                          });
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedWalletId,
                      decoration: _inputDecoration("Wallet"),
                      isExpanded: true,
                      items: wallets.map((wallet) {
                        return DropdownMenuItem<String>(
                          value: wallet.id.toString(),
                          child: Text("${wallet.balance} ${wallet.currency}"),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedWalletId = value),
                    ),
                    SizedBox(height: 12),
                    ElevatedButton(onPressed: _showActivitySelectionDialog, child: Text("Choose activities")),
                    SizedBox(height: 20),
                    ElevatedButton(onPressed: _updateTransaction, child: Text("Update")),
                  ],
                ),
              ),
      ),
    );
  }
}
