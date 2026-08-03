import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'reklam_kimlik.dart';

/// Reklam katmanının o anki durumu — destek sayfasındaki düğme buna bakar.
@immutable
class ReklamDurumu {
  const ReklamDurumu({
    required this.izinTamam,
    required this.hazir,
    required this.mesgul,
  });

  /// UMP izni alındı ve AdMob SDK'sı başlatıldı.
  final bool izinTamam;

  /// Gösterilmeye hazır bir reklam elde bekliyor.
  final bool hazir;

  /// Şu anda yükleme veya gösterim sürüyor.
  final bool mesgul;

  static const baslangic =
      ReklamDurumu(izinTamam: false, hazir: false, mesgul: false);
}

/// Uygulamadaki TEK reklam noktası: "Geliştiriciye Destek Ol" ödüllü reklamı.
///
/// Reklam kendiliğinden asla açılmaz; yalnız kullanıcı destek düğmesine bastığında
/// gösterilir. Akış: UMP izni → SDK başlatma → önceden yükleme → gösterim.
///
/// Düğme yalnız [ReklamDurumu.hazir] iken aktifleşir; yani basılabiliyorsa reklam
/// gerçekten eldedir. Reklam yokken kullanıcıya hata gösterilmez, düğme sönük kalır.
class Reklam {
  Reklam._();

  static final ValueNotifier<ReklamDurumu> durum =
      ValueNotifier(ReklamDurumu.baslangic);

  /// Son hata — teşhis için; `flutter logs` içinde `AA-REKLAM` etiketiyle de yazılır.
  static String? sonHata;

  static bool _izinTamam = false;
  static bool _mesgul = false;
  static bool _gizlilikSecenegiGerekli = false;
  static RewardedInterstitialAd? _hazir;
  static Future<void>? _hazirlama;
  static Completer<bool>? _yukleme;

  /// AB/UK kullanıcısı gibi UMP'nin "gizlilik seçenekleri" düğmesi istediği durumlar.
  static bool get gizlilikSecenegiGerekli => _gizlilikSecenegiGerekli;

  static void _log(String mesaj) => debugPrint('AA-REKLAM: $mesaj');

  static void _bildir() {
    durum.value = ReklamDurumu(
      izinTamam: _izinTamam,
      hazir: _hazir != null,
      mesgul: _mesgul,
    );
  }

  /// İzin + SDK + ilk yükleme. Eşzamanlı çağrılar aynı Future'ı paylaşır; hazırlık
  /// başarısız olursa kilit bırakılır ki sonraki çağrı yeniden denesin.
  static Future<void> hazirla() {
    final suren = _hazirlama;
    if (suren != null) return suren;
    late final Future<void> yeni;
    yeni = _hazirla().whenComplete(() {
      if (identical(_hazirlama, yeni) && !_izinTamam) _hazirlama = null;
    });
    _hazirlama = yeni;
    return yeni;
  }

  static Future<void> _hazirla() async {
    try {
      final izinVar = await _izinTopla();
      _gizlilikSecenegiGerekli = await _gizlilikSecenegiSorgula();
      if (!izinVar) {
        sonHata ??= 'Reklam izni verilmedi (UMP)';
        _log(sonHata!);
        _bildir();
        return;
      }
      await MobileAds.instance.initialize();
      _izinTamam = true;
      _bildir();
      _log('SDK hazır — gercek=${ReklamKimlik.gercek}, '
          'birim=${ReklamKimlik.odullu}');
      unawaited(_yukle());
    } catch (hata) {
      sonHata = 'Reklam hazırlanamadı: $hata';
      _log(sonHata!);
      _izinTamam = false;
      _bildir();
    }
  }

  /// UMP izin akışı: gerekiyorsa onay formunu gösterir, sonunda reklam istenip
  /// istenemeyeceğini döndürür. Ağ takılırsa 15 sn sonra "izin yok" sayılır.
  static Future<bool> _izinTopla() {
    final tamam = Completer<bool>();

    void bitir() {
      if (tamam.isCompleted) return;
      ConsentInformation.instance.canRequestAds().then(
        (deger) {
          if (!tamam.isCompleted) tamam.complete(deger);
        },
        onError: (_) {
          if (!tamam.isCompleted) tamam.complete(false);
        },
      );
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () => ConsentForm.loadAndShowConsentFormIfRequired((hata) {
        if (hata != null) {
          sonHata = 'UMP form: ${hata.errorCode} ${hata.message}';
          _log(sonHata!);
        }
        bitir();
      }),
      (hata) {
        sonHata = 'UMP güncelleme: ${hata.errorCode} ${hata.message}';
        _log(sonHata!);
        bitir();
      },
    );

    return tamam.future
        .timeout(const Duration(seconds: 15), onTimeout: () => false);
  }

