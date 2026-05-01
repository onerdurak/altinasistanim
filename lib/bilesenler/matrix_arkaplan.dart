import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../modeller.dart';

/// Ana ekrana hareketli "matrix" tarzi arkaplan — para sembolleri
/// rastgele dikey kaymayla akar. Cok dusuk opaklik, market canli
/// hissi verir ama veri/fiyat illüzyonu yapmaz.
class MatrixArkaplan extends StatefulWidget {
  final Widget child;
  const MatrixArkaplan({super.key, required this.child});

  @override
  State<MatrixArkaplan> createState() => _MatrixArkaplanState();
}

class _MatrixArkaplanState extends State<MatrixArkaplan>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<_Sutun> _sutunlar;
  bool _hazir = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _hazirla(Size size) {
    if (_hazir) return;
    final rng = math.Random(42);
    const sembolHavuz = ['₺', '\$', '€', '₿', 'Ξ', '¥', '£', '₽',
                         '0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                         '▲', '▼', '+', '-'];
    final n = (size.width / 60).clamp(8, 18).toInt();
    _sutunlar = List.generate(n, (i) {
      // Ekran boyunca esit araliklarla
      final xRatio = (i + 0.5) / n;
      return _Sutun(
        xRatio: xRatio,
        speed: 8.0 + rng.nextDouble() * 14.0, // px/sn
        offset: rng.nextDouble() * 1500,
        gap: 60 + rng.nextDouble() * 40,
        sembolSec: () => sembolHavuz[rng.nextInt(sembolHavuz.length)],
        secedRng: math.Random(i * 31 + 7),
        renkTuru: rng.nextDouble(),
      );
    });
    _hazir = true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, cs) {
      _hazirla(Size(cs.maxWidth, cs.maxHeight));
      return Stack(
        children: [
          // Matrix katmani — arkada
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (c, _) {
                final t = _ctrl.value * _ctrl.duration!.inSeconds;
                return CustomPaint(
                  painter: _MatrixPainter(
                    sutunlar: _sutunlar,
                    zaman: t,
                  ),
                );
              },
            ),
          ),
          // Ana icerik
          widget.child,
        ],
      );
    });
  }
}

class _Sutun {
  final double xRatio;
  final double speed; // px/sn
  final double offset;
  final double gap; // semboller arasi dikey aralik
  final String Function() sembolSec;
  final math.Random secedRng;
  final double renkTuru; // 0..1

  // Sembolleri onceden olusturup cache'le (sutuna ozel)
  late final List<String> sabitSemboller = List.generate(
      40, (i) => sembolSec());

  _Sutun({
    required this.xRatio,
    required this.speed,
    required this.offset,
    required this.gap,
    required this.sembolSec,
    required this.secedRng,
    required this.renkTuru,
  });
}

class _MatrixPainter extends CustomPainter {
  final List<_Sutun> sutunlar;
  final double zaman;

  _MatrixPainter({required this.sutunlar, required this.zaman});

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in sutunlar) {
      final x = s.xRatio * size.width;
      // Sutunun toplam dikey kaymasi
      final shift = (s.offset + zaman * s.speed) % (size.height + 200);

      // Renk paleti
      final Color baseColor = s.renkTuru < 0.55
          ? AppTheme.goldMain
          : (s.renkTuru < 0.78
              ? AppTheme.neonGreen
              : AppTheme.neonRed);

      // Birden fazla sembolu sutunda yukaridan asagi diz
      final sembolSayisi = (size.height / s.gap).ceil() + 4;
      for (int j = 0; j < sembolSayisi; j++) {
        final yPure = j * s.gap - shift;
        // Wrap to screen
        double y = yPure;
        while (y < -50) y += size.height + 100;
        while (y > size.height + 50) y -= size.height + 100;

        // Bas (en alttaki) daha parlak, yukarilar daha solgun
        final mesafe = (size.height - y) / size.height;
        // Alpha: 8..28 arasi, yukari cikinca azalir
        final baseAlpha = (8 + 20 * mesafe.clamp(0, 1)).toInt();

        final col = baseColor.withAlpha(baseAlpha);
        final sembol = s.sabitSemboller[j % s.sabitSemboller.length];

        final tp = TextPainter(
          text: TextSpan(
            text: sembol,
            style: TextStyle(
              color: col,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(x - tp.width / 2, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) {
    return oldDelegate.zaman != zaman;
  }
}
