import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Description + tap handler for one quick-access login method
/// (biometric, QR code, OTP, ...).
class QuickAccessOption {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickAccessOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// Row of circular quick-access buttons shown under the main sign-in
/// button, e.g. Biometric / QR Code / OTP. Purely presentational — wire
/// each [QuickAccessOption.onTap] to your actual platform integration.
class QuickAccessRow extends StatelessWidget {
  final List<QuickAccessOption> options;

  const QuickAccessRow({super.key, required this.options});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: options.map((opt) => _QuickAccessButton(option: opt)).toList(),
    );
  }
}

class _QuickAccessButton extends StatefulWidget {
  final QuickAccessOption option;
  const _QuickAccessButton({required this.option});

  @override
  State<_QuickAccessButton> createState() => _QuickAccessButtonState();
}

class _QuickAccessButtonState extends State<_QuickAccessButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.option.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
                border: Border.all(color: Colors.white.withOpacity(0.16)),
              ),
              child: Icon(widget.option.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              widget.option.label,
              style: GoogleFonts.inter(
                fontSize: 10.5,
                color: Colors.white60,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
