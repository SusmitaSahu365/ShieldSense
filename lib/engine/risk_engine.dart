// lib/engine/risk_engine.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/risk_model.dart';

// ─── Scenario presets ────────────────────────────────────────────────────────
class Scenario {
  final String name;
  final Map<String, double> baseSignals;
  const Scenario({required this.name, required this.baseSignals});
}

const kScenarios = [
  Scenario(name: 'Normal Day', baseSignals: {
    'conversation': 0.10, 'emotion': 0.12, 'environment': 0.08,
  }),
  Scenario(name: 'Tense Argument', baseSignals: {
    'conversation': 0.52, 'emotion': 0.60, 'environment': 0.35,
  }),
  Scenario(name: 'Suspicious Area', baseSignals: {
    'conversation': 0.30, 'emotion': 0.40, 'environment': 0.70,
  }),
  Scenario(name: 'Escalating Threat', baseSignals: {
    'conversation': 0.80, 'emotion': 0.85, 'environment': 0.75,
  }),
];

// ─── State ───────────────────────────────────────────────────────────────────
class RiskEngineState {
  final MonitoringState monitoringState;
  final List<RiskSignal> signals;
  final double psi;
  final RiskLevel riskLevel;
  final bool isEscalating;
  final List<PSISnapshot> history;
  final int scenarioIndex;
  final List<String> eventLog;
  final int sessionSeconds;

  const RiskEngineState({
    this.monitoringState = MonitoringState.idle,
    this.signals = const [],
    this.psi = 0.0,
    this.riskLevel = RiskLevel.safe,
    this.isEscalating = false,
    this.history = const [],
    this.scenarioIndex = 0,
    this.eventLog = const [],
    this.sessionSeconds = 0,
  });

