import 'package:flutter/material.dart';
import 'package:my_project/data/models/activity.dart';
import 'package:my_project/domain/repository/activitiy.dart';
import 'package:my_project/service_locator.dart';
import 'package:my_project/data/models/activity_req_params.dart';

class EditActivityBottomSheet extends StatefulWidget {
  final ActivityDb activity;
  final String categoryId;

  const EditActivityBottomSheet(
      {super.key, required this.activity, required this.categoryId});

  @override
  State<EditActivityBottomSheet> createState() =>
      _EditActivityBottomSheetState();
}

class _EditActivityBottomSheetState extends State<EditActivityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.activity.name);
    _descriptionController =
        TextEditingController(text: widget.activity.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateActivity() async {
    setState(() {
      _isLoading = true;
    });

    String name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : widget.activity.name;

    String description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : widget.activity.description;

    final updateParams = ActivityReqParams(
      name: name,
      description: description,
      walletCategoryId: widget.categoryId,
    );

    final result = await sl<ActivityRepository>()
        .updateActivity(widget.activity.id, updateParams);

    result.fold(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $error')),
        );
      },
      (data) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Activity updated successfully')),
        );
        Navigator.pop(context, true); // Đóng BottomSheet và báo thành công
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Activity Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateActivity,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
