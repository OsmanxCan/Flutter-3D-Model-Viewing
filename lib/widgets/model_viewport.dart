import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:three_js_helpers/three_js_helpers.dart';
import 'package:three_js_simple_loaders/three_js_simple_loaders.dart';
import '../models/aircraft_state.dart';
import '../theme/app_theme.dart';

class ModelViewport extends StatefulWidget {
  const ModelViewport({super.key});
  @override
  State<ModelViewport> createState() => _ModelViewportState();
}

class _ModelViewportState extends State<ModelViewport> {
  three.ThreeJS?          _threeJs;
  three.Object3D?         _modelGroup;
  GridHelper?             _gridHelper;
  three.AmbientLight?     _ambient;
  three.DirectionalLight? _dir1;
  three.DirectionalLight? _dir2;
  three.PointLight?       _point;

  bool   _ready        = false;
  String _lastLighting = '';
  bool   _isLoading    = false;

  // Fare butonu takibi
  bool _midDown   = false;  // orbit
  bool _rightDown = false;  // pan

  @override
  void initState() {
    super.initState();
    _threeJs = three.ThreeJS(
      onSetupComplete: () => setState(() => _ready = true),
      setup: _setup,
    );
  }

  @override
  void dispose() {
    _threeJs?.dispose();
    super.dispose();
  }

  Future<void> _setup() async {
    final t = _threeJs!;
    t.camera = three.PerspectiveCamera(45, t.width / t.height, 0.1, 1000);
    t.scene  = three.Scene();
    t.scene.background = three.Color.fromHex32(0xFF808080);

    _gridHelper = GridHelper(20, 20, 0x1A3A5C, 0x0F2035);
    _gridHelper!.position.y = -2;
    t.scene.add(_gridHelper!);

    _applyLighting('studio');
    _lastLighting = 'studio';

    t.addAnimationEvent((_) => _onFrame());
    await _loadSTL('assets/models/F16.stl');
  }

  // ── Kamera pozisyonunu state'ten hesapla ──────────────────────
  void _updateCamera(AircraftState s) {
    final r  = s.radius;
    final th = s.theta;
    final ph = s.phi;

    // Küresel koordinat → Kartezyen
    final cx = r * math.sin(ph) * math.sin(th);
    final cy = r * math.cos(ph);
    final cz = r * math.sin(ph) * math.cos(th);

    final target = three.Vector3(s.panX, s.panY, 0);
    _threeJs?.camera.position.setValues(
      target.x + cx,
      target.y + cy,
      target.z + cz,
    );
    _threeJs?.camera.lookAt(target);
  }

  void _onFrame() {
    final s = context.read<AircraftState>();

    _updateCamera(s);
    _gridHelper?.visible = s.showGrid;

    // Wireframe — sadece değiştiğinde
    _modelGroup?.traverse((obj) {
      if (obj is three.Mesh) {
        final mat = obj.material;
        if (mat is three.MeshStandardMaterial &&
            mat.wireframe != s.isWireframe) {
          mat.wireframe   = s.isWireframe;
          mat.needsUpdate = true;
        }
      }
    });

    if (s.lightingMode != _lastLighting) {
      _applyLighting(s.lightingMode);
      _lastLighting = s.lightingMode;
    }

    if (s.pendingModelPath != null && !_isLoading) {
      final path = s.pendingModelPath!;
      s.clearPendingModel();
      _loadSTL(path);
    }
  }