  RiskEngineState copyWith({
    MonitoringState? monitoringState,
    List<RiskSignal>? signals,
    double? psi,
    RiskLevel? riskLevel,
    bool? isEscalating,
    List<PSISnapshot>? history,
    int? scenarioIndex,
    List<String>? eventLog,
    int? sessionSeconds,
  }) =>
      RiskEngineState(
        monitoringState: monitoringState ?? this.monitoringState,
        signals: signals ?? this.signals,
        psi: psi ?? this.psi,
        riskLevel: riskLevel ?? this.riskLevel,
        isEscalating: isEscalating ?? this.isEscalating,
        history: history ?? this.history,
        scenarioIndex: scenarioIndex ?? this.scenarioIndex,
        eventLog: eventLog ?? this.eventLog,
        sessionSeconds: sessionSeconds ?? this.sessionSeconds,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class RiskEngineNotifier extends StateNotifier<RiskEngineState> {
  RiskEngineNotifier() : super(const RiskEngineState()) {
    _initSignals();
  }

  Timer? _monitorTimer;
  Timer? _sessionTimer;
  final _rng = Random();
  double _prevPsi = 0.0;

  static const _signalDefs = [
    {'id': 'conversation', 'label': 'Conversational Risk', 'icon': '💬'},
    {'id': 'emotion', 'label': 'Emotional Stress', 'icon': '🎙'},
    {'id': 'environment', 'label': 'Environmental Risk', 'icon': '📍'},
  ];

  void _initSignals() {
    final signals = _signalDefs.map((d) => RiskSignal(
      id: d['id']!,
      label: d['label']!,
      value: 0.0,
      icon: d['icon']!,
    )).toList();
    state = state.copyWith(signals: signals);
  }

  // ── Flowchart: Step 1 - Setup ─────────────────────────────────────────────
  void startSetup() {
    state = state.copyWith(
      monitoringState: MonitoringState.setup,
      eventLog: ['[${_ts()}] Baseline setup started...'],
    );
    // Simulate setup delay
    Future.delayed(const Duration(seconds: 2), startMonitoring);
  }

  // ── Flowchart: Step 2 - Start Monitoring ─────────────────────────────────
  void startMonitoring() {
    _log('Monitoring started. Scenario: ${kScenarios[state.scenarioIndex].name}');
    state = state.copyWith(
      monitoringState: MonitoringState.monitoring,
      history: [],
      sessionSeconds: 0,
    );
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(sessionSeconds: state.sessionSeconds + 1);
    });
    _monitorTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      _runAnalysisCycle();
    });
  }

  // ── Flowchart: Continuous Risk Analysis Loop ──────────────────────────────
  void _runAnalysisCycle() {
    // Step A: Compute each signal with noise
    final scenario = kScenarios[state.scenarioIndex];
    final newSignals = state.signals.map((s) {
      final base = scenario.baseSignals[s.id] ?? 0.1;
      final noise = (_rng.nextDouble() - 0.5) * 0.12;
      final v = (base + noise).clamp(0.0, 1.0);
      return s.copyWith(value: v);
    }).toList();

    // Step B: Weighted PSI = conversation(40%) + emotion(40%) + environment(20%)
    final weights = {'conversation': 0.40, 'emotion': 0.40, 'environment': 0.20};
    double rawPsi = 0.0;
    for (final s in newSignals) {
      rawPsi += s.value * (weights[s.id] ?? 0.0);
    }
    // Smooth it
    final psi = (_prevPsi * 0.6 + rawPsi * 0.4).clamp(0.0, 1.0);
    _prevPsi = psi;
    final level = psiToLevel(psi);

    // Step C: Is Risk Escalating? (PSI trending up over last 3 snapshots)
    final recentHistory = state.history.takeLast(3).toList();
    bool escalating = false;
    if (recentHistory.length >= 3) {
      final trend = psi - recentHistory.first.psi;
      escalating = trend > 0.08;
    }

    // Record snapshot
    final snapshot = PSISnapshot(
      psi: psi,
      level: level,
      timestamp: DateTime.now(),
      signals: newSignals,
      isEscalating: escalating,
    );
    final newHistory = [...state.history, snapshot];
    if (newHistory.length > 40) newHistory.removeAt(0);

    // Update state
    state = state.copyWith(
      signals: newSignals,
      psi: psi,
      riskLevel: level,
      isEscalating: escalating,
      history: newHistory,
    );

    // Step D: Route based on risk level (flowchart branches)
    _routeByRisk(level, escalating);
  }

  void _routeByRisk(RiskLevel level, bool escalating) {
    if (!escalating && level.index < RiskLevel.moderate.index) {
      // No escalation → Continue Silent Monitoring
      if (state.monitoringState != MonitoringState.monitoring) {
        state = state.copyWith(monitoringState: MonitoringState.monitoring);
        _log('Returned to silent monitoring.');
      }
      return;
    }

    switch (level) {
      case RiskLevel.safe:
      case RiskLevel.low:
        // Continue silent monitoring
        if (state.monitoringState != MonitoringState.monitoring) {
          state = state.copyWith(monitoringState: MonitoringState.monitoring);
        }
        break;

      case RiskLevel.moderate:
        // Subtle Alert
        if (state.monitoringState != MonitoringState.alerting) {
          state = state.copyWith(monitoringState: MonitoringState.alerting);
          _log('⚠️ SUBTLE ALERT: Vibration triggered. Suggesting relocation.');
        }
        break;

      case RiskLevel.high:
        // Safety Prompt
        if (state.monitoringState != MonitoringState.escalating) {
          state = state.copyWith(monitoringState: MonitoringState.escalating);
          _log('🟠 SAFETY PROMPT: Check-in confirmation sent. Suggest trusted contact.');
        }
        break;

      case RiskLevel.critical:
        // Emergency Intervention
        if (state.monitoringState != MonitoringState.emergency) {
          state = state.copyWith(monitoringState: MonitoringState.emergency);
          _log('🚨 EMERGENCY: Auto-alert sent. Live location shared. Auto-call triggered.');
        }
        break;
    }
  }

  void setScenario(int index) {
    _prevPsi = 0.0;
    state = state.copyWith(scenarioIndex: index);
    _log('Scenario changed → ${kScenarios[index].name}');
  }

  void stopMonitoring() {
    _monitorTimer?.cancel();
    _sessionTimer?.cancel();
    state = state.copyWith(
      monitoringState: MonitoringState.ended,
    );
    _log('Monitoring session ended.');
  }

  void reset() {
    _monitorTimer?.cancel();
    _sessionTimer?.cancel();
    _prevPsi = 0.0;
    state = const RiskEngineState();
    _initSignals();
  }

  void _log(String msg) {
    final log = [...state.eventLog, '[${_ts()}] $msg'];
    if (log.length > 50) log.removeAt(0);
    state = state.copyWith(eventLog: log);
  }

  String _ts() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────────
final riskEngineProvider =
    StateNotifierProvider<RiskEngineNotifier, RiskEngineState>(
  (_) => RiskEngineNotifier(),
);

extension IterableLastN<T> on Iterable<T> {
  Iterable<T> takeLast(int n) {
    final list = toList();
    if (list.length <= n) return list;
    return list.sublist(list.length - n);
  }
}
