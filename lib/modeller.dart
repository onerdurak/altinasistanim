import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF101010);
  static const Color card = Color(0xFF1C1C1E);
  static const Color goldMain = Color(0xFFFFD700);
  static const Color goldDim = Color(0xFFFFA000);
  static const Color silverLight = Color(0xFFCFD8DC);
  static const Color silverDark = Color(0xFF546E7A);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonRed = Color(0xFFFF1744);
  static const Color textMain = Color(0xFFEEEEEE);
  static const Color btcColor = Color(0xFFF7931A);
}

String formatNumber(double value) {
  if (value == 0) return "0";
  if (value % 1 == 0) return value.toInt().toString();
  return value.toStringAsFixed(2);
}

class PortfolioItem {
  final String id;
  final String personName;
  final bool isCredit;
  final Map<String, double> assets;
  final DateTime date;

  PortfolioItem(
      {required this.id,
      required this.personName,
      required this.isCredit,
      required this.assets,
      required this.date});

  double getTotalValue(List<AssetType> market) {
    final map = {for (var a in market) a.id: a};
    double total = 0;
    assets.forEach((assetId, amount) {
      final asset = map[assetId];
      if (asset != null) total += asset.sellPrice * amount;
    });
    return total;
  }

  factory PortfolioItem.fromJson(Map<String, dynamic> json) => PortfolioItem(
      id: json['id'] ?? "",
      personName: json['personName'] ?? "",
      isCredit: json['isCredit'] ?? false,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      assets: (json['assets'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())));

  Map<String, dynamic> toJson() => {
        'id': id,
        'personName': personName,
        'isCredit': isCredit,
        'date': date.toIso8601String(),
        'assets': assets,
      };
}

class AssetType {
  final String id;
  final List<String> jsonKeys;
  final String shortName;
  final String name;
  final double sellMarkup;
  final double buyMarkup;
  final String category;

  double baseSellPrice;
  double baseBuyPrice;
  double sellPrice;
  double buyPrice;
  /// Yüzdelik değişimler. Üçü de **kendi geçmiş verimizden** hesaplanır
  /// (PiyasaMotoru._degisimleriHesapla); dış kaynağın "Change" alanı
  /// kullanılmaz — o alan ons için hep 0 dönüyordu ve neye göre
  /// kıyasladığı belirsizdi.
  ///
  /// [changeRate] 24 saatlik değişim; kullanıcının her ekranda ilk
  /// gördüğü değer budur. [change7d] ve [change30d] yalnız varlık detay
  /// sayfasında, istendiğinde açılır.
  double changeRate;
  /// null = henüz hesaplanamadı (geçmiş inmedi). 0 ise gerçekten
  /// değişmemiş demektir — ikisini ayırmak için nullable.
  double? change7d;
  double? change30d;
  double usdPrice;
  double baseUsdPrice;
  bool isDollarBase;
  final bool manualInput;

  AssetType(this.id, this.jsonKeys, this.shortName, this.name,
      this.baseSellPrice, this.baseBuyPrice, this.category,
      {this.sellMarkup = 1.0,
      this.buyMarkup = 1.0,
      this.sellPrice = 0,
      this.buyPrice = 0,
      this.changeRate = 0,
      this.change7d,
      this.change30d,
      this.usdPrice = 0,
      this.baseUsdPrice = 0,
      this.isDollarBase = false,
      this.manualInput = false});

  /// Dışarıdan gelen nSell ve nBuy zaten markup uygulanmış fiyatlardır.
  /// Bu metod içinde markup tekrar uygulanmaz.
  void applyNewPrices(double nSell, double nBuy, double nChange,
      {double? nUsd}) {
    baseSellPrice = nSell;
    baseBuyPrice = nBuy;

    if (baseBuyPrice > baseSellPrice) baseBuyPrice = baseSellPrice * 0.999;

    // Markup zaten dışarıdan uygulanmış geliyor, burada tekrar çarpılmaz
    sellPrice = baseSellPrice;
    buyPrice = baseBuyPrice;

    if (buyPrice > sellPrice) buyPrice = sellPrice * 0.999;

    changeRate = nChange;
    if (nUsd != null) {
      baseUsdPrice = nUsd;
      usdPrice = nUsd;
    }
  }

  String get label => shortName;

  /// Pencere anahtarına göre değişim: 'g24' | 'g7' | 'g30'.
  /// Sunucudaki degisim.csv sütun adlarıyla birebir aynı.
  double? degisim(String pencere) {
    switch (pencere) {
      case 'g7':
        return change7d;
      case 'g30':
        return change30d;
      default:
        return changeRate;
    }
  }
}
