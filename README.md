# 🛡 ShieldSense — Personal Safety Index Flutter App

A **GUI simulation** of a real-time personal safety monitoring system, built in Flutter.
Implements the full flowchart logic: Baseline Setup → Continuous Risk Analysis → PSI Scoring → Escalation Detection → Response Routing.

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry, GoRouter, navigation listener
├── models/
│   └── risk_model.dart          # RiskLevel, MonitoringState, PSISnapshot, RiskSignal
├── engine/
│   └── risk_engine.dart         # Riverpod StateNotifier — full flowchart simulation logic
├── screens/
│   ├── setup_screen.dart        # Baseline setup / splash
│   └── monitor_screen.dart      # Main dashboard (Monitor / Signals / Log tabs)
└── widgets/
    ├── psi_gauge.dart            # Animated arc ring gauge with glow
    ├── signal_card.dart          # Individual signal with animated progress bar
    ├── alert_banner.dart         # Flowchart branches: Subtle / Safety Prompt / Emergency
    └── history_chart.dart        # fl_chart PSI history line graph with threshold lines
```

---

## 🔁 Flowchart → Code Mapping

| Flowchart Node                   | Code Location                               |
|----------------------------------|---------------------------------------------|
| Baseline Setup                   | `engine.startSetup()` → 2s delay            |
| Start Monitoring                 | `engine.startMonitoring()` → 1.5s timer     |
| Conversational Risk Analysis     | `signals['conversation']` weighted 40%      |
| Emotional Stress Detection       | `signals['emotion']` weighted 40%           |
| Environmental Risk Assessment    | `signals['environment']` weighted 20%       |
| Predictive Safety Index          | `psi = conv*0.4 + emo*0.4 + env*0.2`        |
| Is Risk Escalating?              | PSI trend > 8pts over last 3 readings       |
| Continue Silent Monitoring       | `MonitoringState.monitoring` (default loop) |
| Subtle Alert (Moderate Risk)     | `MonitoringState.alerting`                  |
| Safety Prompt (High Risk)        | `MonitoringState.escalating`                |
| Emergency Intervention (Critical)| `MonitoringState.emergency`                 |
| End Monitoring                   | `engine.stopMonitoring()`                   |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0
- Android Studio / Xcode / VS Code with Flutter extension

### Install & Run

```bash
cd shield_sense
flutter pub get
flutter run
```

### Build APK

```bash
flutter build apk --release
```

---

## 🎮 Simulation Controls

The bottom bar has 4 scenario buttons:

| Scenario         | PSI Range  | Behavior                          |
|------------------|------------|-----------------------------------|
| **Normal**       | ~10–25     | Silent monitoring, green gauge    |
| **Tense**        | ~45–60     | Elevated, alert banner appears    |
| **Suspicious**   | ~50–70     | Caution, safety prompt            |
| **Escalating**   | ~75–95     | Critical, emergency protocol      |

Each scenario adds ±6% random noise per cycle to simulate real sensor variation.

---

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.4.9       # State management
go_router: ^13.0.1              # Navigation / deep linking
fl_chart: ^0.66.2               # PSI history chart
lottie: ^3.0.0                  # Alert animations (ready to use)
google_fonts: ^6.1.0            # Typography
flutter_animate: ^4.3.0         # Micro animations
vibration: ^1.8.4               # Haptic feedback on alerts
```

---

## 🔮 Extending to Real AI

To replace simulation with real ML:

1. **Voice Stress** → Connect `WebRTC` audio → send to `FastAPI` endpoint running TFLite model → update `signals['emotion']`
2. **Text Intent** → Pipe conversation text → Hugging Face toxicity endpoint → update `signals['conversation']`
3. **Location** → Use `geolocator` package → compute distance from safe zones → update `signals['environment']`

The engine's `_runAnalysisCycle()` is the single integration point — swap fake values for real API responses there.

---

## 🎨 Design System

- **Background**: `#080A0F` deep navy black
- **Safe**: `#00E5A0` teal green
- **Low**: `#8BC34A`
- **Moderate**: `#FFD166` amber
- **High**: `#FF9F1C` orange
- **Critical**: `#FF3366` red
- **Font**: Monospace (system) for data, system sans for UI
