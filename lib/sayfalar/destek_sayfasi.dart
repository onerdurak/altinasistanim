import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modeller.dart';
import '../oblok.dart';
import '../reklam.dart';

/// Geliştiriciye Destek Ol.
///
/// 1.0.28'de ücretli satın almaların tamamı (tek seferlik destek paketleri +
/// aylık abonelik) kaldırıldı. Destek artık yalnız kullanıcının kendi isteğiyle
/// izlediği kısa bir reklamla veriliyor; uygulamanın hiçbir özelliği ödeme ya da
/// reklam arkasında değil.
class SupportDeveloperPage extends StatefulWidget {
  const SupportDeveloperPage({super.key});

  @override
  State<SupportDeveloperPage> createState() => _SupportDeveloperPageState();
}

class _SupportDeveloperPageState extends State<SupportDeveloperPage> {
  /// Kullanıcının kaç kez destek olduğu (yalnız cihazda tutulur).
  static const String _sayacAnahtari = 'destek_reklam_sayisi';

  int _izlenen = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_sayaciOku());
    // Sayfa açılır açılmaz izin + SDK + önyükleme başlar; kullanıcı düğmeye
    // bastığında reklam çoğunlukla elde hazır olur.
    unawaited(Reklam.hazirla());
  }

  Future<void> _sayaciOku() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => _izlenen = prefs.getInt(_sayacAnahtari) ?? 0);
  }

  Future<void> _sayaciArtir() async {
    final prefs = await SharedPreferences.getInstance();
    final yeni = (prefs.getInt(_sayacAnahtari) ?? 0) + 1;
    await prefs.setInt(_sayacAnahtari, yeni);
    if (!mounted) return;
    setState(() => _izlenen = yeni);
  }

  Future<void> _destekOl() async {
    final kazandi = await Reklam.goster();
    if (!mounted) return;
    // Reklam gelmediyse veya erken kapatıldıysa sessiz kal — kullanıcıya hata
    // gösterilmez, düğme kendi durumunu zaten yansıtıyor.
    if (!kazandi) return;
    await _sayaciArtir();
    if (!mounted) return;
    _showSnack("Teşekkürler! Desteğin için çok mutlu olduk 💛", AppTheme.goldMain);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Geliştiriciye Destek Ol")),
      body: ValueListenableBuilder<ReklamDurumu>(
        valueListenable: Reklam.durum,
        builder: (context, durum, _) => _buildContent(durum),
      ),
    );
  }

  Widget _buildContent(ReklamDurumu durum) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        // Başlık
        const Icon(Icons.favorite_rounded, size: 72, color: AppTheme.goldMain),
        const SizedBox(height: 20),
        const Text(
          "Altın Asistanım ücretsiz ve öyle kalacak. Faydalı bulduysanız kısa "
          "bir reklam izleyerek destek olabilirsiniz; hiçbir ücret ödemeniz "
          "gerekmiyor ve hiçbir özellik kapalı değil.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 30),

        // ── REKLAM İZLEYEREK DESTEK ──
        _buildDestekKarti(durum),

        const SizedBox(height: 20),
        _buildSayac(),

        // ── Reklam gizlilik tercihleri (yalnız UMP gerektiriyorsa) ──
        if (Reklam.gizlilikSecenegiGerekli) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () => Reklam.gizlilikSecenekleriniGoster(),
              icon: const Icon(Icons.privacy_tip_outlined,
                  color: AppTheme.goldMain, size: 20),
              label: const Text("Reklam Gizlilik Tercihleri",
                  style: TextStyle(color: AppTheme.goldMain, fontSize: 13)),
            ),
          ),
        ],

        const SizedBox(height: 28),

        // ── OYUNUMUZU İNDİREREK DESTEK ──
        _buildOblokKarti(),

        // Yasal linkler
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(
                  'https://onerdurak.github.io/altin-asistanim-privacy/privacy-policy.html#terms')),
              child: const Text("Kullanım Koşulları",
                  style: TextStyle(
                      color: AppTheme.goldMain,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.goldMain)),
            ),
            const Text("  •  ",
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            GestureDetector(
              onTap: () => launchUrl(Uri.parse(
                  'https://onerdurak.github.io/altin-asistanim-privacy/privacy-policy.html')),
              child: const Text("Gizlilik Politikası",
                  style: TextStyle(
                      color: AppTheme.goldMain,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.goldMain)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDestekKarti(ReklamDurumu durum) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A2000), Color(0xFF1A1500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.goldMain.withAlpha(120), width: 1.5),
      ),
      child: Column(children: [
        const Icon(Icons.smart_display_rounded,
            color: AppTheme.goldMain, size: 40),
        const SizedBox(height: 10),
        const Text("REKLAM İZLEYEREK DESTEK OL",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1)),
        const SizedBox(height: 8),
        const Text(
          "Yaklaşık yarım dakikalık bir reklam izlersiniz, geliri doğrudan\n"
          "uygulamanın geliştirilmesine gider.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        _buildDugme(durum),
      ]),
    );
  }

  /// Düğme yalnız reklam GERÇEKTEN eldeyken aktif olur; hazırlık sürerken
  /// göstergeye, reklam gelmediğinde "Tekrar Dene"ye döner.
  Widget _buildDugme(ReklamDurumu durum) {
    if (durum.mesgul) {
      return const SizedBox(
        height: 52,
        child: Center(
            child: CircularProgressIndicator(color: AppTheme.goldMain)),
      );
    }

    final hazir = durum.hazir;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.goldMain,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppTheme.goldMain.withAlpha(80),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
        onPressed: () => hazir ? _destekOl() : Reklam.yenidenDene(),
        icon: Icon(hazir
            ? Icons.play_circle_fill_rounded
            : Icons.refresh_rounded),
        label: Text(hazir ? "Reklamı İzle" : "Tekrar Dene",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
    );
  }

  /// Aynı stüdyonun oyunu Oblok'un tanıtım kartı.
  ///
  /// Reklam izlemek istemeyen ya da zaten izlemiş kullanıcıya ikinci bir
  /// destek yolu sunuyor. Dokununca kullanıcının kendi platformunun mağazası
  /// açılır: Android'de Google Play, iOS'ta App Store.
  ///
  /// Kart, altın rengi reklam kartıyla yarışmasın diye gümüş paletle çizildi;
  /// sayfadaki asıl eylem reklam düğmesi, bu ikincil bir öneri.
  Widget _buildOblokKarti() {
    final adres = Oblok.magazaAdresi();
    // Mağazası olmayan platformda (masaüstü/web) kart hiç çizilmez.
    // Menüdeki güncelleme satırı da aynı şekilde davranıyor.
    if (adres == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => launchUrl(adres, mode: LaunchMode.externalApplication),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppTheme.silverDark.withAlpha(120)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(Oblok.ikon,
                    width: 58, height: 58, filterQuality: FilterQuality.medium),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Oyunumuzu deneyin",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    const Text(
                      "${Oblok.tamAd} — 8×8 mücevher blok bulmacamız. "
                      "Ücretsiz indirmeniz de bize destek olur.",
                      style: TextStyle(
                          color: Colors.white60, fontSize: 12.5, height: 1.4),
                    ),
                    const SizedBox(height: 9),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.download_rounded,
                          size: 15, color: AppTheme.silverLight),
                      const SizedBox(width: 5),
                      Text(Oblok.magazaEtiketi,
                          style: const TextStyle(
                              color: AppTheme.silverLight,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600)),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white38, size: 22),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildSayac() {
    if (_izlenen == 0) return const SizedBox.shrink();
    return Text(
      _izlenen == 1
          ? "Bir kez destek oldunuz 💛"
          : "Şimdiye kadar $_izlenen kez destek oldunuz 💛",
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white54, fontSize: 13),
    );
  }
}
