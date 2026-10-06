// Generates the local PNG assets used by the app.
// Run with: dart run tool/generate_assets.dart
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int width = 900;
const int height = 600;

class Rgb {
  const Rgb(this.r, this.g, this.b);
  final int r;
  final int g;
  final int b;

  Rgb mix(Rgb other, double t) => Rgb(
        (r + (other.r - r) * t).round().clamp(0, 255),
        (g + (other.g - g) * t).round().clamp(0, 255),
        (b + (other.b - b) * t).round().clamp(0, 255),
      );
}

class Canvas {
  Canvas(this.w, this.h) : px = Uint8List(w * h * 3);

  final int w;
  final int h;
  final Uint8List px;

  void set(int x, int y, Rgb c) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    final i = (y * w + x) * 3;
    px[i] = c.r;
    px[i + 1] = c.g;
    px[i + 2] = c.b;
  }

  Rgb get(int x, int y) {
    final i = ((y.clamp(0, h - 1)) * w + (x.clamp(0, w - 1))) * 3;
    return Rgb(px[i], px[i + 1], px[i + 2]);
  }

  void fillGradient(Rgb top, Rgb bottom) {
    for (var y = 0; y < h; y++) {
      final t = y / (h - 1);
      final c = top.mix(bottom, t * t);
      for (var x = 0; x < w; x++) {
        set(x, y, c);
      }
    }
  }

  void sun(int cx, int cy, int radius, Rgb core, Rgb glow) {
    for (var y = cy - radius * 3; y <= cy + radius * 3; y++) {
      for (var x = cx - radius * 3; x <= cx + radius * 3; x++) {
        final d = math.sqrt((x - cx) * (x - cx) + (y - cy) * (y - cy));
        if (d <= radius) {
          set(x, y, core);
        } else if (d <= radius * 3) {
          final t = 1 - (d - radius) / (radius * 2);
          set(x, y, get(x, y).mix(glow, t * 0.35));
        }
      }
    }
  }

  void mountains(List<List<double>> peaks, Rgb color, double opacity) {
    for (var x = 0; x < w; x++) {
      var top = h.toDouble();
      for (final p in peaks) {
        final cx = p[0];
        final ph = p[1];
        final hw = p[2];
        final d = (x - cx).abs();
        if (d < hw) top = math.min(top, ph * (1 - d / hw));
      }
      if (top >= h) continue;
      for (var y = top.round(); y < h; y++) {
        final t = ((y - top) / math.max(1, h - top)).clamp(0.0, 1.0);
        final shade = color.mix(const Rgb(0, 0, 0), t * 0.35);
        set(x, y, get(x, y).mix(shade, opacity));
      }
    }
  }

  void dunes(Rgb color, double base, double amp, double period, double phase) {
    for (var x = 0; x < w; x++) {
      final top = (base + amp * math.sin(x / period + phase)).round();
      for (var y = top; y < h; y++) {
        final t = ((y - top) / math.max(1, h - top)).clamp(0.0, 1.0);
        set(x, y, color.mix(const Rgb(0, 0, 0), t * 0.25));
      }
    }
  }

  void water(Rgb deep, Rgb shallow, double from) {
    for (var y = from.round(); y < h; y++) {
      final t = (y - from) / math.max(1, h - from);
      final base = deep.mix(shallow, (1 - t) * 0.8);
      for (var x = 0; x < w; x++) {
        final ripple = (math.sin(y * 0.9 + x * 0.05) * 0.5 + 0.5) * 14;
        set(x, y, base.mix(const Rgb(255, 255, 255), ripple / 255 * 0.5));
      }
    }
  }

  void haze(double from, double to, Rgb color) {
    for (var y = from.round(); y < to.round(); y++) {
      final t = (y - from) / math.max(1, to - from);
      for (var x = 0; x < w; x++) {
        set(x, y, get(x, y).mix(color, t * 0.55));
      }
    }
  }

  void band(double top, double bottom, Rgb color) {
    for (var y = top.round(); y < bottom.round(); y++) {
      for (var x = 0; x < w; x++) {
        set(x, y, color);
      }
    }
  }

  void roundedMask(int radius) {
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        var outside = false;
        if (x < radius && y < radius) {
          final dx = radius - x;
          final dy = radius - y;
          if (dx * dx + dy * dy > radius * radius) outside = true;
        }
        if (!outside &&
            x >= w - radius &&
            y < radius &&
            (x - (w - radius)) * (x - (w - radius)) + (radius - y) * (radius - y) >
                radius * radius) {
          outside = true;
        }
        if (!outside &&
            x < radius &&
            y >= h - radius &&
            (radius - x) * (radius - x) + (y - (h - radius)) * (y - (h - radius)) >
                radius * radius) {
          outside = true;
        }
        if (outside) set(x, y, const Rgb(255, 255, 255));
      }
    }
  }
}

