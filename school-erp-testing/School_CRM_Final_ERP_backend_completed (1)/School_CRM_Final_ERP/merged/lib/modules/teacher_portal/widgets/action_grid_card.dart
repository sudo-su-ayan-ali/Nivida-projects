import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'common/app_card.dart';

class ActionGridCard extends StatelessWidget {
  final String title;
  final List<ActionTile> tiles;
  final int columns;
  final void Function(ActionTile tile)? onTileTap;
  final bool wrapInCard;

  const ActionGridCard({
    super.key,
    required this.title,
    required this.tiles,
    this.columns = 3,
    this.onTileTap,
    this.wrapInCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        const SizedBox(height: 16),
        LayoutBuilder(builder: (context, constraints) {
          const spacing = 12.0;
          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: tiles
                .map((t) => SizedBox(
                      width: width,
                      child: _ActionTileWidget(tile: t, onTap: onTileTap == null ? null : () => onTileTap!(t)),
                    ))
                .toList(),
          );
        }),
      ],
    );

    if (!wrapInCard) return content;
    return AppCard(child: content);
  }
}

class _ActionTileWidget extends StatefulWidget {
  final ActionTile tile;
  final VoidCallback? onTap;
  const _ActionTileWidget({required this.tile, this.onTap});

  @override
  State<_ActionTileWidget> createState() => _ActionTileWidgetState();
}

class _ActionTileWidgetState extends State<_ActionTileWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap ??
            () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${widget.tile.label} opened'), duration: const Duration(seconds: 1)),
                ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: _hovering ? AppColors.primaryLight : AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _hovering ? AppColors.primary.withOpacity(0.35) : AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.tile.icon, size: 22, color: _hovering ? AppColors.primary : AppColors.textPrimary),
              const SizedBox(height: 8),
              Text(
                widget.tile.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.toolLabel,
              ),
              if (widget.tile.sub.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(widget.tile.sub, textAlign: TextAlign.center, style: AppTextStyles.toolSub),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
