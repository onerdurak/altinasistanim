import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../modeller.dart';
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
