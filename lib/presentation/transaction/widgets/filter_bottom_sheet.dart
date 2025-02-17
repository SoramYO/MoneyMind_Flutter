import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

class FilterBottomSheet extends StatefulWidget {
  final bool? isCategorized;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isDescending;
  final Function(FilterOptions) onApply;
  final VoidCallback onClear;

  const FilterBottomSheet({
    super.key,
    this.isCategorized,
    this.fromDate,
    this.toDate,
    required this.isDescending,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late bool? isCategorized;
  late DateTime? fromDate;
  late DateTime? toDate;
  late bool isDescending;

  @override
  void initState() {
    super.initState();
    isCategorized = widget.isCategorized;
    fromDate = widget.fromDate;
    toDate = widget.toDate;
    isDescending = widget.isDescending;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<bool?>(
            value: isCategorized,
            decoration: const InputDecoration(labelText: 'Category Filter'),
            items: const [
              DropdownMenuItem(value: null, child: Text('All')),
              DropdownMenuItem(value: true, child: Text('Categorized')),
              DropdownMenuItem(value: false, child: Text('Uncategorized')),
            ],
            onChanged: (value) => setState(() => isCategorized = value),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(fromDate != null 
                    ? DateFormat('dd/MM/yyyy').format(fromDate!)
                    : 'From Date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: fromDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => fromDate = date);
                    }
                  },
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(toDate != null 
                    ? DateFormat('dd/MM/yyyy').format(toDate!)
                    : 'To Date'),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: toDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => toDate = date);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Sort Descending'),
            value: isDescending,
            onChanged: (value) => setState(() => isDescending = value),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              widget.onApply(FilterOptions(
                isCategorized: isCategorized,
                fromDate: fromDate,
                toDate: toDate,
                isDescending: isDescending,
              ));
              Navigator.pop(context);
            },
            child: const Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}

class FilterOptions {
  final bool? isCategorized;
  final DateTime? fromDate;
  final DateTime? toDate;
  final bool isDescending;

  FilterOptions({
    this.isCategorized,
    this.fromDate,
    this.toDate,
    required this.isDescending,
  });
} 