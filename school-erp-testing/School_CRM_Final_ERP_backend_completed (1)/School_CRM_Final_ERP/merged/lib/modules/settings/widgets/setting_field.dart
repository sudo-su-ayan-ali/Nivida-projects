import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A single labeled field. If [options] is provided it renders as a
/// dropdown, otherwise as a free-text field.
class SettingField extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<String>? options;
  final bool dark;
  final ValueChanged<String> onChanged;

  const SettingField({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    required this.onChanged,
    this.options,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final fieldBg = dark ? const Color(0xFF11172A) : Colors.white;
    final borderColor = dark ? AppColors.cardBorderDark : AppColors.cardBorder;

    final effectiveOptions = options == null
        ? null
        : (options!.contains(value)
            ? options!
            : (value.isNotEmpty ? [...options!, value] : options!));
    final effectiveValue = options == null
        ? value
        : (effectiveOptions!.contains(value) ? value : effectiveOptions.first);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 15,
                color: dark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: fieldBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: effectiveOptions == null
              ? TextFormField(
                  initialValue: value,
                  onChanged: onChanged,
                  style: TextStyle(fontSize: 13.5, color: labelColor),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                )
              : DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: effectiveValue,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary),
                    style: TextStyle(fontSize: 13.5, color: labelColor),
                    dropdownColor: dark ? AppColors.cardWhiteDark : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    items: effectiveOptions
                        .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onChanged(v);
                    },
                  ),
                ),
        ),
      ],
    );
  }
}
