# Flutter / engine plumbing.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Firebase + Google Play Services use reflection for model classes.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# google_generative_ai / OkHttp transport.
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }

# flutter_local_notifications gson types.
-keep class com.dexterous.** { *; }

# Required by url_launcher on some OEMs that strip Intent handler metadata.
-keep class androidx.browser.** { *; }

# Standard JSR-305 + Kotlin metadata.
-dontwarn javax.annotation.**
-keep class kotlin.Metadata { *; }
