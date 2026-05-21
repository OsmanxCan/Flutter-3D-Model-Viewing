import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/aircraft_state.dart';
import '../theme/app_theme.dart';

class ControlToolbar extends StatelessWidget {
  const ControlToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AircraftState>(
      builder: (_, s, __) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border(bottom: BorderSide(color: AppTheme.borderGlow)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              const Text('VIEWPORT',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted,
                      letterSpacing: 2.0, fontFamily: 'monospace')),
              _vDiv(),
              _Toggle(icon: Icons.grid_3x3, label: 'WIREFRAME',
                  active: s.isWireframe, color: AppTheme.accentCyan,
                  onTap: s.toggleWireframe),
              const SizedBox(width: 6),
              _Toggle(icon: Icons.grid_on, label: 'GRID',
                  active: s.showGrid, color: AppTheme.accentBlue,
                  onTap: s.toggleGrid),
              const SizedBox(width: 6),
              _Toggle(icon: Icons.timeline, label: 'AXES',
                  active: s.showAxes, color: AppTheme.accentOrange,
                  onTap: s.toggleAxes),
              _vDiv(),
              _Toggle(icon: Icons.rotate_right, label: 'AUTO ROT',
                  active: s.isAutoRotating, color: AppTheme.accentGreen,
                  onTap: s.toggleAutoRotate),
              _vDiv(),
              const Text('IŞIK:',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted,
                      letterSpacing: 1.5, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              for (final m in ['STUDIO', 'OUTDOOR', 'DRAMATIC'])
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: _Chip(
                    label: m,
                    active: s.lightingMode == m.toLowerCase(),
                    onTap: () => s.setLightingMode(m.toLowerCase()),
                  ),
                ),
              _vDiv(),
              const Text('GÖRÜNÜM:',
                  style: TextStyle(fontSize: 10, color: AppTheme.textMuted,
                      letterSpacing: 1.5, fontFamily: 'monospace')),
              const SizedBox(width: 8),
              for (final p in [
                ('ÖN',  0.0,  0.0),
                ('YAN', 0.0,  1.57),
                ('ÜST', -1.57, 0.0),
                ('İZO', -0.4,  0.8),
              ])
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: _Chip(
                    label: p.$1,
                    active: false,
                    onTap: () => context.read<AircraftState>()
                        .setViewPreset(p.$2, p.$3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vDiv() => Container(
      width: 1, height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 14),
      color: AppTheme.borderGlow);
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;
  const _Toggle({required this.icon, required this.label,
      required this.active, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Tooltip(
        message: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: active ? color : AppTheme.borderGlow),
              borderRadius: BorderRadius.circular(3),
              color: active ? color.withOpacity(0.12) : Colors.transparent,
            ),
            child: Row(children: [
              Icon(icon, size: 12,
                  color: active ? color : AppTheme.textMuted),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(fontSize: 9,
                      color: active ? color : AppTheme.textMuted,
                      letterSpacing: 1.2, fontWeight: FontWeight.w600,
                      fontFamily: 'monospace')),
            ]),
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(
                color: active ? AppTheme.accentBlue : AppTheme.borderGlow),
            borderRadius: BorderRadius.circular(2),
            color: active ? AppTheme.accentBlue.withOpacity(0.15) : Colors.transparent,
          ),
          child: Text(label,
              style: TextStyle(
                  fontSize: 9,
                  color: active ? AppTheme.accentBlue : AppTheme.textMuted,
                  letterSpacing: 1.0, fontFamily: 'monospace')),
        ),
      );
}
