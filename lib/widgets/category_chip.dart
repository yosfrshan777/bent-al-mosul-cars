import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.title,
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 11,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF176F)
                : const Color(0xFF15151B),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF176F)
                  : const Color(0xFF292932),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : const Color(0xFFFF176F),
              ),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w900
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
