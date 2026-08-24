import 'package:flutter/foundation.dart';

/// Aynı stüdyonun diğer uygulaması Oblok'un mağaza kimliği.
///
/// [Surum.magazaAdresi] ile birleştirilmedi: orası *bu* uygulamanın kendi
/// mağaza sayfasını döndürüyor, burası başka bir uygulamanınkini. İkisinin
/// kimlikleri birbirinden bağımsız değişir; ortak bir yardımcıya sıkıştırmak
/// birini güncellerken diğerini bozma riski doğururdu.
class Oblok {
  /// Mağazalardaki tam ad. Kart içinde kısa "Oblok" kullanılıyor; bu değer
  /// kullanıcı mağazada ne göreceğini bilsin diye alt satırda duruyor.
  static const String tamAd = 'Oblok: Crystal City Puzzle';

  /// 1024px'lik kaynak ikonun 192px'e küçültülmüş kopyası (~14 KB).
  /// Kaynak, oblok deposunda `assets/ikon_kaynak.png`.
  static const String ikon = 'assets/icon/oblok.png';

  /// Mağaza adresi. `market://` ve `itms-apps://` yerine https kullanılıyor:
  /// mağaza uygulaması bulunmayan bir ortamda özel şemalar hiç açılmıyor,
  /// https her yerde çalışıyor. Aynı gerekçe [Surum.magazaAdresi] için de
  /// geçerli, oradaki notla birlikte okunmalı.
  ///
  /// Mağazası olmayan platformda (masaüstü/web) **null** döner; çağıran taraf
  /// kartı hiç çizmez. Gidilecek yer yokken "indir" demek anlamsız olurdu.
  static Uri? magazaAdresi() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse('https://play.google.com/store/apps/details'
            '?id=ai.drksistem.oblok');
      case TargetPlatform.iOS:
        return Uri.parse('https://apps.apple.com/app/id6790773505');
      default:
        return null;
    }
  }

  /// Düğme yazısı. Ekler mağazaya göre değişiyor ("Play'de" ama "Store'da"),
  /// o yüzden ad ve ek tek parça halinde tutuluyor — string birleştirmeyle
  /// üretilseydi biri yanlış çekimlenirdi.
  ///
  /// Yalnız [magazaAdresi] null değilken anlamlıdır.
  static String get magazaEtiketi =>
      defaultTargetPlatform == TargetPlatform.iOS
          ? "App Store'da indir"
          : "Google Play'de indir";
}
