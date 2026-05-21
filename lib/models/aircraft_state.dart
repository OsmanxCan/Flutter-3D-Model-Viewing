import 'package:flutter/foundation.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class AircraftSpec {
  final String label;
  final String value;
  final String unit;
  final IconData? icon;

  const AircraftSpec({
    required this.label,
    required this.value,
    this.unit = '',
    this.icon,
  });
}

class AircraftState extends ChangeNotifier {
  // 3D rotation state
  double _rotationX = -0.2;
  double _rotationY = 0.5;
  double _rotationZ = 0.0;
  double _zoom = 1.0;
  bool _isAutoRotating = false;
  // bool _isWireframe = false;
  // bool _showGrid = true;
  // bool _showAxes = false;
  // String _lightingMode = 'studio'; // studio, outdoor, dramatic
  String? _loadedModelPath;

  // Getters
  // double get rotationX => _rotationX;
  // double get rotationY => _rotationY;
  double get rotationZ => _rotationZ;
  // double get zoom => _zoom;
  bool get isAutoRotating => _isAutoRotating;
  // bool get isWireframe => _isWireframe;
  // bool get showGrid => _showGrid;
  // bool get showAxes => _showAxes;
  // String get lightingMode => _lightingMode;
  // String? get loadedModelPath => _loadedModelPath;

   // Geriye uyumluluk — viewport rotation için hesaplanan değerler
  double get rotationX => _phi - math.pi / 2;
  double get rotationY => _theta;

  bool   get showGrid    => _showGrid;
  bool   get showAxes    => _showAxes;
  bool   get isWireframe => _isWireframe;
  String get lightingMode => _lightingMode;
  String? get pendingModelPath => _pendingModelPath;

  // Zoom: 0.1x … 5x
  double get zoom => 15.0 / _radius;

  // F-16 Fighting Falcon Özellikleri
  static const List<Map<String, dynamic>> f16Specs = [
    {
      'category': 'GENEL BİLGİLER',
      'specs': [
        {'label': 'Üretici', 'value': 'General Dynamics / Lockheed Martin', 'unit': ''},
        {'label': 'İlk Uçuş', 'value': '1974', 'unit': ''},
        {'label': 'Statü', 'value': 'Aktif Hizmet', 'unit': ''},
        {'label': 'Mürettebat', 'value': '1', 'unit': 'kişi'},
      ]
    },
    {
      'category': 'BOYUTLAR',
      'specs': [
        {'label': 'Uzunluk', 'value': '15.06', 'unit': 'm'},
        {'label': 'Kanat Açıklığı', 'value': '9.96', 'unit': 'm'},
        {'label': 'Yükseklik', 'value': '5.09', 'unit': 'm'},
        {'label': 'Kanat Alanı', 'value': '27.87', 'unit': 'm²'},
      ]
    },
    {
      'category': 'AĞIRLIK',
      'specs': [
        {'label': 'Boş Ağırlık', 'value': '8.570', 'unit': 'kg'},
        {'label': 'Yüklü Ağırlık', 'value': '12.003', 'unit': 'kg'},
        {'label': 'Maks. Kalkış Ağırlığı', 'value': '19.187', 'unit': 'kg'},
      ]
    },
    {
      'category': 'PERFORMANS',
      'specs': [
        {'label': 'Maks. Hız', 'value': 'Mach 2.0', 'unit': '(2.414 km/s)'},
        {'label': 'Menzil', 'value': '4.220', 'unit': 'km'},
        {'label': 'Servis Tavanı', 'value': '15.240', 'unit': 'm'},
        {'label': 'Tırmanma Hızı', 'value': '254', 'unit': 'm/s'},
        {'label': 'G Limiti', 'value': '+9 / -3', 'unit': 'g'},
        {'label': 'İtki/Ağırlık', 'value': '1.095', 'unit': ''},
      ]
    },
    {
      'category': 'İTKİ SİSTEMİ',
      'specs': [
        {'label': 'Motor', 'value': 'F110-GE-129', 'unit': ''},
        {'label': 'Motor Tipi', 'value': 'Turbofan', 'unit': ''},
        {'label': 'Kuru İtki', 'value': '76.3', 'unit': 'kN'},
        {'label': 'Ardışık Yanma', 'value': '129.0', 'unit': 'kN'},
      ]
    },
    {
      'category': 'SİLAHLANDIRMA',
      'specs': [
        {'label': 'Top', 'value': 'M61A1 Vulcan 20mm', 'unit': ''},
        {'label': 'Silah Noktaları', 'value': '9', 'unit': 'adet'},
        {'label': 'Silah Kapasitesi', 'value': '7.700', 'unit': 'kg'},
        {'label': 'Hava-Hava Füze', 'value': 'AIM-9, AIM-120', 'unit': ''},
        {'label': 'Hava-Kara', 'value': 'AGM-65, Paveway', 'unit': ''},
      ]
    },
    {
      'category': 'AVIYONIK',
      'specs': [
        {'label': 'Radar', 'value': 'AN/APG-68', 'unit': ''},
        {'label': 'EW Sistemi', 'value': 'AN/ALQ-187', 'unit': ''},
        {'label': 'HUD', 'value': 'Uyarı Başüstü Göstergesi', 'unit': ''},
        {'label': 'HOTAS', 'value': 'Kol Üstü Kontrol', 'unit': ''},
      ]
    },
  ];

