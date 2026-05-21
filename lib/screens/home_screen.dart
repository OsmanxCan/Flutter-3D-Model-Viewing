import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aircraft_state.dart';
import '../widgets/model_viewport.dart';
import '../widgets/info_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/control_toolbar.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _autoRotateController;
  bool _infoPanelExpanded = true;

  @override
  void initState() {
    super.initState();
    _autoRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(() {
        final state = context.read<AircraftState>();
        state.autoRotateTick();
      });
    _autoRotateController.repeat();
  }

  @override
  void dispose() {
    _autoRotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Column(
        children: [
          // Top navigation bar
          const TopBar(),

          // Main content
          Expanded(
            child: Row(
              children: [
                // 3D Viewport (sol ve merkez)
                Expanded(
                  child: Column(
                    children: [
                      // Control toolbar
                      const ControlToolbar(),
                      // 3D Model area
                      const Expanded(child: ModelViewport()),
                    ],
                  ),
                ),

                // Divider
                Container(
                  width: 1,
                  color: AppTheme.borderGlow,
                ),

                // Info Panel (sağ)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: _infoPanelExpanded ? 360 : 0,
                  child: _infoPanelExpanded
                      ? const InfoPanel()
                      : const SizedBox.shrink(),
                ),

                // Panel toggle button
                _PanelToggleButton(
                  isExpanded: _infoPanelExpanded,
                  onToggle: () => setState(() => _infoPanelExpanded = !_infoPanelExpanded),
                ),
              ],
            ),
          ),

          // Status bar
          _StatusBar(),
        ],
      ),
    );
  }
}

class _PanelToggleButton extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;

  const _PanelToggleButton({required this.isExpanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      color: AppTheme.bgPanel,
      child: InkWell(
        onTap: onToggle,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExpanded ? Icons.chevron_right : Icons.chevron_left,
              color: AppTheme.textMuted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AircraftState>(
      builder: (context, state, _) {
        return Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(
            color: AppTheme.bgPanel,
            border: Border(top: BorderSide(color: AppTheme.borderGlow)),
          ),
          child: Row(
            children: [
              _statusItem('ROT X', '${(state.rotationX * 57.3).toStringAsFixed(1)}°'),
              const SizedBox(width: 24),
              _statusItem('ROT Y', '${(state.rotationY * 57.3).toStringAsFixed(1)}°'),
              const SizedBox(width: 24),
              _statusItem('ZOOM', '${(state.zoom * 100).toStringAsFixed(0)}%'),
              const SizedBox(width: 24),
              _statusItem('WIREFRAME', state.isWireframe ? 'ON' : 'OFF',
                  color: state.isWireframe ? AppTheme.accentCyan : AppTheme.textMuted),
              const SizedBox(width: 24),
              _statusItem('AUTO ROTATE', state.isAutoRotating ? 'ON' : 'OFF',
                  color: state.isAutoRotating ? AppTheme.accentGreen : AppTheme.textMuted),
              const Spacer(),
              Text(
                'F-16 FIGHTING FALCON  //  GENERAL DYNAMICS',
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                  letterSpacing: 1.5,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusItem(String label, String value, {Color? color}) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            color: color ?? AppTheme.accentBlue,
            letterSpacing: 1.2,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
