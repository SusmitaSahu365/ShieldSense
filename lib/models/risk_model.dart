// lib/models/risk_model.dart

enum RiskLevel { safe, low, moderate, high, critical }

enum MonitoringState {
  idle,
  setup,
  monitoring,
  escalating,
  alerting,
  emergency,
  ended,
}

class RiskSignal {
  final String id;
  final String label;
  final double value; // 0.0 - 1.0
  final String icon;

  const RiskSignal({
    required this.id,
    required this.label,
    required this.value,
    required this.icon,
  });

  RiskSignal copyWith({double? value}) =>
      RiskSignal(id: id, label: label, value: value ?? this.value, icon: icon);
}

class PSISnapshot {
  final double psi; // 0.0 - 1.0
  final RiskLevel level;
  final DateTime timestamp;
  final List<RiskSignal> signals;
  final bool isEscalating;

  const PSISnapshot({
    required this.psi,
    required this.level,
    required this.timestamp,
    required this.signals,
    required this.isEscalating,
  });
}

extension RiskLevelX on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.safe: return 'SAFE';
      case RiskLevel.low: return 'LOW RISK';
      case RiskLevel.moderate: return 'MODERATE';
      case RiskLevel.high: return 'HIGH RISK';
      case RiskLevel.critical: return 'CRITICAL';
    }
  }

  String get description {
    switch (this) {
      case RiskLevel.safe: return 'No threats detected. Continue monitoring.';
      case RiskLevel.low: return 'Slight signals detected. Staying alert.';
      case RiskLevel.moderate: return 'Risk elevated. Consider relocating.';
      case RiskLevel.high: return 'High risk! Check in with trusted contact.';
      case RiskLevel.critical: return 'EMERGENCY — Contacting help now!';
    }
  }

  // Colors as hex integers
  int get colorValue {
    switch (this) {
      case RiskLevel.safe: return 0xFF00E5A0;
      case RiskLevel.low: return 0xFF8BC34A;
      case RiskLevel.moderate: return 0xFFFFD166;
      case RiskLevel.high: return 0xFFFF9F1C;
      case RiskLevel.critical: return 0xFFFF3366;
    }
  }
}

RiskLevel psiToLevel(double psi) {
  if (psi < 0.2) return RiskLevel.safe;
  if (psi < 0.4) return RiskLevel.low;
  if (psi < 0.6) return RiskLevel.moderate;
  if (psi < 0.8) return RiskLevel.high;
  return RiskLevel.critical;
}
