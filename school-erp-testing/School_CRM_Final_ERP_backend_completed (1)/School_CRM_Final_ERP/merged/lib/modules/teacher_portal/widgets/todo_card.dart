import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dashboard_models.dart';
import '../state/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({super.key});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  final TextEditingController _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit(AppState app) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    app.addTodo(text);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final pending = app.todos.where((t) => !t.done).length;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My To-Do List', style: AppTextStyles.sectionTitle),
              Text('$pending pending', style: AppTextStyles.itemSub),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  onSubmitted: (_) => _submit(app),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add a reminder...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    filled: true,
                    fillColor: AppColors.scaffoldBg,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _submit(app),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (app.todos.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('No reminders yet — add one above.', style: AppTextStyles.itemSub),
            )
          else
            for (final t in app.todos.take(6)) _TodoRow(item: t),
        ],
      ),
    );
  }
}

class _TodoRow extends StatelessWidget {
  final TodoItem item;
  const _TodoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          InkWell(
            onTap: () => app.toggleTodo(item.id),
            borderRadius: BorderRadius.circular(6),
            child: Icon(
              item.done ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: item.done ? AppColors.green : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.title,
              style: AppTextStyles.itemSub.copyWith(
                color: item.done ? AppColors.textMuted : AppColors.textPrimary,
                decoration: item.done ? TextDecoration.lineThrough : null,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          InkWell(
            onTap: () => app.deleteTodo(item.id),
            child: const Icon(Icons.close, size: 15, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}