  void _applyLighting(String mode) {
    final scene = _threeJs?.scene;
    if (scene == null) return;
    for (final l in [_ambient, _dir1, _dir2, _point]) {
      if (l != null) scene.remove(l);
    }

    switch (mode) {
      case 'studio':
        _ambient = three.AmbientLight(0xFFFFFF, 0.4);
        _dir1 = three.DirectionalLight(0xFFFFFF, 0.8)
          ..position.setValues(5, 10, 5);
        _dir2 = three.DirectionalLight(0x4488FF, 0.3)
          ..position.setValues(-5, -5, -5);
        break;
      case 'outdoor':
        _ambient = three.AmbientLight(0x87CEEB, 0.5);
        _dir1 = three.DirectionalLight(0xFFFFAA, 1.0)
          ..position.setValues(10, 20, 5);
        _dir2 = three.DirectionalLight(0x4466FF, 0.2)
          ..position.setValues(0, -5, 0);
        break;
      case 'dramatic':
        _ambient = three.AmbientLight(0x111111, 0.2);
        _dir1 = three.DirectionalLight(0xFF4400, 0.9)
          ..position.setValues(-10, 5, -5);
        _dir2 = three.DirectionalLight(0x0044FF, 0.9)
          ..position.setValues(10, 5, 5);
        _point = three.PointLight(0x00FFFF, 0.5, 20)
          ..position.setValues(0, 5, 0);
        break;
    }

    for (final l in [_ambient, _dir1, _dir2, _point]) {
      if (l != null) scene.add(l);
    }
  }

