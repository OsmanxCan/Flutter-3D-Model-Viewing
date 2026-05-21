import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';

/// STL dosyalarını yüklemek için yardımcı sınıf.
/// Hem ASCII hem binary STL formatını destekler.
class STLLoaderUtil {
  /// Asset'ten STL yükle
  Future<Uint8List?> loadFromAssets(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Dosya yolundan STL yükle
  Future<Uint8List?> loadFromFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.readAsBytes();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// STL'nin binary mi ASCII mi olduğunu kontrol et
  bool isBinarySTL(Uint8List data) {
    if (data.length < 84) return false;
    // Binary STL: ilk 80 byte header, sonra 4 byte triangle sayısı
    final triangleCount = ByteData.view(data.buffer).getUint32(80, Endian.little);
    final expectedSize = 80 + 4 + (triangleCount * 50);
    return data.length == expectedSize;
  }

  /// Binary STL'den triangle verilerini çıkar
  List<Triangle> parseBinarySTL(Uint8List data) {
    final triangles = <Triangle>[];
    final byteData = ByteData.view(data.buffer);

    final triangleCount = byteData.getUint32(80, Endian.little);
    int offset = 84;

    for (int i = 0; i < triangleCount; i++) {
      if (offset + 50 > data.length) break;

      final normal = Vector3STL(
        byteData.getFloat32(offset, Endian.little),
        byteData.getFloat32(offset + 4, Endian.little),
        byteData.getFloat32(offset + 8, Endian.little),
      );
      offset += 12;

      final v1 = Vector3STL(
        byteData.getFloat32(offset, Endian.little),
        byteData.getFloat32(offset + 4, Endian.little),
        byteData.getFloat32(offset + 8, Endian.little),
      );
      offset += 12;

      final v2 = Vector3STL(
        byteData.getFloat32(offset, Endian.little),
        byteData.getFloat32(offset + 4, Endian.little),
        byteData.getFloat32(offset + 8, Endian.little),
      );
      offset += 12;

      final v3 = Vector3STL(
        byteData.getFloat32(offset, Endian.little),
        byteData.getFloat32(offset + 4, Endian.little),
        byteData.getFloat32(offset + 8, Endian.little),
      );
      offset += 12;

      offset += 2; // attribute byte count

      triangles.add(Triangle(normal: normal, v1: v1, v2: v2, v3: v3));
    }

    return triangles;
  }

  /// Bounding box hesapla (model merkezleme için)
  BoundingBox calculateBoundingBox(List<Triangle> triangles) {
    double minX = double.infinity, minY = double.infinity, minZ = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity, maxZ = -double.infinity;

    for (final tri in triangles) {
      for (final v in [tri.v1, tri.v2, tri.v3]) {
        if (v.x < minX) minX = v.x;
        if (v.y < minY) minY = v.y;
        if (v.z < minZ) minZ = v.z;
        if (v.x > maxX) maxX = v.x;
        if (v.y > maxY) maxY = v.y;
        if (v.z > maxZ) maxZ = v.z;
      }
    }

    return BoundingBox(
      min: Vector3STL(minX, minY, minZ),
      max: Vector3STL(maxX, maxY, maxZ),
    );
  }
}

class Vector3STL {
  final double x, y, z;
  const Vector3STL(this.x, this.y, this.z);
}

class Triangle {
  final Vector3STL normal;
  final Vector3STL v1, v2, v3;
  const Triangle({required this.normal, required this.v1, required this.v2, required this.v3});
}

class BoundingBox {
  final Vector3STL min, max;
  const BoundingBox({required this.min, required this.max});

  Vector3STL get center => Vector3STL(
    (min.x + max.x) / 2,
    (min.y + max.y) / 2,
    (min.z + max.z) / 2,
  );

  double get maxDimension {
    final dx = max.x - min.x;
    final dy = max.y - min.y;
    final dz = max.z - min.z;
    return dx > dy ? (dx > dz ? dx : dz) : (dy > dz ? dy : dz);
  }
}
