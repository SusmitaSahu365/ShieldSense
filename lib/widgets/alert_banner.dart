// lib/widgets/alert_banner.dart

import 'package:flutter/material.dart';
import '../models/risk_model.dart';

class AlertBanner extends StatefulWidget {
  final RiskLevel level;
  final MonitoringState monitoringState;
  final VoidCallback? onSOS;
  final VoidCallback? onCheckIn;

  const AlertBanner({
    super.key,
    required this.level,
    required this.monitoringState,
    this.onSOS,
    this.onCheckIn,
  });

  @override
  State<AlertBanner> createState() => _AlertBannerState();
}

class _AlertBannerState extends State<AlertBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _blink;

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.monitoringState == MonitoringState.monitoring ||
        widget.monitoringState == MonitoringState.idle ||
        widget.monitoringState == MonitoringState.setup ||
        widget.monitoringState == MonitoringState.ended) {
      return const SizedBox.shrink();
    }

    final color = Color(widget.level.colorValue);
    final isEmergency = widget.monitoringState == MonitoringState.emergency;
    final isEscalating = widget.monitoringState == MonitoringState.escalating;

    return AnimatedBuilder(
      animation: _blink,
      builder: (_, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(isEmergency ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(isEmergency ? _blink.value * 0.6 + 0.4 : 0.35),
            width: isEmergency ? 2 : 1,
          ),
          boxShadow: isEmergency
              ? [
                  BoxShadow(
                    color: color.withOpacity(_blink.value * 0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isEmergency
                      ? '🚨'
                      : isEscalating
                          ? '🟠'
                          : '⚠️',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isEmergency
                        ? 'EMERGENCY PROTOCOL ACTIVE'
                        : isEscalating
                            ? 'HIGH RISK — Safety Prompt'
                            : 'ELEVATED RISK — Subtle Alert',
                    style: TextStyle(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._bulletPoints(isEmergency, isEscalating, color),
            const SizedBox(height: 10),
            Row(
              children: [
                if (!isEmergency) ...[
                  _ActionButton(
                    label: isEscalating ? 'I\'m Safe' : 'Noted',
                    color: color,
                    onTap: widget.onCheckIn,
                  ),
                  const SizedBox(width: 8),
                ],
                _ActionButton(
                  label: '🆘 SOS',
                  color: const Color(0xFFFF3366),
                  onTap: widget.onSOS,
                  filled: isEmergency,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _bulletPoints(bool emergency, bool escalating, Color color) {
    List<String> points;
    if (emergency) {
      points = [
        'Auto-alert sent to emergency contacts',
        'Live location sharing activated',
        'Auto-call trigger initiated',
      ];
    } else if (escalating) {
      points = [
        'Check-in confirmation: Are you safe?',
        'Suggest contacting trusted contact',
      ];
    } else {
      points = [
        'Vibration alert sent',
        'Suggestion to relocate shown',
        'Precaution checklist displayed',
      ];
    }
    return points
        .map((p) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ',
                      style: TextStyle(
                          color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(p,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ),
                ],
              ),
            ))
        .toList();
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;

  const _ActionButton({
    required this.label,
    required this.color,
    this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: filled ? color : color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: filled ? Colors.black : color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
