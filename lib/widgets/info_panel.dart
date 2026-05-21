import 'package:flutter/material.dart';
import '../models/aircraft_state.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class InfoPanel extends StatefulWidget {
  const InfoPanel({super.key});
  @override
  State<InfoPanel> createState() => _InfoPanelState();
}

class _InfoPanelState extends State<InfoPanel> {
  final Set<String> _open = {'GENEL BİLGİLER', 'PERFORMANS'};

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.bgPanel,
      child: Column(
        children: [
          _Header(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _AircraftBadge(),
                ...AircraftState.f16Specs.map((cat) {
                  final name = cat['category'] as String;
                  final specs = cat['specs'] as List<Map<String, dynamic>>;
                  return _Category(
                    name: name,
                    specs: specs,
                    open: _open.contains(name),
                    onToggle: () => setState(() =>
                        _open.contains(name) ? _open.remove(name) : _open.add(name)),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          color: AppTheme.bgSurface,
          border: Border(bottom: BorderSide(color: AppTheme.borderGlow)),
        ),
        child: Row(
          children: [
            Container(width: 3, height: 16, color: AppTheme.accentBlue),
            const SizedBox(width: 10),
            const Text('TEKNİK ÖZELLİKLER',
                style: TextStyle(fontSize: 11, color: AppTheme.textPrimary,
                    letterSpacing: 2.5, fontWeight: FontWeight.w600,
                    fontFamily: 'monospace')),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.accentGreen.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(2),
                color: AppTheme.accentGreen.withOpacity(0.08),
              ),
              child: const Text('F-16C BLK 50',
                  style: TextStyle(fontSize: 9, color: AppTheme.accentGreen,
                      letterSpacing: 1.5, fontFamily: 'monospace')),
            ),
          ],
        ),
      );
}

class _AircraftBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0D1A2E), Color(0xFF0A1220)],
        ),
        border: Border.all(color: AppTheme.borderGlow),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(painter: _SilhouettePainter()),
          ),
          const SizedBox(height: 14),
          const Text('F-16C FIGHTING FALCON',
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary,
                  letterSpacing: 2.5, fontWeight: FontWeight.w700,
                  fontFamily: 'monospace')),
          const SizedBox(height: 3),
          const Text('GENERAL DYNAMICS / LOCKHEED MARTIN',
              style: TextStyle(fontSize: 9, color: AppTheme.textMuted,
                  letterSpacing: 1.5, fontFamily: 'monospace')),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _KStat('MACH', '2.0'),
              _div(),
              _KStat('TAVAN', '15km'),
              _div(),
              _KStat('MENZIL', '4.2k'),
              _div(),
              _KStat('İTKİ', '129kN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _div() => Container(width: 1, height: 28, color: AppTheme.borderGlow);
}

class _KStat extends StatelessWidget {
  final String label, value;
  const _KStat(this.label, this.value);
  @override
  Widget build(BuildContext context) => Column(children: [
        Text(value,
            style: const TextStyle(fontSize: 14, color: AppTheme.accentBlue,
                fontWeight: FontWeight.w700, fontFamily: 'monospace')),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 8, color: AppTheme.textMuted,
                letterSpacing: 1.5, fontFamily: 'monospace')),
      ]);
}

class _Category extends StatelessWidget {
  final String name;
  final List<Map<String, dynamic>> specs;
  final bool open;
  final VoidCallback onToggle;
  const _Category(
      {required this.name, required this.specs, required this.open,
       required this.onToggle});

  @override
  Widget build(BuildContext context) => Column(children: [
        InkWell(
          onTap: onToggle,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: AppTheme.bgSurface,
              border: Border(
                  top: BorderSide(color: AppTheme.borderGlow),
                  bottom: BorderSide(color: AppTheme.borderGlow)),
            ),
            child: Row(children: [
              Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentBlue.withOpacity(open ? 1.0 : 0.3))),
              const SizedBox(width: 10),
              Text(name,
                  style: TextStyle(
                      fontSize: 10,
                      color: open ? AppTheme.accentBlue : AppTheme.textMuted,
                      letterSpacing: 2.0, fontWeight: FontWeight.w600,
                      fontFamily: 'monospace')),
              const Spacer(),
              Icon(open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppTheme.textMuted, size: 16),
            ]),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: open
              ? Column(children: specs.map((sp) => _SpecRow(sp)).toList())
              : const SizedBox.shrink(),
        ),
      ]);
}

class _SpecRow extends StatefulWidget {
  final Map<String, dynamic> data;
  const _SpecRow(this.data);
  @override
  State<_SpecRow> createState() => _SpecRowState();
}

class _SpecRowState extends State<_SpecRow> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hov ? AppTheme.accentBlue.withOpacity(0.05) : Colors.transparent,
            border: const Border(bottom: BorderSide(color: AppTheme.gridLine)),
          ),
          child: Row(children: [
            const SizedBox(width: 16),
            Expanded(
              flex: 5,
              child: Text(widget.data['label'] as String,
                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(widget.data['value'] as String,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                  if ((widget.data['unit'] as String).isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(widget.data['unit'] as String,
                        style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
                  ],
                ],
              ),
            ),
          ]),
        ),
      );
}

class _SilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final sc = size.height / 60.0;

    void draw(Path p) { canvas.drawPath(p, fill); canvas.drawPath(p, stroke); }

    final body = Path();
    body.moveTo(cx + 28*sc, cy);
    body.lineTo(cx + 18*sc, cy - 4*sc);
    body.lineTo(cx - 25*sc, cy - 3*sc);
    body.lineTo(cx - 28*sc, cy);
    body.lineTo(cx - 25*sc, cy + 3*sc);
    body.lineTo(cx + 18*sc, cy + 4*sc);
    body.close();
    draw(body);

    for (final sign in [-1.0, 1.0]) {
      final w = Path();
      w.moveTo(cx + 2*sc, cy - sign*3*sc);
      w.lineTo(cx - 8*sc, cy - sign*22*sc);
      w.lineTo(cx - 18*sc, cy - sign*22*sc);
      w.lineTo(cx - 14*sc, cy - sign*3*sc);
      w.close();
      draw(w);

      final t = Path();
      t.moveTo(cx - 16*sc, cy - sign*3*sc);
      t.lineTo(cx - 22*sc, cy - sign*12*sc);
      t.lineTo(cx - 26*sc, cy - sign*12*sc);
      t.lineTo(cx - 24*sc, cy - sign*3*sc);
      t.close();
      draw(t);
    }
  }
  @override
  bool shouldRepaint(_) => false;
}
