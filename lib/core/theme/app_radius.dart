import 'package:flutter/material.dart';

class AppRadius {
  static const Radius xs = Radius.circular(6);
  static const Radius sm = Radius.circular(10);
  static const Radius md = Radius.circular(14);
  static const Radius lg = Radius.circular(18);
  static const Radius xl = Radius.circular(22);
  static const Radius xxl = Radius.circular(28);
  static const Radius pill = Radius.circular(999);

  // BorderRadius shortcuts
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(22));
  static const BorderRadius buttonRadius = BorderRadius.all(
    Radius.circular(14),
  );
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(999));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(28),
  );

  // Legacy compatibility aliases
  static Radius get circularS => sm;
  static Radius get circularM => md;
  static Radius get circularL => lg;
  static BorderRadius get roundedSm =>
      const BorderRadius.all(Radius.circular(8));
  static BorderRadius get roundedMd =>
      const BorderRadius.all(Radius.circular(12));
  static BorderRadius get roundedLg =>
      const BorderRadius.all(Radius.circular(16));
  static BorderRadius get roundedXl => cardRadius;
}
