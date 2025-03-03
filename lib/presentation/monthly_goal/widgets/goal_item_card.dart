import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/core/constants/app_colors.dart';
import 'package:my_project/data/models/goal_item.dart';

class GoalItemCard extends StatelessWidget {
  final GoalItem goalItem;

  const GoalItemCard({
    super.key,
    required this.goalItem,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      goalItem.walletTypeName.toString(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: goalItem.isAchieved
                            ? AppColors.text
                            : AppColors.error,
                      ),
                    ),
                    const SizedBox(
                        width: 5), // Thêm khoảng cách giữa text và icon
                    Icon(
                      goalItem.isAchieved ? Icons.check_circle : Icons.cancel,
                      color: goalItem.isAchieved ? Colors.green : Colors.red,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  goalItem.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Used Amount: ${NumberFormat('#,###').format(goalItem.usedAmount)}đ',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Used: ${NumberFormat('#.##').format(goalItem.usedPercentage)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Target Mode: ${getTargetModeText(goalItem.targetMode)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildInfoChip(
                      'Target: ${NumberFormat('#.##').format(goalItem.minTargetPercentage)}%',
                      Icons.trending_down,
                    ),
                    _buildInfoChip(
                      'Target: ${NumberFormat('#.##').format(goalItem.maxTargetPercentage)}%',
                      Icons.trending_up,
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildInfoChip(
                      'Amount: ${NumberFormat('#,###').format(goalItem.minAmount)}đ',
                      Icons.arrow_downward,
                    ),
                    _buildInfoChip(
                      'Amount: ${NumberFormat('#,###').format(goalItem.maxAmount)}đ',
                      Icons.arrow_upward,
                    ),
                  ],
                ),
              ],
            ),
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

// Hàm chuyển đổi targetMode thành chuỗi văn bản
String getTargetModeText(int targetMode) {
  switch (targetMode) {
    case 0:
      return 'Max Only'; // Chỉ kiểm tra giá trị tối đa
    case 1:
      return 'Min Only'; // Chỉ kiểm tra giá trị tối thiểu
    case 2:
      return 'Range'; // Kiểm tra theo khoảng (min-max)
    case 3:
      return 'Percentage Only'; // Kiểm tra tỷ lệ phần trăm
    case 4:
      return 'Fixed Amount'; // Giá trị cố định
    case 5:
      return 'No Target'; // Không có mục tiêu cụ thể
    default:
      return 'Unknown'; // Trường hợp không xác định
  }
}
