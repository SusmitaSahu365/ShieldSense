// lib/widgets/signal_card.dart

import 'package:flutter/material.dart';
import '../models/risk_model.dart';

class SignalCard extends StatelessWidget {
  final RiskSignal signal;

  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final level = psiToLevel(signal.value);
    final color = Color(level.colorValue);
    final pct = signal.value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(signal.icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  signal.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: pct),
                duration: const Duration(milliseconds: 500),
                builder: (_, v, __) => Text(
                  '${(v * 100).round()}',
                  style: TextStyle(
                    color: color,
                    fontFamily: 'monospace',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: Colors.white.withOpacity(0.07),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            level.label,
            style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 10,
              fontFamily: 'monospace',
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
