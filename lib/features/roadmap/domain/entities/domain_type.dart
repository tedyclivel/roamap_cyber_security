// lib/features/roadmap/domain/entities/domain_type.dart

import 'package:flutter/material.dart';
import 'package:iron_mind/core/theme/app_theme.dart';

enum DomainType {
  physique,
  algorithmique,
  cyber,
  mental,
  linux;

  String get label {
    switch (this) {
      case DomainType.physique:      return 'Physique';
      case DomainType.algorithmique: return 'Algorithmique';
      case DomainType.cyber:         return 'Cybersécurité';
      case DomainType.mental:        return 'Mental';
      case DomainType.linux:         return 'Linux / Dev';
    }
  }

  String get emoji => ''; // Emojis supprimés pour un look plus pro

  Color get color {
    switch (this) {
      case DomainType.physique:      return IronMindColors.physique;
      case DomainType.algorithmique: return IronMindColors.algo;
      case DomainType.cyber:         return IronMindColors.cyber;
      case DomainType.mental:        return IronMindColors.mental;
      case DomainType.linux:         return IronMindColors.linux;
    }
  }

  IconData get icon {
    switch (this) {
      case DomainType.physique:      return Icons.fitness_center_rounded;
      case DomainType.algorithmique: return Icons.code_rounded;
      case DomainType.cyber:         return Icons.security_rounded;
      case DomainType.mental:        return Icons.psychology_rounded;
      case DomainType.linux:         return Icons.terminal_rounded;
    }
  }
}