Uint8List _u32(int v) {
  final b = ByteData(4);
  b.setUint32(0, v);
  return b.buffer.asUint8List();
}

int _crc32(List<int> data) {
  var table = _crcTable;
  if (table == null) {
    table = List<int>.generate(256, (n) {
      var c = n;
      for (var k = 0; k < 8; k++) {
        c = (c & 1) != 0 ? 0xEDB88320 ^ (c >> 1) : c >> 1;
      }
      return c;
    });
    _crcTable = table;
  }
  var c = 0xffffffff;
  for (final b in data) {
    c = table[(c ^ b) & 0xff] ^ (c >> 8);
  }
  return (c ^ 0xffffffff) & 0xffffffff;
}

List<int>? _crcTable;

void _chunk(BytesBuilder out, String type, List<int> data) {
  out.add(_u32(data.length));
  final t = type.codeUnits;
  out.add(t);
  out.add(data);
  out.add(_u32(_crc32(<int>[...t, ...data])));
}

Uint8List encodePng(Canvas c) {
  final raw = <int>[];
  const bpp = 3;
  for (var y = 0; y < c.h; y++) {
    raw.add(1); // Sub filter
    final rowStart = y * c.w * bpp;
    for (var i = 0; i < c.w * bpp; i++) {
      final left = i >= bpp ? c.px[rowStart + i - bpp] : 0;
      raw.add((c.px[rowStart + i] - left) & 0xff);
    }
  }

  final idat = ZLibCodec(level: 9).encode(raw);

  final out = BytesBuilder();
  out.add(<int>[137, 80, 78, 71, 13, 10, 26, 10]);
  final ihdr = BytesBuilder();
  ihdr.add(_u32(c.w));
  ihdr.add(_u32(c.h));
  ihdr.add(<int>[8, 2, 0, 0, 0]);
  _chunk(out, 'IHDR', ihdr.toBytes());
  _chunk(out, 'IDAT', idat);
  _chunk(out, 'IEND', <int>[]);
  return out.toBytes();
}

void save(String name, Canvas c) {
  final bytes = encodePng(c);
  File('assets/images/$name').writeAsBytesSync(bytes);
  stdout.writeln('wrote assets/images/$name (${(bytes.length / 1024).toStringAsFixed(1)} KB)');
}

