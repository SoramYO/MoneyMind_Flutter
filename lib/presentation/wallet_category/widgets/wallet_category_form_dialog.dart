import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:my_project/core/constants/app_icons.dart';
import 'package:my_project/core/utils/hex_color.dart';
import 'package:my_project/data/models/wallet_category.dart';
import 'package:my_project/data/models/wallet_type.dart';
import 'package:my_project/domain/repository/wallet_category.dart';
import 'package:my_project/domain/repository/wallet_type.dart';
import 'package:my_project/service_locator.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class WalletCategoryFormDialog extends StatefulWidget {
  final WalletCategory? category;
  final String userId;

  const WalletCategoryFormDialog({
    super.key,
    this.category,
    required this.userId,
  });

  @override
  State<WalletCategoryFormDialog> createState() =>
      _WalletCategoryFormDialogState();
}

class _WalletCategoryFormDialogState extends State<WalletCategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _iconPathController = TextEditingController();
  final _colorController = TextEditingController();
  String? _selectedIconId;
  String? _selectedWalletTypeId;
  List<WalletType> _walletTypes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description;
      _iconPathController.text = widget.category!.iconPath ?? '';
      _colorController.text = widget.category!.color ?? '';
      _selectedWalletTypeId = widget.category!.walletTypeId;

      // Tìm ID dựa trên iconPath (URL) hiện có
      if (widget.category!.iconPath != null) {
        // Nếu iconPath là đường dẫn URL
        if (widget.category!.iconPath!.startsWith('http')) {
          // Tìm icon ID phù hợp với URL
          _selectedIconId = AppIcons.walletCategoryIcons
              .firstWhere(
                (icon) => icon.link == widget.category!.iconPath,
                orElse: () => AppIcons.walletCategoryIcons.first,
              )
              .id;
        } else {
          // Nếu iconPath đã là ID
          _selectedIconId = widget.category!.iconPath;
        }
      }
    }
    _loadWalletTypes();
  }

  Future<void> _loadWalletTypes() async {
    final result = await sl<WalletTypeRepository>().getWalletType(1, 100);
    result.fold(
      (error) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error))),
      (types) => setState(() => _walletTypes = types),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.all(24),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category == null
                      ? 'Add Wallet Category'
                      : 'Edit Wallet Category',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Category name',
                    hintText: 'Enter wallet category name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.account_balance_wallet),
                  ),
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter category name'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter description',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                  validator: (value) => value?.isEmpty ?? true
                      ? 'Please enter description'
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      _selectedIconId, // Use the selected icon ID as the value
                  decoration: InputDecoration(
                    labelText: 'Icon',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: _selectedIconId != null
                        ? Icon(AppIcons.getIconById(_selectedIconId!))
                        : const Icon(Icons.image),
                  ),
                  items: AppIcons.walletCategoryIcons
                      .map((appIcon) => DropdownMenuItem<String>(
                            value: appIcon.id,
                            child: Row(
                              children: [
                                // Nếu có link và link không rỗng
                                appIcon.link != null && appIcon.link!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: CachedNetworkImage(
                                          imageUrl: appIcon.link!,
                                          width: 24,
                                          height: 24,
                                          fit: BoxFit.cover,
                                          errorWidget: (ctx, url, err) =>
                                              Icon(appIcon.icon),
                                        ),
                                      )
                                    : Icon(appIcon.icon),
                                const SizedBox(width: 10),
                                Text(appIcon.name),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIconId = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select an icon' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.color_lens, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _colorController.text.isEmpty
                                ? 'Choose color'
                                : 'Color code: ${_colorController.text}',
                            style: TextStyle(
                              color: _colorController.text.isEmpty
                                  ? Colors.grey.shade600
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (_colorController.text.isNotEmpty)
                          _buildColorPreview(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedWalletTypeId,
                  decoration: InputDecoration(
                    labelText: 'Wallet type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: _walletTypes
                      .map((type) => DropdownMenuItem(
                          value: type.id, child: Text(type.name)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _selectedWalletTypeId = value),
                  validator: (value) =>
                      value == null ? 'Please choose wallet type' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
          child: const Text('Cancel', style: TextStyle(fontSize: 16)),
        ),
        if (_isLoading)
          const CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(widget.category == null ? 'Create New' : 'Update',
                style: const TextStyle(fontSize: 16)),
          ),
      ],
    );
  }

  Widget _buildColorPreview() {
    Color? color;
    try {
      color = HexColor(_colorController.text);
    } catch (_) {
      return const Icon(Icons.error, color: Colors.red);
    }
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300)),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Lấy URL của icon dựa trên ID đã chọn
    String? iconPath;
    if (_selectedIconId != null) {
      // Lấy link từ ID được chọn
      iconPath = AppIcons.getLinkById(_selectedIconId!);
    }

    // Nếu không có link từ ID, giữ lại iconPath cũ (nếu có)
    if (iconPath == null || iconPath.isEmpty) {
      iconPath = widget.category?.iconPath;
    }

    final walletCategory = WalletCategory(
      id: widget.category?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      iconPath: iconPath,
      color: _colorController.text.isEmpty ? null : _colorController.text,
      createAt: widget.category?.createAt ?? DateTime.now(),
      isActive: true,
      userId: widget.userId,
      walletTypeId: _selectedWalletTypeId ?? '',
      walletTypeName: widget.category?.walletTypeName ?? '',
      walletTypeDescription: widget.category?.walletTypeDescription ?? '',
      activities: widget.category?.activities ?? [],
    );

    try {
      final result = widget.category == null
          ? await sl<WalletCategoryRepository>()
              .createWalletCategory(walletCategory)
          : await sl<WalletCategoryRepository>()
              .updateWalletCategory(walletCategory);

      if (!mounted) return;

      result.fold(
        (error) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: Colors.red)),
        (data) => Navigator.pop(context, data),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showColorPicker() async {
    Color pickerColor = _colorController.text.isEmpty
        ? Colors.blue
        : HexColor(_colorController.text);

    final Color? selectedColor = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            showLabel: true,
            paletteType: PaletteType.hsv,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, pickerColor),
              child: const Text('Select')),
        ],
      ),
    );

    if (selectedColor != null && mounted) {
      setState(() {
        _colorController.text =
            '#${selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _iconPathController.dispose();
    _colorController.dispose();
    super.dispose();
  }
}
