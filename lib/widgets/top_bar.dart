import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../models/aircraft_state.dart';
import '../theme/app_theme.dart';
import 'dart:io';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Future<void> _pickFile(BuildContext ctx) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['stl', 'obj'],
    );
    if (result != null && result.files.single.path != null && ctx.mounted) {
      ctx.read<AircraftState>().requestLoadModel(result.files.single.path!);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        backgroundColor: AppTheme.bgCard,
        content: Text('Yükleniyor: ${result.files.single.name}',
            style: const TextStyle(color: AppTheme.accentGreen)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppTheme.bgPanel,
        border: Border(bottom: BorderSide(color: AppTheme.borderGlow)),
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.accentBlue, width: 1.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.airplanemode_active,
                color: AppTheme.accentBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('F-16 FALCON',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary, letterSpacing: 2.5,
                      fontFamily: 'monospace')),
              Text('FIGHTING FALCON  //  3D VIEWER',
                  style: TextStyle(
                      fontSize: 9, color: AppTheme.accentBlue,
                      letterSpacing: 2.0, fontFamily: 'monospace')),
            ],
          ),
          const SizedBox(width: 32),
          _Badge(label: 'DECLASSIFIED', color: AppTheme.accentOrange),
          const Spacer(),
          _TbBtn(icon: Icons.folder_open_outlined, label: 'MODEL YÜKLE',
              onTap: () => _pickFile(context)),
          const SizedBox(width: 8),
          _TbBtn(icon: Icons.center_focus_strong, label: 'RESET',
              onTap: () => context.read<AircraftState>().resetView()),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(2),
          color: color.withOpacity(0.08),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 9, color: color, letterSpacing: 2.5,
                fontWeight: FontWeight.bold, fontFamily: 'monospace')),
      );
}

class _TbBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _TbBtn({required this.icon, required this.label, required this.onTap});
  @override
  State<_TbBtn> createState() => _TbBtnState();
}

class _TbBtnState extends State<_TbBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hov = true),
        onExit: (_) => setState(() => _hov = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  color: _hov ? AppTheme.accentBlue : AppTheme.borderGlow),
              borderRadius: BorderRadius.circular(3),
              color: _hov ? AppTheme.accentBlue.withOpacity(0.1) : Colors.transparent,
            ),
            child: Row(children: [
              Icon(widget.icon, size: 14,
                  color: _hov ? AppTheme.accentBlue : AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(widget.label,
                  style: TextStyle(
                      fontSize: 10,
                      color: _hov ? AppTheme.accentBlue : AppTheme.textSecondary,
                      letterSpacing: 1.5, fontWeight: FontWeight.w600,
                      fontFamily: 'monospace')),
            ]),
          ),
        ),
      );
}
