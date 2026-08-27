import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modeller.dart';
import '../oblok.dart';

/// Geliştiriciye Destek Ol.
///
/// **Geçmiş:** 1.0.28'de ücretli satın almaların tamamı (tek seferlik destek
/// paketleri + aylık abonelik) kaldırıldı, yerine ödüllü reklam kondu. 1.3.2'de
/// reklam da tamamen kaldırıldı: google_mobile_ads bağımlılığı, AdMob
/// kimlikleri ve UMP rıza akışı söküldü. Uygulamada artık hiçbir reklam yok.
///
/// **Bugün:** sayfada tek bir destek yolu var — aynı stüdyonun oyununu
/// indirmek. Sayfa bu yüzden durum tutmuyor; StatefulWidget olmasını
/// gerektiren reklam durumu ve izleme sayacı ile birlikte gitti.
class SupportDeveloperPage extends StatelessWidget {
  const SupportDeveloperPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geliştiriciye Destek Ol")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          const Icon(Icons.favorite_rounded, size: 72, color: AppTheme.goldMain),
          const SizedBox(height: 20),
          const Text(
            "Altın Asistanım tamamen ücretsiz. Reklam yok, ücretli özellik "
            "yok, abonelik yok — ve böyle kalacak.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.55),
          ),
          const SizedBox(height: 14),
          const Text(
            "Yine de destek olmak isterseniz, aynı stüdyodan çıkan oyunumuzu "
            "deneyebilirsiniz. Sizin için ücretsiz, bizim için çok değerli.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 30),

          _buildOblokKarti(),

          _buildYasalLinkler(),
        ],
      ),
    );
  }

  /// Aynı stüdyonun oyunu Oblok'un kartı — sayfanın asıl eylemi.
  ///
  /// Dokununca kullanıcının kendi platformunun mağazası açılır: Android'de
  /// Google Play, iOS'ta App Store.
  ///
  /// Reklam kaldırılmadan önce bu kart gümüş paletteydi; asıl eylem reklam
  /// düğmesiydi ve ikisi de altın olsa yarışırlardı. Artık sayfadaki tek
  /// eylem bu olduğu için altına alındı.
  Widget _buildOblokKarti() {
    final adres = Oblok.magazaAdresi();
    // Mağazası olmayan platformda (masaüstü/web) kart hiç çizilmez.
    // Menüdeki güncelleme satırı da aynı şekilde davranıyor.
    if (adres == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: () => launchUrl(adres, mode: LaunchMode.externalApplication),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A2000), Color(0xFF1A1500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.goldMain.withAlpha(120), width: 1.5),
            ),
            child: Column(children: [
              Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(Oblok.ikon,
                      width: 64,
                      height: 64,
                      filterQuality: FilterQuality.medium),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Oblok",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5)),
                      SizedBox(height: 4),
                      Text("8×8 mücevher blok bulmacası.\n25 şehirlik bir yolculuk.",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4)),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      launchUrl(adres, mode: LaunchMode.externalApplication),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.goldMain,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14))),
                  icon: const Icon(Icons.download_rounded),
                  label: Text(Oblok.magazaEtiketi,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildYasalLinkler() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _link("Kullanım Koşulları",
            'https://onerdurak.github.io/altin-asistanim-privacy/privacy-policy.html#terms'),
        const Text("  •  ",
            style: TextStyle(color: Colors.white38, fontSize: 13)),
        _link("Gizlilik Politikası",
            'https://onerdurak.github.io/altin-asistanim-privacy/privacy-policy.html'),
      ],
    );
  }

  Widget _link(String yazi, String adres) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(adres)),
      child: Text(yazi,
          style: const TextStyle(
              color: AppTheme.goldMain,
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: AppTheme.goldMain)),
    );
  }
}
