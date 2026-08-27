# R8 / ProGuard kurallari — release derlemesinde isMinifyEnabled ile devreye girer.
#
# Buradaki kurallar SAVUNMA amaclidir: R8 kullanilmadigini sandigi sinifi atar,
# ama Flutter eklentileri siniflari YANSIMAYLA (reflection) buldugu icin R8 bunu
# goremez. Atilan sinif derlemede degil, CALISMA ANINDA ClassNotFoundException
# olarak patlar. O yuzden her kural silinmeden once gercek cihazda denenmelidir.

# ── Flutter motoru ve eklenti kayit mekanizmasi ──
# GeneratedPluginRegistrant eklentileri isimle yansimayla cagirir.
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── local_auth (androidx.biometric) ──
# Biyometrik dogrulama Fragment uzerinden calisiyor; FragmentManager
# fragment'lari sinif adiyla yeniden olusturur.
-keep class androidx.biometric.** { *; }
-keep class androidx.fragment.app.** { *; }

# ── Play Core ──
# Flutter'in varsayilan kurallari deferred component sinislarina atifta bulunur.
# Bu uygulama deferred component KULLANMIYOR, siniflar da pakette yok; uyariyi
# susturmazsak R8 "missing class" diye derlemeyi durdurur.
-dontwarn com.google.android.play.core.**

# ── Uygulamanin kendi giris noktasi ──
-keep class com.drksistem.altinasistanim.MainActivity { *; }
