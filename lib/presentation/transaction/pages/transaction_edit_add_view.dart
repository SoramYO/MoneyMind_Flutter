import 'package:flutter/material.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/data/models/wallet.dart';
import 'package:my_project/data/models/transaction.dart';
import 'package:my_project/data/repository/activity.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/domain/repository/wallet.dart';
import 'package:my_project/domain/repository/transaction.dart';
import 'package:my_project/service_locator.dart';

// Khởi tạo lớp TransactionFormScreen
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({Key? key}) : super(key: key);

  @override
  _TransactionFormScreenState createState() => _TransactionFormScreenState();
}

// Khởi tạo trạng thái của TransactionFormScreen
class _TransactionFormScreenState extends State<TransactionFormScreen> {
  List<Wallet> wallets = []; // Danh sách ví
  List<ActivityDb> activities = []; // Danh sách hoạt động
  final _formKey = GlobalKey<FormState>(); // Khóa toàn cục để xác định biểu mẫu
  final TextEditingController _recipientController = TextEditingController(); // Bộ điều khiển văn bản cho người nhận
  final TextEditingController _amountController = TextEditingController(); // Bộ điều khiển văn bản cho số tiền
  final TextEditingController _descriptionController = TextEditingController(); // Bộ điều khiển văn bản cho mô tả
  final TextEditingController _dateController = TextEditingController(); // Bộ điều khiển văn bản cho ngày giao dịch
  String? _selectedWalletId; // Biến để lưu trữ ID ví được chọn
  String? _walletCategoryId; // Biến để lưu trữ ID của WalletCategory
  String? _selectedActivityId; // Biến để lưu trữ ID của Activity
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final resultListWallets = await sl<WalletRepository>().getWallets(); // Thay 'userId' bằng ID người dùng thực tế
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

Future<void> _createTransaction() async {
  try {
    final transaction = Transaction(
      id: '', // ID sẽ được tạo tự động bởi backend
      recipientName: _recipientController.text,
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      transactionDate: DateTime.parse(_dateController.text),
      createAt: DateTime.now(),
      lastUpdateAt: DateTime.now(),
      userId: 'userId', // Thay 'userId' bằng ID người dùng thực tế
      walletId: _selectedWalletId,
      tags: [], // Thêm các tag nếu cần
    );

    final result = await sl<TransactionRepository>().createTransaction(transaction);
    result.fold(
      (errorMessage) {
        if (errorMessage == "Create transaction successfully !") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Thêm giao dịch thành công!!"),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Thêm giao dịch thất bại hãy thử lại!!"),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (data) {
        print("Transaction created: $data");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lưu giao dịch thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        
        // Xóa dữ liệu trong các ô nhập sau khi lưu thành công
        _recipientController.clear();
        _amountController.clear();
        _descriptionController.clear();
        _dateController.clear();
        setState(() {
          _selectedWalletId = null;
          _walletCategoryId = null;
          _selectedActivityId = null;
          activities.clear();
        });
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

  // Phương thức để tạo kiểu cho các trường nhập liệu
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
          'Thông tin giao dịch',
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
                        // Trường nhập liệu cho người nhận
                        TextFormField(
                          controller: _recipientController,
                          decoration: _inputDecoration("Người nhận"),
                        ),
                        SizedBox(height: 12),
                        // Trường nhập liệu cho số tiền
                        TextFormField(
                          controller: _amountController,
                          decoration: _inputDecoration("Số tiền"),
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 12),
                        // Trường nhập liệu cho mô tả
                        TextFormField(
                          controller: _descriptionController,
                          decoration: _inputDecoration("Mô tả"),
                        ),
                        SizedBox(height: 12),
                        // Trường nhập liệu cho ngày giao dịch
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
                        // Dropdown để chọn ví
                        DropdownButtonFormField<String>(
                          value: _selectedWalletId,
                          decoration: _inputDecoration("Ví"),
                          isExpanded: true,
                          items: wallets.map((wallet) {
                            return DropdownMenuItem<String>(
                              value: wallet.id.toString(), // ID của ví
                              child: Text(
                                  "Ví có ${wallet.balance} ${wallet.currency}"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedWalletId = value;

                              // Lấy thông tin ví từ danh sách wallets dựa vào ID được chọn
                              final selectedWallet = wallets
                                  .firstWhere((wallet) => wallet.id == value);

                              // Lưu lại WalletCategory ID
                              _walletCategoryId = selectedWallet.walletCategory.id;

                              // In ra ID của ví và ID của walletCategory
                              print(
                                  "Wallet ID: ${selectedWallet.id} - WalletCategory ID: ${selectedWallet.walletCategory.id}");

                              // Gọi API để lấy danh sách activity
                              _loadActivities(_walletCategoryId!);
                            });
                          },
                        ),
                        SizedBox(height: 12),
                        // Dropdown để chọn activity (chỉ hiện khi đã chọn ví)
                        if (_walletCategoryId != null)
                          DropdownButtonFormField<String>(
                            value: _selectedActivityId,
                            decoration: _inputDecoration("Hoạt động"),
                            isExpanded: true,
                            items: activities.map((activity) {
                              return DropdownMenuItem<String>(
                                value: activity.id.toString(), // ID của activity
                                child: Text(activity.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedActivityId = value;

                                // In ra ID của activity
                                print("Selected Activity ID: $_selectedActivityId");
                              });
                            },
                          ),
                        SizedBox(height: 20),
                        // Nút lưu thông tin giao dịch
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Gọi hàm createTransaction để tạo giao dịch
                              _createTransaction();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Lưu",
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