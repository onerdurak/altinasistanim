import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../modeller.dart';
import '../bilesenler/ortak_araclar.dart';

/// Borç ve Alacak'i tek sayfada birlestiren widget.
/// Ust kisimda iki sekme: BORÇ / ALACAK
/// FAB main.dart'tan ekleme dialogu gosterir.
class BorcAlacakPage extends StatefulWidget {
  final List<PortfolioItem> debts;
  final List<PortfolioItem> credits;
  final List<AssetType> market;
  final Function(PortfolioItem) onTap;
  final Function(PortfolioItem, bool) onDelete;
  final Future<void> Function() onRefresh;
  final ValueChanged<int>? onTabChanged;

  const BorcAlacakPage({
    super.key,
    required this.debts,
    required this.credits,
    required this.market,
    required this.onTap,
    required this.onDelete,
    required this.onRefresh,
    this.onTabChanged,
  });

  @override
  State<BorcAlacakPage> createState() => _BorcAlacakPageState();
}

class _BorcAlacakPageState extends State<BorcAlacakPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    // Animasyon DEGERINI dinle -> renkler tab degisirken aninda guncellenir
    _tabCtrl.animation?.addListener(() {
      if (mounted) setState(() {});
    });
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        widget.onTabChanged?.call(_tabCtrl.index);
      }
    });
  }

  // Anlik aktif tab — animasyon sirasinda dahi anlik dogru deger
  int get _activeTab {
    final v = _tabCtrl.animation?.value ?? _tabCtrl.index.toDouble();
    return v.round();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sekme bari — pill/stadium tarzi segmented control
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color(0x33FFD700)),
          ),
          child: TabBar(
            controller: _tabCtrl,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFDAA520)],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.white70,
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            dividerColor: Colors.transparent,
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_down,
                        size: 18,
                        color: _activeTab == 0
                            ? Colors.black
                            : AppTheme.neonRed),
                    const SizedBox(width: 6),
                    const Text("BORÇ"),
                    const SizedBox(width: 6),
                    if (widget.debts.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? Colors.black26
                                : AppTheme.neonRed.withAlpha(60),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("${widget.debts.length}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 0
                                    ? Colors.black
                                    : AppTheme.neonRed)),
                      ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_circle_up,
                        size: 18,
                        color: _activeTab == 1
                            ? Colors.black
                            : AppTheme.neonGreen),
                    const SizedBox(width: 6),
                    const Text("ALACAK"),
                    const SizedBox(width: 6),
                    if (widget.credits.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? Colors.black26
                                : AppTheme.neonGreen.withAlpha(60),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text("${widget.credits.length}",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _activeTab == 1
                                    ? Colors.black
                                    : AppTheme.neonGreen)),
                      ),
                  ],
                ),
              ),
            ],
            onTap: (i) {
              widget.onTabChanged?.call(i);
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              ListingPage(
                items: widget.debts,
                market: widget.market,
                isCredit: false,
                onTap: widget.onTap,
                onDelete: (item) => widget.onDelete(item, false),
                onRefresh: widget.onRefresh,
              ),
              ListingPage(
                items: widget.credits,
                market: widget.market,
                isCredit: true,
                onTap: widget.onTap,
                onDelete: (item) => widget.onDelete(item, true),
                onRefresh: widget.onRefresh,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Add chooser bottom sheet — borç mu alacak mı diye sorar
void showAddChooserSheet(BuildContext context, void Function(bool isCredit) onPick) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (c) => Container(
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            const Text("YENİ KAYIT",
                style: TextStyle(
                    color: AppTheme.goldMain,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1.5)),
            const SizedBox(height: 6),
            const Text("Hangisini eklemek istiyorsun?",
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 22),
            // Borç ekle
            _ChooserCard(
              icon: Icons.arrow_circle_down,
              iconColor: AppTheme.neonRed,
              title: "BORÇ EKLE",
              subtitle: "Borçlu olduğun bir kayıt",
              onTap: () {
                Navigator.pop(c);
                onPick(false);
              },
            ),
            const SizedBox(height: 12),
            // Alacak ekle
            _ChooserCard(
              icon: Icons.arrow_circle_up,
              iconColor: AppTheme.neonGreen,
              title: "ALACAK EKLE",
              subtitle: "Alacaklı olduğun bir kayıt",
              onTap: () {
                Navigator.pop(c);
                onPick(true);
              },
            ),
          ],
        ),
      ),
    ),
  );
}

