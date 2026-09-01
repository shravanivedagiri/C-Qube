import 'package:flutter/material.dart';

class AppColors {
  // Primary & Accent Brand Colors (Professional Pastel/Muted Slate & Lavender)
  static const Color primary = Color(0xFF4F46E5); // Soft Slate Blue
  static const Color primaryLight = Color(0xFF818CF8); // Muted Blue Pastel
  static const Color primaryDark = Color(0xFF3730A3);

  static const Color secondary = Color(0xFF7C3AED); // Professional Soft Violet
  static const Color accent = Color(0xFF0D9488); // Soft Teal Pastel

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Soft Sage/Emerald
  static const Color warning = Color(0xFFF59E0B); // Warm Amber
  static const Color error = Color(0xFFEF4444); // Soft Red
  static const Color info = Color(0xFF3B82F6); // Soft Sky Blue

  // Role Badge Colors
  static const Color studentRole = Color(0xFF3B82F6);
  static const Color clubRole = Color(0xFF7C3AED);

  // Light Mode Colors
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightDivider = Color(0xFFF1F5F9);

  // Dark Mode Colors
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkDivider = Color(0xFF334155);

  // Category Tag Gradients & Pastels
  static const List<Color> techGradient = [Color(0xFF4F46E5), Color(0xFF3730A3)];
  static const List<Color> culturalGradient = [Color(0xFFDB2777), Color(0xFF9D174D)];
  static const List<Color> sportsGradient = [Color(0xFF059669), Color(0xFF047857)];
  static const List<Color> businessGradient = [Color(0xFFD97706), Color(0xFFB45309)];
  static const List<Color> artsGradient = [Color(0xFF7C3AED), Color(0xFF5B21B6)];
}
