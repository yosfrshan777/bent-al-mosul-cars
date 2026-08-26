import 'package:flutter/material.dart';

class CarSearchBar extends StatelessWidget {
  const CarSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilter,
    this.hint = 'ابحث عن ماركة أو موديل أو مدينة',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilter;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFFFF176F),
                  size: 22,
                ),
                filled: true,
                fillColor: const Color(0xFF15151B),
                contentPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF292932),
                  ),
                ),
                enabledBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFF292932),
                  ),
                ),
                focusedBorder:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF176F),
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          if (onFilter != null) ...[
            const SizedBox(width: 9),
            Material(
              color: const Color(0xFF15151B),
              borderRadius:
                  BorderRadius.circular(15),
              child: InkWell(
                onTap: onFilter,
                borderRadius:
                    BorderRadius.circular(15),
                child: Container(
                  width: 53,
                  height: 53,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(15),
                    border: Border.all(
                      color: const Color(
                        0xFF292932,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .tune_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
