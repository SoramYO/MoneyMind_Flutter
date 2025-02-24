import 'package:flutter/material.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/service_locator.dart';

import '../../../data/models/activity_req_params.dart';

class AddActivityBottomSheet extends StatefulWidget {
  final String categoryId;

  const AddActivityBottomSheet({super.key, required this.categoryId});

  @override
  State<AddActivityBottomSheet> createState() => _AddActivityBottomSheetState();
}

class _AddActivityBottomSheetState extends State<AddActivityBottomSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  bool _isLoading = false;
  String? _nameError;
  String? _descriptionError;

  Future<void> _saveActivity() async {
    setState(() {
      _nameError = _nameController.text.isEmpty ? 'Required field' : null;
      _descriptionError =
          _descriptionController.text.isEmpty ? 'Required field' : null;
    });

    if (_nameError != null || _descriptionError != null) return;

    setState(() {
      _isLoading = true;
    });

    // Tạo đối tượng CreateReqActivityParams
    final params = ActivityReqParams(
      name: _nameController.text,
      description: _descriptionController.text,
      walletCategoryId: widget.categoryId,
    );

    // Giả lập gọi API (thay thế bằng API thực tế)
    await Future.delayed(const Duration(seconds: 2));

    String message = "";

    try {
      final result = await sl<ActivityRepository>().createActivity(params);

      result.fold(
        (error) => setState(() {
          message = error;
          _isLoading = false;
        }),
        (data) => setState(() {
          message = data;
          _isLoading = false;
        }),
      );
    } catch (e) {
      setState(() {
        message = e.toString();
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });

    // Đóng BottomSheet và trả về thông báo
    if (context.mounted) {
      Navigator.pop(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Add Activity',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
              errorText: _nameError,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description *',
              border: OutlineInputBorder(),
              errorText: _descriptionError,
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveActivity,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Save'),
          ),
        ],
      ),
    );
  }
}