  // void updateRotation(double dx, double dy) {
  //   _rotationY += dx * 0.01;
  //   _rotationX += dy * 0.01;
  //   _rotationX = _rotationX.clamp(-math.pi / 2, math.pi / 2);
  //   notifyListeners();
  // }

  // void updateZoom(double delta) {
  //   _zoom = (_zoom - delta * 0.001).clamp(0.3, 3.0);
  //   notifyListeners();
  // }

  void toggleAutoRotate() {
    _isAutoRotating = !_isAutoRotating;
    notifyListeners();
  }

  // void toggleWireframe() {
  //   _isWireframe = !_isWireframe;
  //   notifyListeners();
  // }

  // void toggleGrid() {
  //   _showGrid = !_showGrid;
  //   notifyListeners();
  // }

  // void toggleAxes() {
  //   _showAxes = !_showAxes;
  //   notifyListeners();
  // }

  void setLightingMode(String mode) {
    _lightingMode = mode;
    notifyListeners();
  }

  void resetView() {
    _rotationX = -0.2;
    _rotationY = 0.5;
    _rotationZ = 0.0;
    _zoom = 1.0;
    notifyListeners();
  }

  void setLoadedModel(String? path) {
    _loadedModelPath = path;
    notifyListeners();
  }

  String? _pendingModelPath;
  // String? get pendingModelPath => _pendingModelPath;

  void loadModelFromPath(String path) {
    _pendingModelPath = path;
    notifyListeners();
  }

  // void clearPendingModel() {
  //   _pendingModelPath = null;
  //   // notifyListeners çağrılmaz — render loop'ta çağrılıyor
  // }

  void autoRotateTick() {
    if (_isAutoRotating) {
      _rotationY += 0.005;
      notifyListeners();
    }
  }

  void setRotationFromAngle(double yAngle) {
    _rotationY = yAngle;
    notifyListeners();
  }

  void setViewPreset(double rx, double ry) {
    _rotationX = rx;
    _rotationY = ry;
    notifyListeners();
  }
  
  void requestLoadModel(String path) {
    _pendingModelPath = path;
    notifyListeners();
  }


   double _theta = 0.3;       // yatay açı (radyan) — serbest, limit yok
  double _phi   = 1.2;       // dikey açı (radyan) — 0.05 … π-0.05
  double _radius = 15.0;     // zoom mesafesi

  // ── Pan (kamera hedef offset) ─────────────────────────────────
  double _panX = 0.0;
  double _panY = 0.0;

  // ── Görünüm ayarları ─────────────────────────────────────────
  bool   _showGrid   = true;
  bool   _showAxes   = false;
  bool   _isWireframe = false;
  String _lightingMode = 'studio';

  // ── Getters ──────────────────────────────────────────────────
  double get theta   => _theta;
  double get phi     => _phi;
  double get radius  => _radius;
  double get panX    => _panX;
  double get panY    => _panY;

 

  // ── Orbit (orta tekerlek sürükleme) ──────────────────────────
  void orbit(double dx, double dy) {
    const sens = 0.005;
    _theta += dx * sens;
    _phi    = (_phi - dy * sens).clamp(0.05, math.pi - 0.05);
    notifyListeners();
  }

  // ── Pan (sağ tık / iki parmak) ────────────────────────────────
  void pan(double dx, double dy) {
    const sens = 0.01;
    // Kamera yönüne göre pan vektörü
    final cosT = math.cos(_theta);
    final sinT = math.sin(_theta);
    // Sağa = (-sinT, 0, cosT), Yukarı = (0, 1, 0) basit yaklaşım
    _panX += (-sinT * dx + cosT * 0) * sens * _radius * 0.1;
    _panY += dy * sens * _radius * 0.1;
    notifyListeners();
  }

  // ── Zoom (scroll) ─────────────────────────────────────────────
  void updateZoom(double delta) {
    _radius = (_radius + delta * 0.01).clamp(2.0, 80.0);
    notifyListeners();
  }

  // ── Eski API — geriye uyumluluk ───────────────────────────────
  void updateRotation(double dx, double dy) => orbit(dx, dy);

  // ── Toggle'lar ───────────────────────────────────────────────
  void toggleGrid()      { _showGrid    = !_showGrid;    notifyListeners(); }
  void toggleAxes()      { _showAxes    = !_showAxes;    notifyListeners(); }
  void toggleWireframe() { _isWireframe = !_isWireframe; notifyListeners(); }

  void setLighting(String mode) {
    _lightingMode = mode;
    notifyListeners();
  }

  void loadModel(String path) {
    _pendingModelPath = path;
    notifyListeners();
  }

  void clearPendingModel() {
    _pendingModelPath = null;
    // notifyListeners() ÇAĞIRMA — _onFrame içinde çağrılır
  }

  // Gizmo'dan eksen tıklaması
  void setViewFromAxis(String axis) {
    switch (axis) {
      case 'X':  _theta = math.pi / 2;  _phi = math.pi / 2; break;
      case '-X': _theta = -math.pi / 2; _phi = math.pi / 2; break;
      case 'Y':  _theta = 0;            _phi = 0.05;         break;
      case '-Y': _theta = 0;            _phi = math.pi-0.05; break;
      case 'Z':  _theta = 0;            _phi = math.pi / 2;  break;
      case '-Z': _theta = math.pi;      _phi = math.pi / 2;  break;
    }
    notifyListeners();
  }
}
