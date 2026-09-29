import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

/// Common dialog shell: gradient icon, title/subtitle header, close button,
/// scrollable body and an optional footer. Used by every quick-action form
/// and every "view all / view report" detail dialog so the whole app shares
/// one consistent, professional dialog language.
class AppDialog extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Widget child;
  final double width;
  final Widget? footer;
  final EdgeInsetsGeometry contentPadding;

  const AppDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.color = AppColors.primary,
    this.width = 480,
    this.footer,
    this.contentPadding = const EdgeInsets.fromLTRB(24, 20, 24, 24),
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width < width + 40 ? screenSize.width - 32 : width;
    final maxHeight = screenSize.height * 0.86;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: AppShadows.hover,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Header(title: title, subtitle: subtitle, icon: icon, color: color),
              Flexible(
                child: SingleChildScrollView(
                  padding: contentPadding,
                  child: child,
                ),
              ),
              if (footer != null)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.borderSoft)),
                  ),
                  child: footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  const _Header({required this.title, required this.subtitle, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 16, 18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          _CloseButton(onTap: () => Navigator.of(context).pop()),
        ],
      ),
    );
  }
}

class _CloseButton extends StatefulWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  State<_CloseButton> createState() => _CloseButtonState();
}

class _CloseButtonState extends State<_CloseButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _hovering ? const Color(0xFFF1F5F9) : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Icon(Icons.close_rounded, size: 19, color: AppColors.textMuted),
        ),
      ),
    );
  }
}

/// Standard Cancel / Submit footer row for form dialogs.
class DialogFormFooter extends StatelessWidget {
  final String submitLabel;
  final IconData submitIcon;
  final VoidCallback onSubmit;
  const DialogFormFooter({super.key, required this.submitLabel, required this.onSubmit, this.submitIcon = Icons.check_rounded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: SecondaryButtonFullWidth(label: 'Cancel', onPressed: () => Navigator.of(context).pop())),
        const SizedBox(width: 12),
        Expanded(child: PrimaryButtonFullWidth(label: submitLabel, icon: submitIcon, onPressed: onSubmit)),
      ],
    );
  }
}

class PrimaryButtonFullWidth extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const PrimaryButtonFullWidth({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 17), const SizedBox(width: 8)],
          Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class SecondaryButtonFullWidth extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const SecondaryButtonFullWidth({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      ),
      child: Text(label, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700)),
    );
  }
}
