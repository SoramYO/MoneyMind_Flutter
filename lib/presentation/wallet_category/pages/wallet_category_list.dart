import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:my_project/presentation/wallet_category/pages/wallet_category_detail.dart';
import 'package:my_project/presentation/wallet_category/widgets/filter_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:my_project/presentation/wallet_category/widgets/wallet_category_form_dialog.dart';

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
  int pageSize = 20;
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
      // Add the actual data loading code here
      final result =
          await sl<WalletCategoryRepository>().getWalletCategoryByUserId(
        widget.userId,
        _currentWalletTypeId,
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

  Future<void> _showCreateDialog() async {
    final newCategory = await showDialog<WalletCategory>(
      context: context,
      builder: (context) => WalletCategoryFormDialog(
        userId: widget.userId,
      ),
    );

    if (newCategory != null) {
      setState(() {
        walletCategories = [...walletCategories, newCategory];
      });
      _loadWalletCategories(); // Reload the list to get updated data
    }
  }

  Future<void> _showEditDialog(WalletCategory category) async {
    final updatedCategory = await showDialog<WalletCategory>(
      context: context,
      builder: (context) => WalletCategoryFormDialog(
        category: category,
        userId: widget.userId,
      ),
    );

    if (updatedCategory != null) {
      setState(() {
        walletCategories = walletCategories
            .map((c) => c.id == updatedCategory.id ? updatedCategory : c)
            .toList();
      });

      // Optional: Reload from server to ensure data consistency
      _loadWalletCategories();
    }
  }

  // Nhóm categories theo walletTypeName
  Map<String, List<WalletCategory>> get groupedCategories {
    final groups = <String, List<WalletCategory>>{};
    for (var category in walletCategories) {
      final typeName = category.walletTypeName ?? 'Not classified';
      if (!groups.containsKey(typeName)) {
        groups[typeName] = [];
      }
      groups[typeName]!.add(category);
    }

    // Sort categories trong mỗi nhóm
    for (var categories in groups.values) {
      categories.sort((a, b) => a.name.compareTo(b.name));
    }
    return groups; // Add return statement
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

    // Add this part to apply the filter when user selects it
    if (result != null) {
      setState(() {
        _currentWalletTypeId = result['walletTypeId'];
        currentPage = 1; // Reset to first page when applying filters
      });
      _loadWalletCategories(); // Reload with new filter
    }
  }

  Future<void> _createDefaultWalletCategories() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final result =
        await sl<WalletCategoryRepository>().createWalletCategoryDefault();
    result.fold(
      (errorMessage) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      },
      (data) {
        setState(() {
          walletCategories = data;
          isLoading = false;
        });
      },
    );
  }

  // dart
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          const Text(
            'No wallet categories yet',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 28),
            label: const Text(
              "Create default wallet",
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: const Size(200, 60),
            ),
            onPressed: _createDefaultWalletCategories,
          ),
        ],
      ),
    );
  }

  void _navigateToCreatePage() {
    _showCreateDialog();
  }

  void _navigateToUpdatePage(WalletCategory walletCategory) {
    _showEditDialog(walletCategory);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(child: Text(error!));
    }

    if (walletCategories.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 10,
          title: const Text(
            'Wallet category',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _buildEmptyState(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Wallet category',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _navigateToCreatePage,
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
                  ...entry.value.map(
                    (category) => Dismissible(
                      key: Key(category.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.blue,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        _navigateToUpdatePage(category);
                        return false; // Không xóa card sau khi vuốt
                      },
                      child: WalletCategoryCard(
                        category: category,
                        onTap: () => _handleCategoryTap(category),
                        onLongPress: () => _showEditDialog(category),
                      ),
                    ),
                  ),
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
  final VoidCallback onLongPress; // Add this line
  const WalletCategoryCard({
    super.key,
    required this.category,
    required this.onTap,
    required this.onLongPress, // Add this line
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
        onLongPress: onLongPress, // Add this line
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
                child: _buildCategoryIcon(),
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
                          '${category.activities.length} activities',
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

  Widget _buildCategoryIcon() {
    // Check if the iconPath is a network URL.
    if (category.iconPath != null &&
        (category.iconPath!.startsWith('http://') ||
            category.iconPath!.startsWith('https://'))) {
      return CachedNetworkImage(
        imageUrl: category.iconPath!,
        color: category.color != null ? HexColor(category.color!) : Colors.grey,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) {
          print("Error loading image: $error");
          return Icon(
            Icons.category_outlined,
            color: category.color != null
                ? HexColor(category.color!)
                : Colors.grey,
          );
        },
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    } else if (category.iconPath != null) {
      // Assume it's a local asset.
      return Image.asset(
        category.iconPath!,
        color: category.color != null ? HexColor(category.color!) : Colors.grey,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
      );
    } else {
      // Fallback icon if iconPath is null.
      return Icon(
        Icons.category_outlined,
        color: category.color != null ? HexColor(category.color!) : Colors.grey,
      );
    }
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