void main() {
  Directory('assets/images').createSync(recursive: true);

  // 1. El Nido, Palawan - turquoise lagoon + limestone cliffs
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(56, 168, 224), const Rgb(178, 232, 244));
    c.sun(680, 130, 42, const Rgb(255, 244, 200), const Rgb(255, 240, 170));
    c.mountains([
      [120, 300, 260],
      [430, 360, 300],
      [760, 280, 250],
    ], const Rgb(58, 122, 84), 0.95);
    c.mountains([
      [300, 380, 220],
      [620, 350, 190],
    ], const Rgb(34, 88, 62), 0.95);
    c.water(const Rgb(9, 130, 160), const Rgb(120, 224, 224), 440);
    c.haze(300, 440, const Rgb(255, 255, 255));
    save('el_nido.png', c);
  }

  // 2. Banaue Rice Terraces - green stepped fields
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(168, 214, 240), const Rgb(232, 244, 236));
    c.sun(200, 110, 38, const Rgb(255, 250, 225), const Rgb(255, 245, 200));
    c.mountains([
      [180, 300, 320],
      [560, 330, 380],
      [840, 290, 240],
    ], const Rgb(96, 132, 104), 0.85);
    c.haze(280, 380, const Rgb(255, 255, 255));
    for (var i = 0; i < 7; i++) {
      final top = 340.0 + i * 36;
      c.dunes(Rgb(64 + i * 6, 132 + i * 6, 62 + i * 4), top, 16, 190, i * 1.1);
      c.band(top + 6, top + 9, const Rgb(226, 240, 208));
    }
    save('banaue.png', c);
  }

  // 3. Chocolate Hills, Bohol - rolling brown mounds
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(112, 180, 232), const Rgb(212, 236, 248));
    c.sun(730, 120, 40, const Rgb(255, 248, 214), const Rgb(255, 240, 180));
    c.haze(0, 300, const Rgb(255, 255, 255));
    c.mountains([
      [90, 330, 130],
      [260, 300, 140],
      [430, 340, 130],
      [600, 310, 150],
      [790, 345, 140],
    ], const Rgb(126, 92, 62), 0.95);
    c.dunes(const Rgb(78, 140, 78), 430, 18, 210, 0.4);
    c.band(470, 600, const Rgb(72, 134, 76));
    c.water(const Rgb(60, 118, 128), const Rgb(150, 214, 226), 540);
    save('chocolate_hills.png', c);
  }

  // 4. Boracay White Beach - white sand + turquoise water
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(84, 176, 232), const Rgb(196, 238, 246));
    c.sun(180, 110, 44, const Rgb(255, 250, 220), const Rgb(255, 244, 190));
    c.water(const Rgb(12, 132, 168), const Rgb(126, 226, 226), 250);
    c.dunes(const Rgb(240, 226, 186), 430, 10, 260, 0.2);
    c.band(448, 600, const Rgb(248, 240, 214));
    for (var y = 452; y < 600; y += 9) {
      c.band(y.toDouble(), (y + 3).toDouble(), const Rgb(232, 216, 180));
    }
    c.band(120, 200, const Rgb(38, 96, 118));
    c.haze(190, 260, const Rgb(255, 255, 255));
    save('boracay.png', c);
  }

  // 5. Mayon Volcano, Albay - perfect cone at sunset
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(46, 62, 128), const Rgb(248, 158, 96));
    c.sun(450, 300, 52, const Rgb(255, 226, 150), const Rgb(255, 180, 120));
    c.mountains([
      [450, 150, 330],
    ], const Rgb(58, 62, 92), 0.95);
    c.mountains([
      [90, 430, 220],
      [830, 440, 240],
    ], const Rgb(32, 38, 60), 0.95);
    c.band(470, 600, const Rgb(22, 26, 46));
    c.haze(400, 480, const Rgb(255, 190, 140));
    save('mayon.png', c);
  }

  // 6. Hundred Islands, Pangasinan - island-dotted sea
  {
    final c = Canvas(width, height);
    c.fillGradient(const Rgb(72, 168, 228), const Rgb(206, 240, 248));
    c.sun(720, 120, 40, const Rgb(255, 250, 222), const Rgb(255, 244, 190));
    c.haze(180, 300, const Rgb(255, 255, 255));
    c.water(const Rgb(10, 118, 152), const Rgb(112, 218, 220), 260);
    const isles = <List<double>>[
      [120, 300, 90, 52],
      [300, 250, 120, 70],
      [520, 310, 100, 46],
      [700, 240, 130, 78],
      [860, 320, 80, 40],
    ];
    for (final i in isles) {
      c.mountains([
        [i[0], i[1], i[2]],
      ], const Rgb(46, 104, 78), 0.95);
      c.dunes(const Rgb(226, 214, 172), i[1] + 34, 6, 140, i[0] / 90);
    }
    save('hundred_islands.png', c);
  }

  // 7. Intramuros, Manila - sunset city walls
  {
    final c = Canvas(width, height);
    const Rgb wall = Rgb(46, 36, 60);
    const Rgb wallDark = Rgb(32, 25, 44);
    c.fillGradient(const Rgb(96, 76, 148), const Rgb(252, 186, 120));
    c.sun(450, 300, 66, const Rgb(255, 234, 162), const Rgb(255, 176, 120));

    // Church towers with pointed spires.
    c.band(390, 600, wallDark);
    for (final tower in <List<double>>[
      <double>[250, 150, 46],
      <double>[660, 200, 40],
    ]) {
      final int cx = tower[0].toInt();
      final int top = tower[1].toInt();
      final int halfW = tower[2].toInt();
      for (var x = cx - halfW; x <= cx + halfW; x++) {
        final double t = (x - (cx - halfW)) / (halfW * 2);
        final double peak = 1 - (t - 0.5).abs() * 2;
        final int yTop = top + 46 - (46 * peak).round();
        c.band(yTop.toDouble(), 400, wall);
      }
      c.band(top.toDouble(), (top + 6).toDouble(), const Rgb(255, 214, 140));
    }

    // City wall with battlements.
    c.band(400, 600, wall);
    c.band(400, 412, const Rgb(66, 52, 86));
    for (var x = 0; x < 900; x += 56) {
      c.band(390, 404, const Rgb(66, 52, 86));
      c.band(390, 400, wall);
    }
    c.haze(330, 400, const Rgb(255, 200, 150));
    save('intramuros.png', c);
  }

  // 8. App logo
  {
    const s = 512;
    final c = Canvas(s, s);
    c.fillGradient(const Rgb(0, 128, 170), const Rgb(0, 200, 190));
    c.sun(150, 140, 46, const Rgb(255, 240, 180), const Rgb(255, 230, 150));
    c.mountains([
      [110, 300, 130],
      [256, 250, 170],
      [400, 300, 130],
    ], const Rgb(255, 255, 255), 0.35);
    c.water(const Rgb(0, 96, 140), const Rgb(0, 176, 190), 330);
    save('logo.png', c);
  }

  // 9. Profile avatar
  {
    const s = 256;
    final c = Canvas(s, s);
    c.fillGradient(const Rgb(0, 150, 190), const Rgb(0, 210, 200));
    c.sun(190, 60, 34, const Rgb(255, 240, 190), const Rgb(255, 230, 160));
    c.mountains([
      [70, 200, 90],
      [190, 190, 110],
    ], const Rgb(255, 255, 255), 0.3);
    c.water(const Rgb(0, 100, 150), const Rgb(0, 180, 200), 200);
    save('avatar.png', c);
  }

  stdout.writeln('All assets generated.');
}
