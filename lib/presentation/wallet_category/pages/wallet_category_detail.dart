import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/presentation/wallet_category/widgets/add_activity_bottom_sheet.dart';
import 'package:my_project/presentation/wallet_category/widgets/edit_activity_bottom_sheet.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/core/utils/hex_color.dart';

class WalletCategoryDetailView extends StatefulWidget {
  final String categoryId;

  const WalletCategoryDetailView({
    super.key,
    required this.categoryId,
  });

  @override
  State<WalletCategoryDetailView> createState() =>
      _WalletCategoryDetailViewState();
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
      final result = await sl<WalletCategoryRepository>()
          .getWalletCategoryById(widget.categoryId);

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
                  '${_category!.activities.length} activities',
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final result = await showModalBottomSheet<String>(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => AddActivityBottomSheet(
                    categoryId: widget.categoryId,
                  ),
                );

                if (result != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                  _loadCategory();
                }
              },
              child: const Text('Add'),
            )
          ],
        ),
        const SizedBox(height: 12),
        ..._category!.activities.map((activity) => Dismissible(
              key: Key(activity.id), // Sử dụng ID làm key duy nhất
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              confirmDismiss: (direction) async {
                return await _showDeleteConfirmationDialog(activity.id);
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(activity.name),
                  subtitle: Text(activity.description),
                  trailing: Text(
                    DateFormat('dd/MM/yyyy').format(activity.createdAt),
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () async {
                    print('Type of activity: ${activity.runtimeType}');
                    print(
                        'Value of activity: $activity'); // In giá trị chi tiết
                    final updated = await showModalBottomSheet<bool>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => EditActivityBottomSheet(
                          activity: activity, categoryId: widget.categoryId),
                    );

                    if (updated == true) {
                      _loadCategory(); // Reload danh mục nếu update thành công
                    }
                  },
                ),
              ),
            )),
      ],
    );
  }

  /// Hộp thoại xác nhận xóa
  Future<bool> _showDeleteConfirmationDialog(String activityId) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Activity'),
            content: const Text('Do you want to delete this activity?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context, true);
                  await _deleteActivity(activityId);
                },
                child: const Text('Yes', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Gọi API xóa Activity
  Future<void> _deleteActivity(String activityId) async {
    try {
      final result = await sl<ActivityRepository>().deleteActivity(activityId);
      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $error')),
        ),
        (data) {
          if (data) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Activity deleted successfully')),
            );
            _loadCategory(); // Load lại danh mục sau khi xóa thành công
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to delete activity')),
            );
          }
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
