import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/data/models/goal_item.dart';
import 'package:my_project/data/models/goal_item_req_params.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/domain/repository/goal_item.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/domain/repository/wallet_type.dart';
import 'package:my_project/service_locator.dart';

class GoalItemFormDialog extends StatefulWidget {
  final GoalItem? goalItem;

  const GoalItemFormDialog({
    super.key,
    this.goalItem,
  });

  @override
  State<GoalItemFormDialog> createState() => _GoalItemFormDialogState();
}

class _GoalItemFormDialogState extends State<GoalItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _minTargetPercentageController = TextEditingController();
  final _maxTargetPercentageController = TextEditingController();
  final _minAmountController = TextEditingController();
  final _maxAmountController = TextEditingController();
  int? _selectedTargetMode;
  String? _selectedWalletTypeId;
  List<WalletType> _walletTypes = [];
  String? _selectedMonthlyGoalId;
  List<MonthlyGoal> _monthlyGoals = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.goalItem != null) {
      _descriptionController.text = widget.goalItem!.description;
      _minTargetPercentageController.text =
          widget.goalItem!.minTargetPercentage.toString();
      _maxTargetPercentageController.text =
          widget.goalItem!.maxTargetPercentage.toString();
      _minAmountController.text = widget.goalItem!.minAmount.toString();
      _maxAmountController.text = widget.goalItem!.maxAmount.toString();
      _selectedTargetMode = widget.goalItem!.targetMode;
      _selectedMonthlyGoalId = widget.goalItem!.monthlyGoalId;
      _selectedWalletTypeId = widget.goalItem!.walletTypeId;
    }
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final resultWalletType =
          await sl<WalletTypeRepository>().getWalletType(1, 100);
      final resultMonthlyGoal = await sl<MonthlyGoalRepository>()
          .getMonthlyGoals(null, null, null, 1, 100);

      resultMonthlyGoal.fold(
        (error) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error))),
        (data) => setState(() => _monthlyGoals = data),
      );
      resultWalletType.fold(
        (error) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error))),
        (data) => setState(() => _walletTypes = data),
      );
      isLoading = false;
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.goalItem == null
                    ? 'Create Goal Item'
                    : 'Update Goal Item',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            hintText: 'Please enter description',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 2,
                          validator: widget.goalItem == null
                              ? ((value) => value?.isEmpty ?? true
                                  ? 'Description is required'
                                  : null)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _minTargetPercentageController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'^\d+(\.\d{0,2})?$')), // Chỉ cho phép số và tối đa 2 chữ số thập phân
                          ],
                          decoration: InputDecoration(
                            labelText: 'Min Target Percentage (%)',
                            hintText: 'Number Percentage',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixText: '%', // Hiển thị đơn vị %
                            prefixIcon: const Icon(Icons.percent),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Min Target Percentage is required';
                            }
                            final double? parsedValue = double.tryParse(value);
                            if (parsedValue == null ||
                                parsedValue < 0 ||
                                parsedValue > 100) {
                              return 'Enter a value between 0-100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maxTargetPercentageController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+(\.\d{0,2})?$')),
                          ],
                          decoration: InputDecoration(
                            labelText: 'Max Target Percentage (%)',
                            hintText: 'Number Percentage',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixText: '%',
                            prefixIcon: const Icon(Icons.percent),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Max Target Percentage is required';
                            }
                            final double? parsedValue = double.tryParse(value);
                            if (parsedValue == null ||
                                parsedValue < 0 ||
                                parsedValue > 100) {
                              return 'Enter a value between 0-100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _minAmountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'^\d+(\.\d{0,14})?$')), // Chỉ cho phép nhập số và dấu .
                          ],
                          decoration: InputDecoration(
                            labelText: 'Min Amount',
                            hintText: 'Positive number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Min Amount is required';
                            }
                            final double? parsedValue = double.tryParse(value);
                            if (parsedValue == null || parsedValue < 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _maxAmountController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(
                                r'^\d+(\.\d{0,14})?$')), // Chỉ cho phép nhập số và dấu .
                          ],
                          decoration: InputDecoration(
                            labelText: 'Max Amount',
                            hintText: 'Positive number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.attach_money),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Max Amount is required';
                            }
                            final double? parsedValue = double.tryParse(value);
                            if (parsedValue == null || parsedValue < 0) {
                              return 'Enter a valid positive number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          value: _selectedTargetMode,
                          decoration: InputDecoration(
                            labelText: 'Target Mode',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.settings),
                          ),
                          items: const [
                            DropdownMenuItem(value: 0, child: Text('Max Only')),
                            DropdownMenuItem(value: 1, child: Text('Min Only')),
                            DropdownMenuItem(value: 2, child: Text('Range')),
                            DropdownMenuItem(
                                value: 3, child: Text('Percentage Only')),
                            DropdownMenuItem(
                                value: 4, child: Text('Fixed Amount')),
                            DropdownMenuItem(
                                value: 5, child: Text('No Target')),
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedTargetMode = value),
                          validator: (value) =>
                              value == null ? 'Target Mode is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedMonthlyGoalId,
                          decoration: InputDecoration(
                            labelText: 'Monthly Goal',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: _monthlyGoals
                              .map((monthlyGoal) => DropdownMenuItem(
                                    value: monthlyGoal.id,
                                    child: Text(
                                        '${monthlyGoal.month}/${monthlyGoal.year}'),
                                  ))
                              .toList(),
                          onChanged: _monthlyGoals.isNotEmpty
                              ? (value) =>
                                  setState(() => _selectedMonthlyGoalId = value)
                              : null,
                          validator: (value) =>
                              value == null ? 'Monthly Goal is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedWalletTypeId,
                          decoration: InputDecoration(
                            labelText: 'Wallet type',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.category),
                          ),
                          items: _walletTypes
                              .map((type) => DropdownMenuItem(
                                    value: type.id,
                                    child: Text(type.name),
                                  ))
                              .toList(),
                          onChanged: _walletTypes.isNotEmpty
                              ? (value) =>
                                  setState(() => _selectedWalletTypeId = value)
                              : null,
                          validator: (value) =>
                              value == null ? 'Wallet Type is required' : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.goalItem == null ? 'Create' : 'Update',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (isLoading) return; // Prevent double submission

    // Đóng bàn phím khi nhấn submit
    FocusScope.of(context).unfocus();

    // Hàm kiểm tra và chuyển đổi số an toàn
    double? tryParseDouble(String? value) {
      if (value == null || value.isEmpty) return null;
      return double.tryParse(value);
    }

    // Kiểm tra và chuyển đổi các giá trị số
    double? minTarget = tryParseDouble(_minTargetPercentageController.text);
    double? maxTarget = tryParseDouble(_maxTargetPercentageController.text);
    double? minAmount = tryParseDouble(_minAmountController.text);
    double? maxAmount = tryParseDouble(_maxAmountController.text);

    // Kiểm tra xem giá trị có hợp lệ không
    if (minTarget == null || maxTarget == null || minTarget > maxTarget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid target percentage range')),
      );
      return;
    }

    if (minAmount == null || maxAmount == null || minAmount > maxAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid amount range')),
      );
      return;
    }

    if (_selectedTargetMode == null ||
        _selectedMonthlyGoalId == null ||
        _selectedWalletTypeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final goalItem = GoalItemReqParams(
        description: _descriptionController.text,
        minTargetPercentage: minTarget,
        maxTargetPercentage: maxTarget,
        minAmount: minAmount,
        maxAmount: maxAmount,
        targetMode: _selectedTargetMode!,
        monthlyGoalId: _selectedMonthlyGoalId!,
        walletTypeId: _selectedWalletTypeId!,
      );

      final result = widget.goalItem == null
          ? await sl<GoalItemRepository>().createGoalItem(goalItem)
          : await sl<GoalItemRepository>()
              .updateGoalItem(widget.goalItem!.id, goalItem);

      if (!mounted) return;

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to ${widget.goalItem == null ? 'create' : 'update'}: $error')),
          );
        },
        (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Goal item ${widget.goalItem == null ? 'created' : 'updated'} successfully')),
          );
          Navigator.pop(context, data); // Đóng dialog và báo thành công
        },
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _maxAmountController.dispose();
    _minAmountController.dispose();
    _maxTargetPercentageController.dispose();
    _minTargetPercentageController.dispose();
    super.dispose();
  }
}
