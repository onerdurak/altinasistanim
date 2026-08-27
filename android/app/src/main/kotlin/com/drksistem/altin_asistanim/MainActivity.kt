package com.drksistem.altinasistanim

import android.graphics.Color
import android.os.Bundle
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Modern edge-to-edge: status ve navigation bar'i seffaf yapar.
        //
        // Burada VAKTIYLE bir de WindowCompat.setDecorFitsSystemWindows(window,
        // false) cagrisi vardi. Ikisi birden gereksizdi: enableEdgeToEdge zaten
        // ayni isi yapiyor. Ustelik setDecorFitsSystemWindows artik desteklenmiyor
        // ve Play Console "desteklenmeyen API" uyarisi veriyordu. Geri EKLEME.
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.auto(
                Color.TRANSPARENT,
                Color.TRANSPARENT
            ),
            navigationBarStyle = SystemBarStyle.auto(
                Color.TRANSPARENT,
                Color.TRANSPARENT
            )
        )
        super.onCreate(savedInstanceState)
    }
}
