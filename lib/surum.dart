import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Uygulamanın kendi sürümü ve mağazadaki sürümle karşılaştırması.
///
/// **Önceden:** uygulama kendi sürümünü bilmiyordu. Menüdeki "Sürüm: X"
/// yazısı doğrudan sunucudan okunuyordu (`canli.csv` 21. satır, B sütunu →
/// [PiyasaMotoru.sheetVersion]), yani kullanıcının telefonundaki sürüm ne
/// olursa olsun sunucunun söylediği görünüyordu. Sunucudaki değer
/// (`veri-toplayici/ayarlar.json` → `surum`) elle güncellendiği için de
/// kayıyordu: 22.08.2026'da uygulama 1.3.0'dayken ekranda 1.0.28 yazıyordu.
///
/// **Artık:** kendi sürümü derlemeden okunuyor (package_info_plus), sunucudan
/// gelen değer ise "en son yayınlanan sürüm" anlamına geliyor. İkisi
/// karşılaştırılabildiği için güncelleme olup olmadığı da söylenebiliyor.
class Surum {
  /// pubspec.yaml'daki sürüm (örn. "1.3.0"). Okunamazsa boş kalır.
  static String uygulama = '';

  /// Yapı numarası (pubspec'teki `+67`). Yalnız Hakkında sayfasında.
  static String yapi = '';

  static Future<void> yukle() async {
    try {
      final bilgi = await PackageInfo.fromPlatform();
      uygulama = bilgi.version;
      yapi = bilgi.buildNumber;
    } catch (_) {
      // Okunamazsa boş kalır ve ekranda sürüm satırı hiç çizilmez.
      // Uydurma bir değer yazmak, düzeltmeye çalıştığımız hatanın
      // aynısı olurdu.
    }
  }

  /// Sürümleri parça parça sayısal karşılaştırır.
  /// a > b ise pozitif, a < b ise negatif, eşitse 0.
  ///
  /// Düz metin karşılaştırması olmaz: "1.10.0" < "1.9.0" çıkardı,
  /// çünkü karakter olarak '1' < '9'.
  static int karsilastir(String a, String b) {
    final pa = _parcala(a);
    final pb = _parcala(b);
    final n = pa.length > pb.length ? pa.length : pb.length;
    for (int i = 0; i < n; i++) {
      final x = i < pa.length ? pa[i] : 0;
      final y = i < pb.length ? pb[i] : 0;
      if (x != y) return x - y;
    }
    return 0;
  }

  /// "1.3.0+67" -> [1, 3, 0]. Yapı numarası ve ek etiketler atılır;
  /// kullanıcıya gösterilen sürüm onlar değil.
  static List<int> _parcala(String s) {
    final govde = s.split('+').first.trim();
    return govde
        .split('.')
        .map((p) => int.tryParse(RegExp(r'\d+').stringMatch(p) ?? '') ?? 0)
        .toList();
  }

  /// Sunucunun bildirdiği sürüm bizimkinden yeniyse true.
  ///
  /// Taraflardan biri bilinmiyorsa **false** döner: emin olmadan
  /// "güncelleme var" demek, olmayan bir güncellemeye yönlendirmek olur.
  static bool guncellemeVar(String sunucuSurumu) {
    if (uygulama.isEmpty || sunucuSurumu.trim().isEmpty) return false;
    return karsilastir(sunucuSurumu, uygulama) > 0;
  }

  /// Mağaza adresi. `market://` yerine https kullanılıyor: uygulama
  /// yüklü olmayan bir ortamda (tarayıcı önizlemesi, emülatör) market
  /// şeması hiç açılmıyor, https her yerde çalışıyor.
  static Uri? magazaAdresi() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Uri.parse('https://play.google.com/store/apps/details'
            '?id=com.drksistem.altinasistanim');
      case TargetPlatform.iOS:
        return Uri.parse('https://apps.apple.com/app/id6760838244');
      default:
        return null;
    }
  }
}
