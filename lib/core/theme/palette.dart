import 'package:flutter/material.dart';

enum PaletteId { forest, midnight, plum, mono }

/// Brand palette - tasarimda Tweaks panelinde secilen "Vera x Uma" renk dunyasi.
class Palette {
  const Palette({
    required this.id,
    required this.brand,
    required this.brandSoft,
    required this.uma,
    required this.umaSoft,
    required this.bgLight,
    required this.bgSoftLight,
    required this.lineLight,
  });

  final PaletteId id;
  final Color brand;
  final Color brandSoft;
  final Color uma;
  final Color umaSoft;
  final Color bgLight;
  final Color bgSoftLight;
  final Color lineLight;

  static const forest = Palette(
    id: PaletteId.forest,
    brand: Color(0xFF0E2A1F),
    brandSoft: Color(0xFF1B4232),
    uma: Color(0xFFC76A26),
    umaSoft: Color(0xFFFBEEDE),
    bgLight: Color(0xFFF4F2EE),
    bgSoftLight: Color(0xFFEFEBE3),
    lineLight: Color(0xFFE7E2D8),
  );

  static const midnight = Palette(
    id: PaletteId.midnight,
    brand: Color(0xFF1A2238),
    brandSoft: Color(0xFF2A3556),
    uma: Color(0xFFE84A5F),
    umaSoft: Color(0xFFFCE9EC),
    bgLight: Color(0xFFF5F4F2),
    bgSoftLight: Color(0xFFEDEBE6),
    lineLight: Color(0xFFE4E2DD),
  );

  static const plum = Palette(
    id: PaletteId.plum,
    brand: Color(0xFF3D2645),
    brandSoft: Color(0xFF5A3A65),
    uma: Color(0xFF2EAB7E),
    umaSoft: Color(0xFFE3F5EC),
    bgLight: Color(0xFFF5F2F4),
    bgSoftLight: Color(0xFFEEEAEE),
    lineLight: Color(0xFFE6E1E5),
  );

  static const mono = Palette(
    id: PaletteId.mono,
    brand: Color(0xFF15171A),
    brandSoft: Color(0xFF2A2D33),
    uma: Color(0xFF4F46E5),
    umaSoft: Color(0xFFEEEDFB),
    bgLight: Color(0xFFF4F4F5),
    bgSoftLight: Color(0xFFEBEBED),
    lineLight: Color(0xFFE2E2E5),
  );

  static const all = [forest, midnight, plum, mono];

  static Palette byId(PaletteId id) => all.firstWhere((p) => p.id == id);
}
