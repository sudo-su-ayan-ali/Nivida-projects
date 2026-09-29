import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A full-width gradient button with a tactile press-scale animation and a
/// built-in loading spinner state, used for the primary "Sign In" action.
class GradientActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<Color> colors;
  final bool loading;
  final VoidCallback? onPressed;

  /// Shown next to the spinner while [loading] is true, e.g.
  /// "AUTHENTICATING…" — gives the wait a high-tech, system-status feel
  /// instead of a bare spinner.
  final String? loadingLabel;

  const GradientActionButton({
    super.key,
    required this.label,
    required this.colors,
    this.icon = Icons.arrow_forward_rounded,
    this.loading = false,
    this.onPressed,
    this.loadingLabel,
  });

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton> {
  double _scale = 1.0;

  void _setScale(double s) => setState(() => _scale = s);

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null || widget.loading;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => _setScale(0.97),
      onTapUp: disabled ? null : (_) => _setScale(1.0),
      onTapCancel: disabled ? null : () => _setScale(1.0),
      onTap: disabled ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: disabled
                  ? [Colors.grey.shade600, Colors.grey.shade700]
                  : widget.colors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: disabled
                ? const <BoxShadow>[]
                : [
                    BoxShadow(
                      color: widget.colors.last.withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Center(
            child: widget.loading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      ),
                      if (widget.loadingLabel != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          widget.loadingLabel!,
                          style: GoogleFonts.robotoMono(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          widget.label,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(widget.icon, color: Colors.white, size: 18),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
