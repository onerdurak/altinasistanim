import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../modeller.dart';

/// Yeni şık simgeler – beğenmezseniz AssetCoinClassic ile değiştirin.
class AssetCoin extends StatelessWidget {
  final AssetType type;
  final double size;
  const AssetCoin({super.key, required this.type, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final config = _iconConfig(type);
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
                colors: [config.inner, config.outer],
                center: const Alignment(-0.3, -0.3),
                radius: 1.2),
            boxShadow: [
              BoxShadow(
                  color: config.outer.withOpacity(0.45),
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: const Offset(1, 2)),
              BoxShadow(
                  color: config.inner.withOpacity(0.25),
                  blurRadius: 10,
                  spreadRadius: -1,
                  offset: const Offset(-1, -1)),
            ],
            border: Border.all(
                color: Colors.white.withOpacity(0.35), width: 0.8)),
        alignment: Alignment.center,
        child: Text(config.symbol,
            style: TextStyle(
                color: config.textColor,
                fontWeight: FontWeight.w900,
                fontSize: config.symbol.length > 2
                    ? size * 0.30
                    : size * 0.42,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(
                      color: config.outer.withOpacity(0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1))
                ])));
  }

  static _CoinStyle _iconConfig(AssetType type) {
    switch (type.category) {
      case 'gold':
        return _CoinStyle(
            const Color(0xFFFFF8E1), const Color(0xFFE6A700),
            Colors.black87, type.label);
      case 'bracelet':
        return _CoinStyle(
            const Color(0xFFFFECB3), const Color(0xFFD4950C),
            Colors.black87, type.label);
      case 'silver':
        return _CoinStyle(
            const Color(0xFFE8EAF6), const Color(0xFF607D8B),
            Colors.white, type.label);
      case 'currency':
        if (type.id == 'usd') {
          return _CoinStyle(
              const Color(0xFFC8E6C9), const Color(0xFF2E7D32),
              Colors.white, '\$');
        } else if (type.id == 'gbp') {
          return _CoinStyle(
              const Color(0xFFF3E5F5), const Color(0xFF6A1B9A),
              Colors.white, '£');
        }
        return _CoinStyle(
            const Color(0xFFBBDEFB), const Color(0xFF1565C0),
            Colors.white, '€');
      case 'crypto':
        if (type.id == 'btc') {
          return _CoinStyle(
              const Color(0xFFFFE0B2), const Color(0xFFE67E00),
              Colors.white, '₿');
        }
        return _CoinStyle(
            const Color(0xFFE0E0E0), const Color(0xFF455A64),
            Colors.white, 'Ξ');
      case 'ons':
        return _CoinStyle(
            const Color(0xFFFFF3E0), const Color(0xFFBF8500),
            Colors.black87, type.label);
      default:
        return _CoinStyle(
            const Color(0xFFFFECB3), const Color(0xFFE65100),
            Colors.white, type.label);
    }
  }
}

class _CoinStyle {
  final Color inner;
  final Color outer;
  final Color textColor;
  final String symbol;
  const _CoinStyle(this.inner, this.outer, this.textColor, this.symbol);
}

/// Eski simgeler – geri dönmek isterseniz yukarıdaki AssetCoin'i silin,
/// bu sınıfın adını AssetCoin olarak değiştirin.
class AssetCoinClassic extends StatelessWidget {
  final AssetType type;
  final double size;
  const AssetCoinClassic({super.key, required this.type, this.size = 28});

  @override
  Widget build(BuildContext context) {
    List<Color> colors;
    Color textColor;
    if (type.category == 'silver') {
      colors = [AppTheme.silverLight, AppTheme.silverDark];
      textColor = Colors.black87;
    } else if (type.category == 'currency') {
      if (type.id == 'usd') {
        colors = [const Color(0xFFB9F6CA), const Color(0xFF00C853)];
      } else if (type.id == 'gbp') {
        colors = [const Color(0xFFE1BEE7), const Color(0xFF8E24AA)];
      } else {
        colors = [const Color(0xFF82B1FF), const Color(0xFF2962FF)];
      }
      textColor = Colors.black87;
    } else if (type.category == 'crypto' || type.category == 'ons') {
      colors = [const Color(0xFFFFCC80), AppTheme.btcColor];
      textColor = Colors.black;
    } else if (type.category == 'bracelet' || type.category == 'gold') {
      colors = [const Color(0xFFFFF59D), const Color(0xFFFBC02D)];
      textColor = Colors.black;
    } else {
      colors = [const Color(0xFFFFECB3), const Color(0xFFFF6F00)];
      textColor = Colors.brown[900]!;
    }
    return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            boxShadow: [
              BoxShadow(
                  color: colors.last.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(1, 1))
            ],
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1)),
        alignment: Alignment.center,
        child: Text(type.label,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w900,
                fontSize: type.label.length > 2 ? size * 0.32 : size * 0.45)));
  }
}

class MiniStat extends StatelessWidget {
  final String label;
  final double val;
  final Color color;
  final bool isObscured;

  const MiniStat(this.label, this.val, this.color,
      {super.key, this.isObscured = false});
  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.compact();
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      Text(isObscured ? "***" : f.format(val),
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 15))
    ]);
  }
}