class _ChooserCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ChooserCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withAlpha(80), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: iconColor.withAlpha(28),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(28),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}


class ListingPage extends StatefulWidget {
  final List<PortfolioItem> items;
  final List<AssetType> market;
  final bool isCredit;
  final Function(PortfolioItem) onTap;
  final Function(PortfolioItem) onDelete;
  final Future<void> Function() onRefresh;

  const ListingPage(
      {super.key,
      required this.items,
      required this.market,
      required this.isCredit,
      required this.onTap,
      required this.onDelete,
      required this.onRefresh});

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  static final _currency =
      NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 0);
  String? _editingItemId;
  final Set<String> _collapsedItems = {};

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return RefreshIndicator(
        color: AppTheme.goldMain,
        backgroundColor: AppTheme.card,
        onRefresh: widget.onRefresh,
        child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Container(
                height: 500,
                alignment: Alignment.center,
                child: const Text("Kayıt Bulunamadı",
                    style: TextStyle(color: Colors.white24)))),
      );
    }
    final marketMap = {for (var a in widget.market) a.id: a};
    return GestureDetector(
      onTap: () => setState(() => _editingItemId = null),
      child: RefreshIndicator(
        color: AppTheme.goldMain,
        backgroundColor: AppTheme.card,
        onRefresh: widget.onRefresh,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: widget.items.length,
          itemBuilder: (c, i) {
            var item = widget.items[i];
            double val = item.getTotalValue(widget.market);
            bool isEditing = _editingItemId == item.id;
            bool isExpanded = !_collapsedItems.contains(item.id);

            return GestureDetector(
                onLongPress: () {
                  HapticFeedback.heavyImpact();
                  setState(() => _editingItemId = item.id);
                },
                onTap: () {
                  if (isEditing) {
                    setState(() => _editingItemId = null);
                  } else {
                    widget.onTap(item);
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                          color: AppTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border(
                              left: BorderSide(
                                  color: widget.isCredit
                                      ? AppTheme.neonGreen
                                      : AppTheme.neonRed,
                                  width: 3))),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: widget.isCredit
                                  ? const Color(0xFF122A15)
                                  : const Color(0xFF2A1215),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                      Text(item.personName,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis),
                                    ])),
                                const SizedBox(width: 10),
                                Text(_currency.format(val),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _collapsedItems.add(item.id);
                                      } else {
                                        _collapsedItems.remove(item.id);
                                      }
                                    });
                                  },
                                  child: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: Colors.white38,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isExpanded && item.assets.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16, right: 16, bottom: 14),
                              child: Builder(builder: (context) {
                                final assetEntries = item.assets.entries.toList();
                                return Column(
                                children: List.generate(assetEntries.length, (idx) {
                                  final entry = assetEntries[idx];
                                  final assetId = entry.key;
                                  final qty = entry.value;
                                  final asset = marketMap[assetId];
                                  if (asset == null) return const SizedBox.shrink();
                                  final assetVal = asset.sellPrice * qty;
                                  final isLast = idx == item.assets.length - 1;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            AssetCoin(type: asset, size: 30),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(asset.name,
                                                      style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.w500)),
                                                  const SizedBox(height: 2),
                                                  Text("x ${formatNumber(qty)} adet",
                                                      style: TextStyle(
                                                          color: const Color(0x59FFFFFF),
                                                          fontSize: 11)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(_currency.format(assetVal),
                                                style: TextStyle(
                                                    color: widget.isCredit
                                                        ? const Color(0xFF66BB6A)
                                                        : const Color(0xFFEF5350),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600)),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          color: const Color(0x0FFFFFFF),
                                          height: 1,
                                          thickness: 0.5,
                                        ),
                                    ],
                                  );
                                }),
                              );
                              }),
                            ),
                        ],
                      ),
                    ),
                    if (isEditing)
                      Positioned(
                          top: -10,
                          right: -5,
                          child: GestureDetector(
                              onTap: () => widget.onDelete(item),
                              child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: AppTheme.neonRed,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2)),
                                  child: const Icon(Icons.delete_forever,
                                      color: Colors.white, size: 20)))),
                  ],
                ),
            );
          },
        ),
      ),
    );
  }
}

class PortfolioCreator extends StatefulWidget {
  final bool isCredit;
  final List<AssetType> market;
  final Function(PortfolioItem) onSave;

