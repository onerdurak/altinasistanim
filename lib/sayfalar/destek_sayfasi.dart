import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modeller.dart';

class PremiumManager {
  static bool _isSubscriptionActive = false;
  static bool get isPremium => _isSubscriptionActive;

  static const Set<String> subscriptionIds = {'aylik20plan'};

  static Future<void> checkPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isSubscriptionActive =
        prefs.getBool('is_subscription_active') ?? false;
    if (prefs.getBool('is_premium') == true && !_isSubscriptionActive) {
      _isSubscriptionActive = true;
    }
  }

  static Future<void> setSubscriptionActive(bool value) async {
    _isSubscriptionActive = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_subscription_active', value);
    await prefs.setBool('is_premium', value);
  }

  static Future<void> handlePurchase(String productId) async {
    if (subscriptionIds.contains(productId)) {
      await setSubscriptionActive(true);
    }
  }

  static Future<void> setPremium(bool value) async {
    await setSubscriptionActive(value);
  }
}

// Tek seferlik destek paket tanımları (görüntü için)
class _DestekPaket {
  final String id;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _DestekPaket(this.id, this.label, this.icon, this.iconColor);
}

const _paketler = [
  _DestekPaket('destek_100', 'Bronz Destek',
      Icons.military_tech_rounded, Color(0xFFCD7F32)),
  _DestekPaket('destek_200', 'Gümüş Destek',
      Icons.military_tech_rounded, Color(0xFFC0C0C0)),
  _DestekPaket('destek_500', 'Altın Destek',
      Icons.military_tech_rounded, AppTheme.goldMain),
  _DestekPaket('destek_1000', 'Platin Destek',
      Icons.diamond_rounded, Color(0xFF00D4FF)),
];

class SupportDeveloperPage extends StatefulWidget {
  const SupportDeveloperPage({super.key});

  @override
  State<SupportDeveloperPage> createState() => _SupportDeveloperPageState();
}

class _SupportDeveloperPageState extends State<SupportDeveloperPage> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _sub;

  // Tüm ürün ID'leri (Android only)
  static const Set<String> _allIds = {
    'destek_100',
    'destek_200',
    'destek_500',
    'destek_1000',
    'aylik20plan',
  };

  Map<String, ProductDetails> _products = {};
  bool _isAvailable = false;
  bool _isLoading = true;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    _sub = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _sub.cancel(),
      onError: (_) {},
    );
    _initStore();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  Future<void> _initStore() async {
    final available = await _iap.isAvailable();
    if (!available) {
      setState(() { _isAvailable = false; _isLoading = false; });
      return;
    }
    final resp = await _iap.queryProductDetails(_allIds);
    final map = <String, ProductDetails>{};
    for (final p in resp.productDetails) {
      map[p.id] = p;
    }
    setState(() {
      _isAvailable = true;
      _products = map;
      _isLoading = false;
    });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> list) {
    for (final p in list) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        PremiumManager.handlePurchase(p.productID);
        setState(() {});
        _showSnack("Teşekkürler! Desteğin için çok mutlu olduk 💛",
            AppTheme.goldMain);
      } else if (p.status == PurchaseStatus.error) {
        _showSnack("İşlem iptal edildi veya bir hata oluştu.",
            AppTheme.neonRed);
      }
      if (p.pendingCompletePurchase) {
        _iap.completePurchase(p);
      }
    }
    setState(() => _isPurchasing = false);
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  void _buyConsumable(ProductDetails product) {
    setState(() => _isPurchasing = true);
    _iap.buyConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  void _buySubscription(ProductDetails product) {
    setState(() => _isPurchasing = true);
    _iap.buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));
  }

  Future<void> _restore() async {
    try {
      await _iap.restorePurchases();
    } catch (_) {
      _showSnack("Geri yükleme sırasında bir hata oluştu.", AppTheme.neonRed);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Bu sayfa sadece Android içindir
    if (Platform.isIOS) {
      return Scaffold(
        appBar: AppBar(title: const Text("Geliştiriciye Destek Ol")),
        body: const Center(
          child: Text("Bu özellik Android üzerinden kullanılabilir.",
              style: TextStyle(color: Colors.white54)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Geliştiriciye Destek Ol")),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.goldMain))
          : !_isAvailable
              ? const Center(
                  child: Text("Mağaza bağlantısı kurulamadı.",
                      style: TextStyle(color: Colors.white54)))
              : Stack(children: [
                  _buildContent(),
                  if (_isPurchasing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.goldMain)),
                    ),
                ]),
    );
  }

  Widget _buildContent() {
    final subProduct = _products['aylik20plan'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
      physics: const BouncingScrollPhysics(),
      children: [
        // Başlık
        const Icon(Icons.favorite_rounded, size: 72, color: AppTheme.goldMain),
        const SizedBox(height: 20),
        const Text(
          "Altın Asistanım'ı faydalı bulduysanız ve ücretsiz kalmasına "
          "katkıda bulunmak isterseniz aşağıdaki paketlerden birini seçerek "
          "destek olabilirsiniz.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 30),

        // ── TEK SEFERLİK PAKETLER ──
        ..._paketler.map((paket) {
          final product = _products[paket.id];
          return _buildOneTimeCard(paket, product);
        }),

        const Divider(color: Colors.white12, height: 40),

        // ── AYLIK ABONELİK (DÜZENLİ DESTEK) ──
        if (subProduct != null) _buildSubscriptionCard(subProduct),

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
        const SizedBox(height: 16),

        // Geri Yükle
        Center(
          child: TextButton.icon(
            onPressed: _restore,
            icon: const Icon(Icons.restore, color: AppTheme.goldMain, size: 20),
            label: const Text("Satın Alımları Geri Yükle",
                style: TextStyle(
                    color: AppTheme.goldMain,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.goldMain)),
          ),
        ),
      ],
    );
  }

  Widget _buildOneTimeCard(_DestekPaket paket, ProductDetails? product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.goldMain.withAlpha(80), width: 1),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(paket.icon, color: paket.iconColor, size: 36),
        title: Text(paket.label,
            style: const TextStyle(
                color: AppTheme.goldMain,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        subtitle: const Text("Tek Seferlik",
            style: TextStyle(color: Colors.white54, fontSize: 13)),
        trailing: product != null
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldMain,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10)),
                onPressed:
                    _isPurchasing ? null : () => _buyConsumable(product),
                child: Text(product.price,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
              )
            : const SizedBox(
                width: 80,
                child: Text("—",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white24))),
      ),
    );
  }

  Widget _buildSubscriptionCard(ProductDetails product) {
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
        const Icon(Icons.star_rounded, color: AppTheme.goldMain, size: 36),
        const SizedBox(height: 10),
        const Text("DÜZENLİ DESTEK",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        const SizedBox(height: 8),
        const Text(
          "Her ay düzenli destek olarak projenin büyümesine\nen büyük katkıyı sağlayın.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldMain,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
            onPressed:
                _isPurchasing ? null : () => _buySubscription(product),
            child: Text("${product.price} / Ay",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 17)),
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Bu abonelik aylık olarak otomatik yenilenir. İstediğiniz zaman "
          "Ayarlar > Apple Kimliği > Abonelikler veya Google Play > Abonelikler "
          "bölümünden iptal edebilirsiniz. İptal, mevcut dönemin sonunda geçerli olur.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white38, fontSize: 10, height: 1.4),
        ),
      ]),
    );
  }
}
