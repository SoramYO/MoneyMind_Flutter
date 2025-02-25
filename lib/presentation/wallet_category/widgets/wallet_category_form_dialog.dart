import 'package:flutter/material.dart';
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
    Key? key,
    this.category,
    required this.userId,
  }) : super(key: key);

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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category == null
                  ? 'Thêm danh mục ví'
                  : 'Chỉnh sửa danh mục ví',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Tên danh mục',
                        hintText: 'Nhập tên danh mục ví',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.account_balance_wallet),
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Vui lòng nhập tên danh mục'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Mô tả',
                        hintText: 'Nhập mô tả cho danh mục',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Vui lòng nhập mô tả' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _iconPathController,
                      decoration: InputDecoration(
                        labelText: 'Đường dẫn biểu tượng',
                        hintText: 'Nhập URL của biểu tượng',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.image),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showColorPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
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
                                    ? 'Chọn màu sắc'
                                    : 'Mã màu: ${_colorController.text}',
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
                        labelText: 'Loại ví',
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
                      onChanged: (value) =>
                          setState(() => _selectedWalletTypeId = value),
                      validator: (value) =>
                          value == null ? 'Vui lòng chọn loại ví' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
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
                    'Hủy',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.category == null ? 'Tạo mới' : 'Cập nhật',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPreview() {
    if (_colorController.text.isEmpty) {
      return const SizedBox.shrink();
    }

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
        border: Border.all(color: Colors.grey.shade300),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return; // Prevent double submission

    setState(() => _isLoading = true);

    try {
      final category = WalletCategory(
        id: widget.category?.id ?? '',
        name: _nameController.text,
        description: _descriptionController.text,
        iconPath: _iconPathController.text.isEmpty ? null : _iconPathController.text,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        walletTypeId: _selectedWalletTypeId!,
        userId: widget.userId,
        activities: widget.category?.activities ?? [],
        walletTypeName: widget.category?.walletTypeName,
        createAt: widget.category?.createAt ?? DateTime.now(),
      );

      final result = widget.category == null
          ? await sl<WalletCategoryRepository>().createWalletCategory(category)
          : await sl<WalletCategoryRepository>().updateWalletCategory(category);

      if (!mounted) return;

      result.fold(
        (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
        (success) {
          if (!mounted) return;
          Navigator.pop(context, success);
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showColorPicker() async {
    final Color? selectedColor = await showDialog(
      context: context,
      builder: (BuildContext context) {
        Color currentColor = _colorController.text.isEmpty
            ? Colors.blue
            : HexColor(_colorController.text);

        return AlertDialog(
          title: const Text('Chọn màu sắc'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: (Color color) {
                currentColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(currentColor),
              child: const Text('Chọn'),
            ),
          ],
        );
      },
    );

    if (selectedColor != null) {
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
