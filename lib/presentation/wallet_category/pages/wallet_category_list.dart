import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:my_project/presentation/wallet_category/pages/wallet_category_detail.dart';
import 'package:my_project/presentation/wallet_category/widgets/filter_bottom_sheet.dart';

class WalletCategoryListView extends StatefulWidget {
  final String userId;
  final String? walletTypeId;

  const WalletCategoryListView({
    super.key,
    required this.userId,
    this.walletTypeId,
  });

  @override
  State<WalletCategoryListView> createState() => _WalletCategoryListViewState();
}

class _WalletCategoryListViewState extends State<WalletCategoryListView> {
  List<WalletCategory> walletCategories = [];
  bool isLoading = false;
  String? error;
  int currentPage = 1;
  int pageSize = 10;
  String? _currentWalletTypeId;

  @override
  void initState() {
    super.initState();
    _currentWalletTypeId = widget.walletTypeId;
    _loadWalletCategories();
  }

  Future<void> _loadWalletCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final result =
          await sl<WalletCategoryRepository>().getWalletCategoryByUserId(
        widget.userId,
        widget.walletTypeId,
        currentPage,
        pageSize,
      );

      result.fold(
        (errorMessage) {
          setState(() {
            error = errorMessage;
            isLoading = false;
          });
        },
        (data) {
          setState(() {
            walletCategories = data;
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // Nhóm categories theo walletTypeName
  Map<String, List<WalletCategory>> get groupedCategories {
    final groups = <String, List<WalletCategory>>{};
    for (var category in walletCategories) {
      final typeName = category.walletTypeName ?? 'Không phân loại';
      if (!groups.containsKey(typeName)) {
        groups[typeName] = [];
      }
      groups[typeName]!.add(category);
    }

    // Sort categories trong mỗi nhóm
    for (var categories in groups.values) {
      categories.sort((a, b) => a.name.compareTo(b.name));
    }

    return groups;
  }

  void _handleCategoryTap(WalletCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WalletCategoryDetailView(categoryId: category.id),
      ),
    );
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterBottomSheet(
        currentFilters: {
          'walletTypeId': _currentWalletTypeId,
        },
      ),
    );

    if (result != null) {
      setState(() {
        _currentWalletTypeId = result['walletTypeId'];
      });
      _loadWalletCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Danh mục ví',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWalletCategories,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...groupedCategories.entries.map(
              (entry) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  ...entry.value.map((category) => WalletCategoryCard(
                        category: category,
                        onTap: () => _handleCategoryTap(category),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WalletCategoryCard extends StatelessWidget {
  final WalletCategory category;
  final VoidCallback onTap;

  const WalletCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (category.color != null
                      ? HexColor(category.color!).withOpacity(0.2)
                      : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.category_outlined,
                  color: category.color != null
                      ? HexColor(category.color!)
                      : Colors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _buildInfoChip(
                          '${category.activities.length} hoạt động',
                          Icons.list_alt_outlined,
                        ),
                        if (category.walletTypeName != null)
                          _buildInfoChip(
                            category.walletTypeName!,
                            Icons.account_balance_wallet_outlined,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Chip(
      label: Text(text),
      labelStyle: const TextStyle(fontSize: 12),
      avatar: Icon(icon, size: 16),
      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
      backgroundColor: Colors.grey[100],
    );
  }
}
