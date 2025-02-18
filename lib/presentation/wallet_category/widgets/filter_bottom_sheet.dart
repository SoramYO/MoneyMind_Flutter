import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedWalletTypeId;

  @override
  void initState() {
    super.initState();
    _selectedWalletTypeId = widget.currentFilters['walletTypeId'];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Bộ lọc'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mã loại ví',
                    hintText: 'Nhập mã loại ví',
                  ),
                  initialValue: _selectedWalletTypeId,
                  onChanged: (value) => _selectedWalletTypeId = value,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _applyFilters(),
                  child: const Text('Áp dụng bộ lọc'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    Navigator.pop(context, {
      'walletTypeId': _selectedWalletTypeId,
    });
  }
} 