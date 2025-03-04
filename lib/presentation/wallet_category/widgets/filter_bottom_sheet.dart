import 'package:flutter/material.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/domain/repository/wallet_type.dart';
import 'package:my_project/service_locator.dart';

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
  List<WalletType> _walletTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedWalletTypeId = widget.currentFilters['walletTypeId'];
    _loadWalletTypes();
  }

  Future<void> _loadWalletTypes() async {
    setState(() {
      _isLoading = true;
    });
    
    final result = await sl<WalletTypeRepository>().getWalletType(1, 100);
    result.fold(
      (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))),
      (types) => setState(() => _walletTypes = types),
    );
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppBar(
            title: const Text('Filter'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedWalletTypeId,
                      decoration: const InputDecoration(
                        labelText: 'Wallet type',
                        hintText: 'Select wallet type',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All'),
                        ),
                        ..._walletTypes.map((type) => DropdownMenuItem<String>(
                          value: type.id,
                          child: Text(type.name),
                        )).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedWalletTypeId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _applyFilters(),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Apply filter'),
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