import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onMore,
    this.moreText = 'عرض الكل',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onMore;
  final String moreText;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onMore != null) ...[
            const SizedBox(width: 10),
            TextButton(
              onPressed: onMore,
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color(0xFFFF176F),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    moreText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 3),
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