  const PortfolioCreator(
      {super.key,
      required this.isCredit,
      required this.market,
      required this.onSave});

  @override
  State<PortfolioCreator> createState() => _PortfolioCreatorState();
}

class _PortfolioCreatorState extends State<PortfolioCreator> {
  static final _currency =
      NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 0);
  final _nameCtrl = TextEditingController();
  final Map<String, double> _liveAssets = {};

  /// Sayi'ya tiklayinca acilan dialog — mevcut miktari duzenler
  void _editQuantityDialog(AssetType asset) {
    final current = _liveAssets[asset.id] ?? 0;
    final qtyCtrl = TextEditingController(
        text: current > 0 ? formatNumber(current) : "");
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: Text("${asset.name} Miktarı",
            style: const TextStyle(color: Colors.white)),
        content: TextField(
            controller: qtyCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                hintText: "Yeni miktar...",
                hintStyle: TextStyle(color: Colors.grey))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text("İPTAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldMain,
                foregroundColor: Colors.black),
            onPressed: () {
              final val =
                  double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
              if (val != null && val > 0) {
                setState(() => _liveAssets[asset.id] = val);
              } else if (val != null && val == 0) {
                setState(() => _liveAssets.remove(asset.id));
              }
              Navigator.pop(c);
            },
            child: const Text("KAYDET"),
          )
        ],
      ),
    );
  }

  void _updateQuantity(AssetType asset) {
    if (asset.manualInput) {
      showDialog(
        context: context,
        builder: (c) {
          TextEditingController qtyCtrl = TextEditingController();
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text("${asset.name} Miktarı",
                style: const TextStyle(color: Colors.white)),
            content: TextField(
                controller: qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                    hintText: "Miktar giriniz...",
                    hintStyle: TextStyle(color: Colors.grey))),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("İPTAL")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldMain,
                    foregroundColor: Colors.black),
                onPressed: () {
                  double? val =
                      double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
                  if (val != null && val > 0) {
                    setState(() => _liveAssets[asset.id] = val);
                  }
                  Navigator.pop(c);
                },
                child: const Text("EKLE"),
              )
            ],
          );
        },
      );
    } else {
      setState(() => _liveAssets[asset.id] = (_liveAssets[asset.id] ?? 0) + 1);
    }
  }

  void _save() {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Lütfen bir isim giriniz!"),
          backgroundColor: AppTheme.neonRed));
      return;
    }
    if (_liveAssets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Lütfen en az bir varlık seçiniz."),
          backgroundColor: Colors.grey));
      return;
    }
    widget.onSave(PortfolioItem(
        id: DateTime.now().toString(),
        personName: _nameCtrl.text,
        isCredit: widget.isCredit,
        assets: _liveAssets,
        date: DateTime.now()));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final marketMap = {for (var a in widget.market) a.id: a};
    double liveTotal = 0;
    _liveAssets.forEach((k, v) {
      var asset = marketMap[k];
      if (asset != null) liveTotal += asset.sellPrice * v;
    });

    return Scaffold(
      appBar: AppBar(
          title: Text(widget.isCredit ? "ALACAK OLUŞTUR" : "BORÇ OLUŞTUR")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                    labelText: "Kişi/Kurum Adı (Zorunlu)",
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none))),
          ),
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.market.length,
              itemBuilder: (c, i) {
                var asset = widget.market[i];
                if (asset.sellPrice <= 0 && !asset.isDollarBase)
                  return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () => _updateQuantity(asset),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    width: 64,
                    decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AssetCoin(type: asset, size: 26),
                        const SizedBox(height: 4),
                        Text(asset.label,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11)),
                        Text(asset.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 7),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white24, size: 12),
                SizedBox(width: 2),
                Text("kaydır",
                    style: TextStyle(color: Colors.white24, fontSize: 10)),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 30),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: _liveAssets.length,
              itemBuilder: (c, i) {
                String id = _liveAssets.keys.elementAt(i);
                double qty = _liveAssets[id]!;
                var asset = marketMap[id];
                if (asset == null) return const SizedBox.shrink();
                return Container(
                  margin:
                      const EdgeInsets.only(bottom: 10, left: 16, right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      AssetCoin(type: asset, size: 40),
                      const SizedBox(width: 15),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(asset.name,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 2),
                            Text(_currency.format(qty * asset.sellPrice),
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13))
                          ])),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.neonRed),
                              onPressed: () {
                                setState(() {
                                  if (qty > 1) {
                                    _liveAssets[id] = qty - 1;
                                  } else {
                                    _liveAssets.remove(id);
                                  }
                                });
                              }),
                          const SizedBox(width: 8),
                          GestureDetector(
                              onTap: () => _editQuantityDialog(asset),
                              child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppTheme.goldMain
                                              .withAlpha(80),
                                          width: 1)),
                                  child: Text(formatNumber(qty),
                                      style: const TextStyle(
                                          color: AppTheme.goldMain,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)))),
                          const SizedBox(width: 8),
                          IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              icon: const Icon(Icons.add_circle_outline,
                                  color: AppTheme.neonGreen),
                              onPressed: () {
                                setState(() {
                                  _liveAssets[id] = qty + 1;
                                });
                              }),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.card,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("TOPLAM DEĞER",
                      style: TextStyle(color: Colors.grey, fontSize: 10)),
                  Text(_currency.format(liveTotal),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))
                ]),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldMain,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12)),
                    onPressed: _save,
                    child: const Text("KAYDET",
                        style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class PortfolioDetail extends StatefulWidget {
  final PortfolioItem item;
  final List<AssetType> market;
  final VoidCallback onUpdate;
  final bool isWallet;
  final Future<void> Function() onRefresh;
  final Function(AssetType) onAssetTap;

  const PortfolioDetail(
      {super.key,
      required this.item,
      required this.market,
      required this.onUpdate,
      this.isWallet = false,
      required this.onRefresh,
      required this.onAssetTap});

  @override
  State<PortfolioDetail> createState() => _PortfolioDetailState();
}

class _PortfolioDetailState extends State<PortfolioDetail> {
  static final _currency =
      NumberFormat.currency(locale: "tr_TR", symbol: "₺", decimalDigits: 0);
  String? _deletingAssetId;

  void _addAssetDialog(AssetType asset) {
    if (asset.manualInput) {
      showDialog(
        context: context,
        builder: (c) {
          TextEditingController qtyCtrl = TextEditingController();
          return AlertDialog(
            backgroundColor: AppTheme.card,
            title: Text("${asset.name} Ekle",
                style: const TextStyle(color: Colors.white)),
            content: TextField(
                controller: qtyCtrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(hintText: "Miktar")),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: const Text("İPTAL")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.goldMain,
                    foregroundColor: Colors.black),
                onPressed: () {
                  double? val =
                      double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
                  if (val != null) {
                    setState(() => widget.item.assets[asset.id] =
                        (widget.item.assets[asset.id] ?? 0) + val);
                    widget.onUpdate();
                  }
                  Navigator.pop(c);
                  Navigator.pop(context);
                },
                child: const Text("EKLE"),
              )
            ],
          );
        },
      );
    } else {
      setState(() => widget.item.assets[asset.id] =
          (widget.item.assets[asset.id] ?? 0) + 1);
      widget.onUpdate();
      Navigator.pop(context);
    }
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
            color: AppTheme.bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10))),
            const SizedBox(height: 20),
            const Text("KASAYA VARLIK EKLE",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2)),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                itemCount: widget.market.length,
                itemBuilder: (c, i) {
                  var g = widget.market[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0x66000000),
                              blurRadius: 10,
                              offset: const Offset(0, 5))
                        ]),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: AssetCoin(type: g, size: 40),
                      title: Text(g.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      subtitle: Text(
                          "Canlı: ${NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0).format(g.sellPrice)}",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12)),
                      trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: const Color(0x26FFD700),
                              shape: BoxShape.circle),
                          child: const Icon(Icons.add,
                              color: AppTheme.goldMain, size: 22)),
                      onTap: () => _addAssetDialog(g),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteAsset(String assetId) {
    HapticFeedback.heavyImpact();
    setState(() => _deletingAssetId = assetId);
  }

  void _editQuantity(String assetId, double currentQty) {
    TextEditingController qtyCtrl =
        TextEditingController(text: formatNumber(currentQty));
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text("Miktarı Düzenle",
            style: TextStyle(color: Colors.white)),
        content: TextField(
            controller: qtyCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: "Yeni miktar")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c), child: const Text("İPTAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.goldMain,
                foregroundColor: Colors.black),
            onPressed: () {
              double? val = double.tryParse(qtyCtrl.text.replaceAll(',', '.'));
              if (val != null) {
                setState(() => widget.item.assets[assetId] = val);
                widget.onUpdate();
              }
              Navigator.pop(c);
            },
            child: const Text("KAYDET"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marketMap = {for (var a in widget.market) a.id: a};
    double total = widget.item.getTotalValue(widget.market);

    return Scaffold(
      appBar:
          widget.isWallet ? null : AppBar(title: Text(widget.item.personName)),
      body: RefreshIndicator(
        color: AppTheme.goldMain,
        backgroundColor: AppTheme.card,
        onRefresh: widget.onRefresh,
        child: Column(
          children: [
            if (widget.isWallet) const SizedBox(height: 10),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppTheme.goldMain, AppTheme.goldDim]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x66FFA000),
                        blurRadius: 20)
                  ]),
              child: Column(children: [
                Text(widget.isWallet ? "MEVCUT VARLIK" : "GÜNCEL DEĞER",
                    style: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(_currency.format(total),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.w900))
              ]),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: widget.item.assets.length,
                itemBuilder: (c, i) {
                  String id = widget.item.assets.keys.elementAt(i);
                  double qty = widget.item.assets[id]!;
                  var asset = marketMap[id] ??
                      AssetType("0", [], "?", "?", 0.0, 0.0, "gold");
                  // Kasa: kuyumcu alış (sende varsa satarsın), Borç/Alacak: kuyumcu satış
                  double itemPrice =
                      widget.isWallet ? asset.buyPrice : asset.sellPrice;

                  bool isDeleting = _deletingAssetId == id;

                  Widget assetTile = GestureDetector(
                    onLongPress: () => _confirmDeleteAsset(id),
                    onTap: () {
                      if (isDeleting) {
                        setState(() => _deletingAssetId = null);
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                              color: AppTheme.card,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: const Color(0x0AFFFFFF))),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AssetCoin(type: asset),
                              const SizedBox(width: 12),
                              // Metin alani — sabit genisilikte (Expanded)
                              // Uzun isim ellipsis ile kesilir, butonlar sabit kalir
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => widget.onAssetTap(asset),
                                  behavior: HitTestBehavior.opaque,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(asset.name,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                height: 1.15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: false),
                                        const SizedBox(height: 3),
                                        Text(
                                            _currency.format(qty * itemPrice),
                                            style: TextStyle(
                                                color: widget.isWallet
                                                    ? Colors.grey
                                                    : (widget.item.isCredit
                                                        ? const Color(0xFF66BB6A)
                                                        : const Color(0xFFEF5350)),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                height: 1.0),
                                            maxLines: 1,
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ]),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: AppTheme.neonRed),
                                      onPressed: () {
                                        setState(() {
                                          if (qty > 1) {
                                            widget.item.assets[id] = qty - 1;
                                          } else {
                                            widget.item.assets.remove(id);
                                          }
                                        });
                                        widget.onUpdate();
                                      }),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                      onTap: () => _editQuantity(id, qty),
                                      child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: Colors.black45,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          child: Text(formatNumber(qty),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.bold)))),
                                  const SizedBox(width: 8),
                                  IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      iconSize: 20,
                                      icon: const Icon(
                                          Icons.add_circle_outline,
                                          color: AppTheme.neonGreen),
                                      onPressed: () {
                                        setState(() {
                                          widget.item.assets[id] = qty + 1;
                                        });
                                        widget.onUpdate();
                                      }),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (isDeleting)
                          Positioned(
                              top: -8,
                              right: -5,
                              child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _deletingAssetId = null;
                                      widget.item.assets.remove(id);
                                    });
                                    widget.onUpdate();
                                  },
                                  child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                          color: AppTheme.neonRed,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2)),
                                      child: const Icon(Icons.delete_forever,
                                          color: Colors.white, size: 18)))),
                      ],
                    ),
                  );

                  // Kasa (wallet) PageView içinde: sadece long-press ile sil
                  // Alacak/Borç detayı: swipe da kalsın
                  if (widget.isWallet) {
                    return assetTile;
                  }
                  return Dismissible(
                    key: Key(id),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                            color: AppTheme.neonRed,
                            borderRadius: BorderRadius.circular(12)),
                        child:
                            const Icon(Icons.delete, color: Colors.white)),
                    onDismissed: (d) {
                      setState(() => widget.item.assets.remove(id));
                      widget.onUpdate();
                    },
                    child: assetTile,
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.card,
          onPressed: _showAddMenu,
          child: const Icon(Icons.add, color: AppTheme.goldMain)),
    );
  }
}
