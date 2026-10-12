import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class UnitChip extends StatelessWidget {
  const UnitChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.warn = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Highlights the chip while no unit has been chosen for the item yet.
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySoft : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected
              ? AppColors.primary
              : (warn ? AppColors.warning.withValues(alpha: 0.6) : AppColors.border),
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected) ...[
                const Icon(Icons.check_rounded,
                    size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
              ],
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.5,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StepButton extends StatelessWidget {
  const StepButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: filled ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 18,
            color: filled
                ? Colors.white
                : (enabled ? AppColors.textDark : AppColors.border),
          ),
        ),
      ),
    );
  }
}
