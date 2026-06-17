import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Seed — from previous app's accent color ─────────────────
  static const Color seed = Color(0xFF378ADD);

  // ── Neutrals — from previous app's slate palette ─────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey100 = Color(0xFFF1F5F9);
  static const Color grey300 = Color(0xFFE5E7EB);
  static const Color grey600 = Color(0xFF64748B);
  static const Color grey900 = Color(0xFF0F172A);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFEF9F27);
  static const Color error = Color(0xFFE53935);
}