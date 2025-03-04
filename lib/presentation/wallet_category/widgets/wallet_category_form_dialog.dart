import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_project/core/services/storage_service.dart';
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
  String? _selectedWalletTypeId;
  List<WalletType> _walletTypes = [];
  bool _isLoading = false;
  File? _selectedImage;
  final StorageService _storageService = StorageService();

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

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          // Just store the file reference, don't upload yet
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
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
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : _iconPathController.text.isNotEmpty &&
                                _iconPathController.text.startsWith('http')
                            ? Image.network(_iconPathController.text,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                return _buildImagePlaceholder();
                              })
                            : _buildImagePlaceholder(),
                  ),
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

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text('Chọn hình ảnh', style: TextStyle(color: Colors.grey)),
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

    String? iconPath = _iconPathController.text.isNotEmpty
        ? _iconPathController.text
        : widget.category?.iconPath;

    // Upload ảnh nếu đã chọn
    if (_selectedImage != null) {
      try {
        iconPath = await _storageService.uploadFile(
            _selectedImage!, 'wallet_category_icons');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        return;
      }
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