  static Future<bool> _gizlilikSecenegiSorgula() async {
    try {
      final gereklilik = await ConsentInformation.instance
          .getPrivacyOptionsRequirementStatus();
      return gereklilik == PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  /// Arka planda bir reklam yükler. Tek uçuş: aynı anda yalnız bir yükleme; elde
  /// hazır reklam varsa hiç istek atmaz.
  static Future<bool> _yukle() {
    if (_hazir != null) return Future<bool>.value(true);
    final suren = _yukleme;
    if (suren != null) return suren.future;
    if (!_izinTamam) return Future<bool>.value(false);

    final ucus = Completer<bool>();
    _yukleme = ucus;
    _mesgul = true;
    _bildir();

    void bitir(bool basarili) {
      if (identical(_yukleme, ucus)) _yukleme = null;
      _mesgul = false;
      _bildir();
      if (!ucus.isCompleted) ucus.complete(basarili);
    }

    try {
      RewardedInterstitialAd.load(
        adUnitId: ReklamKimlik.odullu,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback:
            RewardedInterstitialAdLoadCallback(
          onAdLoaded: (reklam) {
            _hazir = reklam;
            bitir(true);
          },
          onAdFailedToLoad: (hata) {
            sonHata = 'yükleme: code=${hata.code} ${hata.message}';
            _log(sonHata!);
            bitir(false);
          },
        ),
      );
    } catch (hata) {
      sonHata = 'yükleme istisnası: $hata';
      _log(sonHata!);
      bitir(false);
    }

    return ucus.future;
  }

  /// Kullanıcı destek düğmesine bastığında çağrılır. Reklam sonuna kadar izlenip
  /// ödül hak edildiyse true döner. Reklam yoksa/gösterilemezse sessizce false
  /// döner — sahte "teşekkürler" verilmez.
  static Future<bool> goster() async {
    if (_mesgul) return false;
    await hazirla();
    if (!_izinTamam) return false;

    var eldeki = _hazir;
    _hazir = null;
    if (eldeki == null) {
      final yuklendi = await _yukle();
      if (!yuklendi) return false;
      eldeki = _hazir;
      _hazir = null;
    }
    if (eldeki == null) return false;

    final reklam = eldeki;
    _mesgul = true;
    _bildir();

    final sonuc = Completer<bool>();
    var kazandi = false;
    var kapandi = false;

    void kapat() {
      if (kapandi) return;
      kapandi = true;
      reklam.dispose();
      _mesgul = false;
      _bildir();
      if (!sonuc.isCompleted) sonuc.complete(kazandi);
      // Bir sonraki destek için hemen yeni reklam hazırla.
      unawaited(_yukle());
    }

    reklam.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (_) => kapat(),
      onAdFailedToShowFullScreenContent: (_, hata) {
        sonHata = 'gösterim: code=${hata.code} ${hata.message}';
        _log(sonHata!);
        kapat();
      },
    );

    try {
      await reklam.show(onUserEarnedReward: (_, __) => kazandi = true);
    } catch (hata) {
      sonHata = 'gösterim istisnası: $hata';
      _log(sonHata!);
      kapat();
    }

    // SDK kapanış callback'i kaybolursa sayfa süresiz kilitli kalmasın.
    return sonuc.future.timeout(
      const Duration(seconds: 150),
      onTimeout: () {
        _log('gösterim sonucu 150 sn zaman aşımı');
        kapat();
        return kazandi;
      },
    );
  }

  /// Reklam gelmediğinde kullanıcının "Tekrar Dene" düğmesi.
  static Future<void> yenidenDene() async {
    sonHata = null;
    if (!_izinTamam) _hazirlama = null;
    await hazirla();
    await _yukle();
  }

  /// UMP gizlilik tercihleri formu. Kapanınca eldeki reklam atılır ve izin
  /// durumu yeni tercihe göre baştan kurulur.
  static Future<void> gizlilikSecenekleriniGoster() async {
    final tamam = Completer<void>();
    ConsentForm.showPrivacyOptionsForm((hata) {
      if (hata != null) {
        sonHata = 'gizlilik formu: ${hata.errorCode} ${hata.message}';
        _log(sonHata!);
      }
      if (!tamam.isCompleted) tamam.complete();
    });
    await tamam.future;

    _hazir?.dispose();
    _hazir = null;
    _izinTamam = false;
    _hazirlama = null;
    _bildir();
    await hazirla();
  }
}
