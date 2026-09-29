import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Simple yes/no confirmation dialog. Returns true if the user confirmed.
class ConfirmDeleteDialog extends StatelessWidget {
  final String itemName;
  const ConfirmDeleteDialog({super.key, required this.itemName});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Item?'),
      content: Text('This will permanently remove "$itemName" from the inventory.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