  Future<void> _loadSTL(String path) async {
    if (_isLoading) return;
    _isLoading = true;
    final scene = _threeJs?.scene;
    if (scene == null) { _isLoading = false; return; }

    try {
      final loader = STLLoader();
      final result = path.startsWith('assets/')
          ? await loader.fromAsset(path)
          : await loader.fromPath(path);
      if (result == null) return;

      three.BufferGeometry geo;
      try {
        geo = result as three.BufferGeometry;
      } catch (_) {
        geo = (result as three.Mesh).geometry!;
      }

      geo.computeBoundingBox();
      final box = geo.boundingBox!;
      final cx = (box.max.x + box.min.x) / 2;
      final cy = (box.max.y + box.min.y) / 2;
      final cz = (box.max.z + box.min.z) / 2;
      geo.applyMatrix4(three.Matrix4()..makeTranslation(-cx, -cy, -cz));

      final maxD = [
        box.max.x - box.min.x,
        box.max.y - box.min.y,
        box.max.z - box.min.z,
      ].reduce(math.max);

      final mesh = three.Mesh(
        geo,
        three.MeshStandardMaterial.fromMap({
          'color': three.Color.fromHex32(0xFFCCCCCC),
          'metalness': 0.6,
          'roughness': 0.35,
        }),
      )..scale.setValues(5 / maxD, 5 / maxD, 5 / maxD);

      if (_modelGroup != null) scene.remove(_modelGroup!);
      _modelGroup = three.Group()..add(mesh);
      scene.add(_modelGroup!);
      debugPrint('STL yüklendi: $path');
    } catch (e) {
      debugPrint('STL hata: $e');
    } finally {
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AircraftState>(
      builder: (_, s, __) {
        return Stack(
          children: [
            // ── 3D Viewport ──────────────────────────────────────
            if (_threeJs != null)
              Listener(
                // Scroll → zoom
                onPointerSignal: (e) {
                  if (e is PointerScrollEvent) {
                    s.updateZoom(e.scrollDelta.dy);
                  }
                },
                // Orta / sağ tuş takibi
                onPointerDown: (e) {
                  if (e.buttons == 4) _midDown   = true;  // orta
                  if (e.buttons == 2) _rightDown = true;  // sağ
                },
                onPointerUp: (e) {
                  _midDown   = false;
                  _rightDown = false;
                },
                onPointerMove: (e) {
                  final dx = e.delta.dx;
                  final dy = e.delta.dy;
                  if (_midDown)   s.orbit(dx, dy);  // orbit
                  if (_rightDown) s.pan(dx, dy);    // pan
                },
                child: GestureDetector(
                  // Sol tık sürükleme → orbit (dokunmatik için)
                  onPanUpdate: (d) => s.orbit(d.delta.dx, d.delta.dy),
                  child: _threeJs!.build(),
                ),
              ),

            // ── Yükleniyor ───────────────────────────────────────
            if (!_ready)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                        color: AppTheme.accentBlue, strokeWidth: 1.5),
                    SizedBox(height: 20),
                    Text('3D VIEWPORT BAŞLATILIYOR...',
                        style: TextStyle(
                            color: AppTheme.accentBlue,
                            letterSpacing: 2.5,
                            fontSize: 11,
                            fontFamily: 'monospace')),
                  ],
                ),
              ),

            const _Corners(),

            Positioned(left: 16, bottom: 16, child: _InfoOverlay()),
            Positioned(right: 16, bottom: 16, child: _ZoomBox(zoom: s.zoom)),

            // ── Blender tarzı Axes Gizmo ─────────────────────────
            Positioned(
              right: 16,
              top: 16,
              child: _BlenderAxesGizmo(
                theta: s.theta,
                phi: s.phi,
                onAxisTap: s.setViewFromAxis,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Blender tarzı Axes Gizmo
// ══════════════════════════════════════════════════════════════════════════════

class _BlenderAxesGizmo extends StatelessWidget {
  final double theta;
  final double phi;
  final void Function(String axis) onAxisTap;

  const _BlenderAxesGizmo({
    required this.theta,
    required this.phi,
    required this.onAxisTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Çizimler
          CustomPaint(
            size: const Size(100, 100),
            painter: _GizmoPainter(theta: theta, phi: phi),
          ),
          // Tıklanabilir etiketler
          ..._buildLabels(),
        ],
      ),
    );
  }

  List<Widget> _buildLabels() {
    const size = 100.0;
    const center = Offset(size / 2, size / 2);
    const armLen = 34.0;
    const dotR   = 13.0;

    final axes = [
      ('X',  _axisDir( 1,  0,  0)),
      ('-X', _axisDir(-1,  0,  0)),
      ('Y',  _axisDir( 0,  1,  0)),
      ('-Y', _axisDir( 0, -1,  0)),
      ('Z',  _axisDir( 0,  0,  1)),
      ('-Z', _axisDir( 0,  0, -1)),
    ];

    return axes.map((entry) {
      final label = entry.$1;
      final dir3  = entry.$2;
      final proj  = _project(dir3, theta, phi);
      final pos   = center + proj * armLen;
      final color = _axisColor(label);

      return Positioned(
        left: pos.dx - dotR,
        top:  pos.dy - dotR,
        child: GestureDetector(
          onTap: () => onAxisTap(label),
          child: Container(
            width:  dotR * 2,
            height: dotR * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(label.startsWith('-') ? 0.35 : 0.85),
              border: Border.all(color: color, width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize:   label.length > 1 ? 7 : 9,
                fontWeight: FontWeight.bold,
                color:      Colors.white,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  // 3D birim vektörü → 2D projeksiyon (izometrik benzeri)
  static Offset _project(
      List<double> v, double theta, double phi) {
    final x = v[0];
    final y = v[1];
    final z = v[2];

    // Kamera matrisine göre döndür
    final cosT = math.cos(-theta);
    final sinT = math.sin(-theta);
    final cosP = math.cos(phi - math.pi / 2);
    final sinP = math.sin(phi - math.pi / 2);

    // Y ekseninde theta dönüşü
    final rx = x * cosT + z * sinT;
    final ry = y;
    final rz = -x * sinT + z * cosT;

    // X ekseninde phi dönüşü
    final fx =  rx;
    final fy =  ry * cosP - rz * sinP;

    return Offset(fx, -fy); // Y ekranı ters
  }

  static List<double> _axisDir(double x, double y, double z) => [x, y, z];

  static Color _axisColor(String label) {
    final base = label.replaceAll('-', '');
    switch (base) {
      case 'X': return const Color(0xFFE84040); // kırmızı
      case 'Y': return const Color(0xFF4CAF50); // yeşil
      case 'Z': return const Color(0xFF2196F3); // mavi
      default:  return Colors.white;
    }
  }
}

class _GizmoPainter extends CustomPainter {
  final double theta;
  final double phi;
  const _GizmoPainter({required this.theta, required this.phi});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const armLen = 34.0;

    // Arkaplan çemberi
    canvas.drawCircle(
      center, size.width / 2 - 2,
      Paint()
        ..color = const Color(0xFF1A2332).withOpacity(0.7)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      center, size.width / 2 - 2,
      Paint()
        ..color = AppTheme.accentBlue.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final axes = [
      ('X',  [1.0, 0.0, 0.0]),
      ('Y',  [0.0, 1.0, 0.0]),
      ('Z',  [0.0, 0.0, 1.0]),
      ('-X', [-1.0, 0.0, 0.0]),
      ('-Y', [0.0, -1.0, 0.0]),
      ('-Z', [0.0, 0.0, -1.0]),
    ];

    // Z derinliğine göre sırala — arkadakiler önce çizilir
    final sorted = axes.map((a) {
      final proj = _BlenderAxesGizmo._project(a.$2, theta, phi);
      return (a.$1, a.$2, proj);
    }).toList()
      ..sort((a, b) => a.$3.dy.compareTo(b.$3.dy));

    for (final entry in sorted) {
      final label = entry.$1;
      final proj  = entry.$3;
      final isNeg = label.startsWith('-');
      final color = _BlenderAxesGizmo._axisColor(label);
      final end   = center + proj * armLen;

      if (!isNeg) {
        canvas.drawLine(
          center, end,
          Paint()
            ..color      = color
            ..strokeWidth = 2.0
            ..style      = PaintingStyle.stroke,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GizmoPainter o) =>
      o.theta != theta || o.phi != phi;
}

// ══════════════════════════════════════════════════════════════════════════════
// Yardımcı widget'lar
// ══════════════════════════════════════════════════════════════════════════════

class _InfoOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgPanel.withOpacity(0.85),
          border: Border.all(color: AppTheme.borderGlow),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('F-16C FIGHTING FALCON',
                style: TextStyle(
                    fontSize: 10, color: AppTheme.accentBlue,
                    letterSpacing: 2.0, fontWeight: FontWeight.bold,
                    fontFamily: 'monospace')),
            SizedBox(height: 2),
            Text('ORTA TUŞ: ORBIT  |  SAĞ TUŞ: PAN  |  SCROLL: ZOOM',
                style: TextStyle(
                    fontSize: 8, color: AppTheme.textMuted,
                    letterSpacing: 1.0, fontFamily: 'monospace')),
          ],
        ),
      );
}

class _ZoomBox extends StatelessWidget {
  final double zoom;
  const _ZoomBox({required this.zoom});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.bgPanel.withOpacity(0.85),
          border: Border.all(color: AppTheme.borderGlow),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          children: [
            const Text('ZOOM',
                style: TextStyle(
                    fontSize: 8, color: AppTheme.textMuted,
                    letterSpacing: 1.5, fontFamily: 'monospace')),
            const SizedBox(height: 3),
            Text('${(zoom * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.accentBlue,
                    letterSpacing: 1.0, fontWeight: FontWeight.bold,
                    fontFamily: 'monospace')),
          ],
        ),
      );
}

class _Corners extends StatelessWidget {
  const _Corners();
  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned(top: 16, left: 16,    child: _C(t: true,  l: true)),
        Positioned(top: 16, right: 52,   child: _C(t: true,  l: false)),
        Positioned(bottom: 16, left: 16, child: _C(t: false, l: true)),
        Positioned(bottom: 16, right: 52,child: _C(t: false, l: false)),
      ]);
}

class _C extends StatelessWidget {
  final bool t, l;
  const _C({required this.t, required this.l});
  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 24, height: 24,
          child: CustomPaint(painter: _CPainter(t, l)));
}

class _CPainter extends CustomPainter {
  final bool t, l;
  const _CPainter(this.t, this.l);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = AppTheme.accentBlue.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path();
    if (l && t) {
      path.moveTo(0, s.height); path.lineTo(0, 0); path.lineTo(s.width, 0);
    } else if (!l && t) {
      path.moveTo(0, 0); path.lineTo(s.width, 0); path.lineTo(s.width, s.height);
    } else if (l && !t) {
      path.moveTo(0, 0); path.lineTo(0, s.height); path.lineTo(s.width, s.height);
    } else {
      path.moveTo(s.width, 0); path.lineTo(s.width, s.height); path.lineTo(0, s.height);
    }
    canvas.drawPath(path, p);
  }
  @override
  bool shouldRepaint(_) => false;
}