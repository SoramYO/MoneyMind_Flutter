import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_project/data/models/monthly_goal.dart';
import 'package:my_project/data/models/monthly_goal_req_params.dart';
import 'package:my_project/domain/repository/monthly_goal.dart';
import 'package:my_project/service_locator.dart';

class MonthlyGoalFormDialog extends StatefulWidget {
  final MonthlyGoal? monthlyGoal;

  const MonthlyGoalFormDialog({
    super.key,
    this.monthlyGoal,
  });

  @override
  State<MonthlyGoalFormDialog> createState() => _MonthlyGoalFormDialogState();
}

class _MonthlyGoalFormDialogState extends State<MonthlyGoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _totalAmountController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  final List<int> years =
      List.generate(50, (index) => DateTime.now().year - 25 + index);
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.monthlyGoal != null) {
      _totalAmountController.text = widget.monthlyGoal!.totalAmount.toString();
      selectedMonth = widget.monthlyGoal!.month;
      selectedYear = widget.monthlyGoal!.year;
    }
    _monthController.text = selectedMonth.toString();
    _yearController.text = selectedYear.toString();
  }

  void _showMonthPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Select Month",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: CupertinoPicker(
                scrollController:
                    FixedExtentScrollController(initialItem: selectedMonth - 1),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedMonth = index + 1;
                    _monthController.text =
                        "$selectedMonth"; // Display month in text
                  });
                },
                children: List.generate(
                    12, (index) => Center(child: Text("${index + 1}"))),
              ),
            ),
            CupertinoButton(
              child: const Text("Done"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  void _showYearPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Select Year",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(),
            Expanded(
              child: CupertinoPicker(
                scrollController: FixedExtentScrollController(
                  initialItem: years.indexOf(selectedYear),
                ),
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedYear = years[index];
                    _yearController.text = selectedYear.toString();
                  });
                },
                children: years
                    .map((year) => Center(child: Text(year.toString())))
                    .toList(),
              ),
            ),
            CupertinoButton(
              child: const Text("Done"),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.monthlyGoal == null
                    ? 'Create Monthly Goal'
                    : 'Update Monthly Goal',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _totalAmountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+(\.\d{0,14})?$')),
                ],
                decoration: InputDecoration(
                  labelText: 'Total Amount',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final double? parsed = double.tryParse(value);
                  if (parsed == null || parsed < 0)
                    return 'Enter a valid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthController,
                      readOnly: true,
                      // onTap: _showMonthPicker,
                      decoration: const InputDecoration(labelText: "Month"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      readOnly: true,
                      // onTap: _showYearPicker,
                      decoration: const InputDecoration(labelText: "Year"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                              widget.monthlyGoal == null ? 'Create' : 'Update'),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
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
    double? totalAmount = tryParseDouble(_totalAmountController.text);

    if (totalAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid total amount range')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final monthlyGoal = MonthlyGoalReqParams(
        totalAmount: totalAmount,
        month: selectedMonth,
        year: selectedYear,
      );

      final result = widget.monthlyGoal == null
          ? await sl<MonthlyGoalRepository>().createMonthlyGoal(monthlyGoal)
          : await sl<MonthlyGoalRepository>()
              .updateMonthlyGoal(widget.monthlyGoal!.id, monthlyGoal);
      if (!mounted) return;
      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to ${widget.monthlyGoal == null ? 'create' : 'update'}: $error')),
          );
        },
        (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Monthly goal ${widget.monthlyGoal == null ? 'created' : 'updated'} successfully')),
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
    _totalAmountController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }
}
