import 'package:flutter/material.dart';

class AppShadows {
  // Soft shadows for light elements
  static const soft = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  // Card shadows with subtle depth
  static const cardLight = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  // Dark mode card shadow
  static const cardDark = BoxShadow(
    color: Color(0x40000000),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Primary glow for buttons and highlights
  static const primaryGlow = BoxShadow(
    color: Color(0x294F6EF7),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  // Stronger primary for FABs
  static const primaryStrong = BoxShadow(
    color: Color(0x404F6EF7),
    blurRadius: 24,
    offset: Offset(0, 8),
  );

  // Float shadow for navigation bar
  static const float = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 30,
    offset: Offset(0, 10),
  );

  // Success glow
  static const success = BoxShadow(
    color: Color(0x2910B981),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  // Feature colors glows
  static const waterGlow = BoxShadow(
    color: Color(0x2938BDF8),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const focusGlow = BoxShadow(
    color: Color(0x29A78BFA),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const gymGlow = BoxShadow(
    color: Color(0x29A855F7),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  // Backward compatibility aliases
  static const card = cardLight;
  static const level1 = cardLight;
  static const level2 = float;
  static const primary = primaryGlow;
}