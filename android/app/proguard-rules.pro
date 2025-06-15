# ===============================
# Google ML Kit and Firebase
# ===============================

# Keep all ML Kit classes
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Specifically for ML Kit Text Recognition
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.mlkit.common.** { *; }

# Google Tasks (used by ML Kit)
-keep class com.google.android.gms.tasks.** { *; }

# ===============================
# TensorFlow Lite (used internally)
# ===============================

-keep class org.tensorflow.** { *; }
-dontwarn org.tensorflow.**

# TensorFlow Lite GPU delegate
-keep class org.tensorflow.lite.gpu.** { *; }

# ===============================
# Kotlin & Multidex (safety for obfuscation)
# ===============================

-keep class kotlin.Metadata { *; }
-keep class androidx.multidex.** { *; }
-dontwarn androidx.multidex.**

# Optional: keep Flutter plugin registrant (safe fallback)
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**
