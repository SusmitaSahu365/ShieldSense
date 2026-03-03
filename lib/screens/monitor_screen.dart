// lib/screens/monitor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../engine/risk_engine.dart';
import '../models/risk_model.dart';
import '../widgets/psi_gauge.dart';
import '../widgets/signal_card.dart';
import '../widgets/alert_banner.dart';
import '../widgets/history_chart.dart';

class MonitorScreen extends ConsumerStatefulWidget {
  const MonitorScreen({super.key});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(int secs) {
    final m = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(riskEngineProvider);
    final engine = ref.read(riskEngineProvider.notifier);
    final color = Color(state.riskLevel.colorValue);

    if (state.monitoringState == MonitoringState.ended) {
      return _EndedScreen(
        onReset: engine.reset,
        log: state.eventLog,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      body: Column(
        children: [
          // Status bar + header
          _buildHeader(state, color, engine),

          // Alert banner (flowchart branch actions)
          AlertBanner(
            level: state.riskLevel,
            monitoringState: state.monitoringState,
            onSOS: () => _showSOSDialog(context, engine),
            onCheckIn: () {
              engine.setScenario(0); // calm down
            },
          ),

          // Tabs
          _buildTabBar(color),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MonitorTab(state: state, color: color),
                _SignalsTab(state: state),
                _LogTab(log: state.eventLog),
              ],
            ),
          ),

          // Bottom actions
          _buildBottomBar(state, engine, color),
        ],
      ),
    );
  }

  Widget _buildHeader(RiskEngineState state, Color color, RiskEngineNotifier engine) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: const Color(0xFF080A0F),
        border: Border(
          bottom: BorderSide(color: color.withOpacity(0.15)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withOpacity(0.25)),
                ),
                child: const Center(
                  child: Text('🛡', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ShieldSense',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'LIVE · ${_formatDuration(state.sessionSeconds)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontFamily: 'monospace',
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Escalating indicator
              if (state.isEscalating)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F1C).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFFFF9F1C).withOpacity(0.4)),
                  ),
                  child: const Text(
                    '▲ RISING',
                    style: TextStyle(
                      color: Color(0xFFFF9F1C),
                      fontSize: 10,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showStopDialog(context, engine),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Icon(Icons.stop_circle_outlined,
                      color: Colors.white.withOpacity(0.5), size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(Color color) {
    const tabs = ['Monitor', 'Signals', 'Log'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white38,
        labelStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: tabs.map((t) => Tab(text: t)).toList(),
        padding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }

  Widget _buildBottomBar(
      RiskEngineState state, RiskEngineNotifier engine, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF080A0F),
        border: Border(
            top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      child: Column(
        children: [
          // Scenario selector label
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  'SIMULATE SCENARIO',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: List.generate(kScenarios.length, (i) {
              final active = state.scenarioIndex == i;
              final sc = kScenarios[i];
              final scLevel = sc.baseSignals['conversation']! < 0.3
                  ? RiskLevel.safe
                  : sc.baseSignals['conversation']! < 0.55
                      ? RiskLevel.low
                      : sc.baseSignals['conversation']! < 0.75
                          ? RiskLevel.moderate
                          : RiskLevel.high;
              final scColor = Color(scLevel.colorValue);
              return Expanded(
                child: GestureDetector(
                  onTap: () => engine.setScenario(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? scColor.withOpacity(0.15)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: active
                            ? scColor.withOpacity(0.5)
                            : Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      sc.name.split(' ').first,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: active ? scColor : Colors.white38,
                        fontSize: 11,
                        fontWeight:
                            active ? FontWeight.w700 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showSOSDialog(BuildContext ctx, RiskEngineNotifier engine) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1117),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🚨 Confirm SOS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will alert your emergency contacts and share your live location.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3366),
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              engine.setScenario(3);
            },
            child: const Text('SEND SOS'),
          ),
        ],
      ),
    );
  }

  void _showStopDialog(BuildContext ctx, RiskEngineNotifier engine) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0F1117),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Monitoring?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will end the current monitoring session.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white12,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              engine.stopMonitoring();
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

// ─── Monitor Tab ──────────────────────────────────────────────────────────────
class _MonitorTab extends StatelessWidget {
  final RiskEngineState state;
  final Color color;
  const _MonitorTab({required this.state, required this.color});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Gauge
          Center(
            child: PSIGauge(
              psi: state.psi,
              level: state.riskLevel,
            ),
          ),
          const SizedBox(height: 16),

          // Risk description
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(
                  _levelIcon(state.riskLevel),
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    state.riskLevel.description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // History chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PSI HISTORY',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontFamily: 'monospace',
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '● LIVE',
                        style: TextStyle(
                          color: color,
                          fontFamily: 'monospace',
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PSIHistoryChart(history: state.history),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _StatBox(label: 'SCENARIO', value: kScenarios[state.scenarioIndex].name.split(' ').first),
              const SizedBox(width: 10),
              _StatBox(label: 'TREND', value: state.isEscalating ? '▲ Rising' : '── Stable'),
              const SizedBox(width: 10),
              _StatBox(label: 'READINGS', value: '${state.history.length}'),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _levelIcon(RiskLevel l) {
    switch (l) {
      case RiskLevel.safe: return '✅';
      case RiskLevel.low: return '🟢';
      case RiskLevel.moderate: return '⚠️';
      case RiskLevel.high: return '🟠';
      case RiskLevel.critical: return '🚨';
    }
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 1,
                )),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Signals Tab ──────────────────────────────────────────────────────────────
class _SignalsTab extends StatelessWidget {
  final RiskEngineState state;
  const _SignalsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SIGNAL BREAKDOWN',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontFamily: 'monospace',
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          ...state.signals.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SignalCard(signal: s),
            ),
          ),

          const SizedBox(height: 8),

          // PSI formula
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PSI FORMULA',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontFamily: 'monospace',
                    fontSize: 10,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'PSI = (Conv × 0.4) + (Emotion × 0.4) + (Env × 0.2)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Smoothed with 60/40 decay filter per cycle',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontFamily: 'monospace',
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                // Escalation indicator
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Escalation = PSI trend > 8pts in last 3 readings',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Log Tab ──────────────────────────────────────────────────────────────────
class _LogTab extends StatelessWidget {
  final List<String> log;
  const _LogTab({required this.log});

  @override
  Widget build(BuildContext context) {
    final reversed = log.reversed.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reversed.length,
      itemBuilder: (_, i) {
        final entry = reversed[i];
        final isAlert = entry.contains('⚠️') ||
            entry.contains('🟠') ||
            entry.contains('🚨');
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isAlert
                ? Colors.red.withOpacity(0.07)
                : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isAlert
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
            ),
          ),
          child: Text(
            entry,
            style: TextStyle(
              color: isAlert ? Colors.red[300] : Colors.white.withOpacity(0.5),
              fontFamily: 'monospace',
              fontSize: 11,
            ),
          ),
        );
      },
    );
  }
}

// ─── Ended screen ─────────────────────────────────────────────────────────────
class _EndedScreen extends StatelessWidget {
  final VoidCallback onReset;
  final List<String> log;
  const _EndedScreen({required this.onReset, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 28))),
              ),
              const SizedBox(height: 20),
              const Text(
                'Session\nEnded',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${log.length} events recorded this session.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5A0),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'START NEW SESSION',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
