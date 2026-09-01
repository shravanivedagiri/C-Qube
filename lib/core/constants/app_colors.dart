import 'package:flutter/material.dart';

class AppColors {
  // Primary & Accent Brand Colors
  static const Color primary = Color(0xFF3B50DF); // Deep Indigo
  static const Color primaryLight = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF2537B0);

  static const Color secondary = Color(0xFF8B5CF6); // Electric Violet
  static const Color accent = Color(0xFF06B6D4); // Vibrant Cyan

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Warm Amber
  static const Color error = Color(0xFFEF4444); // Coral Red
  static const Color info = Color(0xFF3B82F6); // Sky Blue

  // Role Badge Colors
  static const Color studentRole = Color(0xFF3B82F6);
  static const Color clubRole = Color(0xFF8B5CF6);

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
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF182238);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkBorder = Color(0xFF1E293B);
  static const Color darkDivider = Color(0xFF1E293B);

  // Category Tag Gradients & Pastels
  static const List<Color> techGradient = [Color(0xFF3B82F6), Color(0xFF1D4ED8)];
  static const List<Color> culturalGradient = [Color(0xFFEC4899), Color(0xFFBE185D)];
  static const List<Color> sportsGradient = [Color(0xFF10B981), Color(0xFF047857)];
  static const List<Color> businessGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> artsGradient = [Color(0xFF8B5CF6), Color(0xFF6D28D9)];
}
