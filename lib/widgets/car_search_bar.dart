import 'package:flutter/material.dart';

class CarSearchBar extends StatelessWidget {
  const CarSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hint = 'ابحث عن ماركة أو موديل أو مدينة',
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFFF176F), size: 23),
          filled: true,
          fillColor: const Color(0xFF101925),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF26364A))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFF26364A))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: Color(0xFFFF176F), width: 1.4)),
        ),
      ),
    );
  }
}
