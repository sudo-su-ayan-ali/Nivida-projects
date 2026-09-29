import 'package:flutter/material.dart';
import '../controller/settings_controller.dart';

/// Lightweight, dependency-free toast notification shown via [OverlayEntry].
class ToastHost extends StatefulWidget {
  final SettingsController controller;
  final Widget child;

  const ToastHost({super.key, required this.controller, required this.child});

  @override
  State<ToastHost> createState() => _ToastHostState();
}

class _ToastHostState extends State<ToastHost> {
  OverlayEntry? _entry;

  @override
  void initState() {
    super.initState();
    widget.controller.toastNotifier.addListener(_onToast);
  }

  @override
  void dispose() {
    widget.controller.toastNotifier.removeListener(_onToast);
    super.dispose();
  }

  void _onToast() {
    final event = widget.controller.toastNotifier.value;
    if (event == null) return;
    _show(event.message, event.type);
  }

  void _show(String message, ToastType type) {
    _entry?.remove();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => _ToastCard(message: message, type: type),
    );
    _entry = entry;
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 2600), () {
      entry.remove();
      if (_entry == entry) _entry = null;
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ToastCard extends StatelessWidget {
  final String message;
  final ToastType type;
  const _ToastCard({required this.message, required this.type});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    switch (type) {
      case ToastType.success:
        color = const Color(0xFF22B573);
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.warning:
        color = const Color(0xFFF59E0B);
        icon = Icons.refresh_rounded;
        break;
      case ToastType.info:
        color = const Color(0xFF2F6FED);
        icon = Icons.info_rounded;
        break;
    }

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      right: 20,
      left: 20,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.topRight,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * -12),
                child: child,
              ),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2436),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border(left: BorderSide(color: color, width: 4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
