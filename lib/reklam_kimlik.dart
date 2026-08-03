import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kReleaseMode;

/// AdMob kimlikleri — **TEK KAYNAK**.
///
/// Gerçek ID'ye geçerken yalnız buradaki `*Prod` sabitleri + iki native dosyadaki
/// App ID değişir:
///   • Android App ID → `android/app/src/main/AndroidManifest.xml` (APPLICATION_ID meta-data)
///   • iOS App ID     → `ios/Runner/Info.plist` (GADApplicationIdentifier)
/// Reklam birimi ID'sini SDK çalışma anında buradan ([odullu]) okur.
///
/// **Prod ↔ Test anahtarı:** release derlemeleri gerçek ID'leri, debug derlemeleri
/// Google'ın resmî TEST ID'lerini kullanır. `--dart-define=ADMOB_GERCEK=false|true`
/// ile açıkça ezilebilir.
///
/// Birim türü: **ödüllü geçiş** (rewarded interstitial). AdMob panosunda birim bu
/// türde oluşturuldu; [Reklam] de `RewardedInterstitialAd` API'sini kullanır. Tür
/// ile ID eşleşmezse SDK reklamı yüklemez.
class ReklamKimlik {
  ReklamKimlik._();

  /// Release = gerçek, debug = test. Dart define verilirse açık tercih kazanır.
  static const bool gercek =
      bool.fromEnvironment('ADMOB_GERCEK', defaultValue: kReleaseMode);

  // ─── App ID'ler (SDK bunları NATIVE config'ten okur; buradakiler belge amaçlı) ──
  static const String appIdAndroidTest =
      'ca-app-pub-3940256099942544~3347511713';
  static const String appIdIosTest = 'ca-app-pub-3940256099942544~1458002511';

  /// GERÇEK Android App ID — Manifest'teki değerle birebir aynı olmalı.
  static const String appIdAndroidProd =
      'ca-app-pub-8001492105518772~7803643402';

  /// GERÇEK iOS App ID — Info.plist'teki değerle birebir aynı olmalı.
  static const String appIdIosProd = 'ca-app-pub-8001492105518772~5121639747';

  // ─── Ödüllü geçiş birimi ID'leri ─────────────────────────────────────────────
  static const String _odulluAndroidTest =
      'ca-app-pub-3940256099942544/5354046379';
  static const String _odulluIosTest = 'ca-app-pub-3940256099942544/6978759866';

  /// GERÇEK Android birimi (AdMob → "ödüllü geçiş").
  static const String _odulluAndroidProd =
      'ca-app-pub-8001492105518772/7312688819';

  /// GERÇEK iOS birimi (AdMob → "ödüllü geçiş").
  static const String _odulluIosProd = 'ca-app-pub-8001492105518772/8431309303';

  /// Çalışma anında platform + moda göre doğru birim ID'si. Prod modda olup
  /// gerçek ID girilmemişse test birimine düşer (asla boş dönmez → SDK
  /// "invalid ad unit" ile patlamaz, yalnız gelir getirmez).
  static String get odullu {
    final iosMu = Platform.isIOS;
    if (gercek) {
      final prod = iosMu ? _odulluIosProd : _odulluAndroidProd;
      if (prod.isNotEmpty) return prod;
    }
    return iosMu ? _odulluIosTest : _odulluAndroidTest;
  }
}
