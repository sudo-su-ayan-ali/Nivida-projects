import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Label shown above every form control.
class FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const FieldLabel(this.label, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: RichText(
        text: TextSpan(
          text: label,
          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          children: [
            if (required)
              TextSpan(text: ' *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.danger)),
          ],
        ),
      ),
    );
  }
}

InputDecoration _decoration({String? hint, Widget? prefixIcon}) {
  return InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: GoogleFonts.inter(fontSize: 13.5, color: AppColors.textMuted),
    prefixIcon: prefixIcon,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.danger)),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(11), borderSide: const BorderSide(color: AppColors.danger, width: 1.5)),
    errorStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger),
  );
}

class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final bool required;
  final TextInputType keyboardType;
  final int maxLines;
  final IconData? icon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.required = false,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.icon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: _decoration(
            hint: hint,
            prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textMuted) : null,
          ),
          validator: validator ??
              (required
                  ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
                  : null),
        ),
      ],
    );
  }
}

class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  final bool required;
  final IconData? icon;

  const AppDropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.required = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label, required: required),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textMuted),
          style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          decoration: _decoration(prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.textMuted) : null),
          borderRadius: BorderRadius.circular(12),
          items: items
              .map((e) => DropdownMenuItem<T>(value: e, child: Text(labelBuilder(e), overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
          validator: required ? (v) => v == null ? 'Please select an option' : null : null,
        ),
      ],
    );
  }
}

class AppRadioPills extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onChanged;

  const AppRadioPills({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((opt) {
            final active = opt == selected;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 140),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: active ? AppColors.primary : AppColors.border),
                ),
                child: Text(
                  opt,
                  style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.textSecondary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  const PrimaryButton({super.key, required this.label, required this.onPressed, this.icon, this.expand = false});

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
          Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const SecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700)),
    );
  }
}

void showAppSnackBar(BuildContext context, String message, {IconData icon = Icons.check_circle_rounded, Color color = AppColors.success}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      content: Row(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
        ],
      ),
    ),
  );
}
