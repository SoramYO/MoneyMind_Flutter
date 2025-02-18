import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/utils/hex_color.dart';

class WalletCategoryDetailView extends StatefulWidget {
  final String categoryId;

  const WalletCategoryDetailView({
    super.key,
    required this.categoryId,
  });

  @override
  State<WalletCategoryDetailView> createState() => _WalletCategoryDetailViewState();
}

class _WalletCategoryDetailViewState extends State<WalletCategoryDetailView> {
  WalletCategory? _category;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategory();
  }

  Future<void> _loadCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await sl<WalletCategoryRepository>().getWalletCategoryById(widget.categoryId);
      
      result.fold(
        (error) => setState(() {
          _error = error;
          _isLoading = false;
        }),
        (data) => setState(() {
          _category = data;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? 'Không tìm thấy danh mục')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_category!.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryHeader(),
            const SizedBox(height: 24),
            _buildActivitiesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _category!.color != null
                      ? HexColor(_category!.color!).withOpacity(0.2)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: _category!.color != null
                      ? HexColor(_category!.color!)
                      : Colors.grey,
                ),
              ),
              title: Text(
                _category!.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(_category!.description),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                _buildDetailChip(
                  '${_category!.activities.length} hoạt động',
                  Icons.list_alt_outlined,
                ),
                if (_category!.walletTypeName != null)
                  _buildDetailChip(
                    _category!.walletTypeName!,
                    Icons.account_balance_wallet_outlined,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      avatar: Icon(icon, size: 18),
      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
    );
  }

  Widget _buildActivitiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Hoạt động',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._category!.activities.map((activity) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(activity.name),
            subtitle: Text(activity.description),
            trailing: Text(
              DateFormat('dd/MM/yyyy').format(activity.createAt),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        )),
      ],
    );
  }
} 