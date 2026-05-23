import 'package:flutter/material.dart';

/// Maps backend `TipIcon` strings to Material icons.
///
/// Backend enum (in `backend/models/ai_coach.py`):
///   muscle | leaf | water | fire | moon | walk | scale | sun
///
/// Unknown values fall back to `leaf`.
class TipIconMap {
  TipIconMap._();

  static IconData iconFor(String name) {
    switch (name) {
      case 'muscle':
        return Icons.fitness_center_rounded;
      case 'leaf':
        return Icons.eco_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'fire':
        return Icons.local_fire_department_rounded;
      case 'moon':
        return Icons.bedtime_rounded;
      case 'walk':
        return Icons.directions_walk_rounded;
      case 'scale':
        return Icons.monitor_weight_rounded;
      case 'sun':
        return Icons.wb_sunny_rounded;
      default:
        return Icons.eco_rounded;
    }
  }

  static Color tintFor(String name) {
    switch (name) {
      case 'muscle':
        return const Color(0xFFE57373); // soft red
      case 'leaf':
        return const Color(0xFF7BE6D5); // seafoam accent
      case 'water':
        return const Color(0xFF14C8D8); // aqua primary
      case 'fire':
        return const Color(0xFFFF8A65); // warm orange
      case 'moon':
        return const Color(0xFF7986CB); // soft indigo
      case 'walk':
        return const Color(0xFF81C784); // soft green
      case 'scale':
        return const Color(0xFFB39DDB); // soft purple
      case 'sun':
        return const Color(0xFFFFD54F); // soft yellow
      default:
        return const Color(0xFF7BE6D5);
    }
  }
}
