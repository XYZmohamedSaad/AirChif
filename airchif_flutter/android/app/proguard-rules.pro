# Keep Flutter and AndroidX classes
-keep class io.flutter.embedding.** { *; }
-keep class androidx.lifecycle.** { *; }
-keep class com.google.android.play.core.** { *; }
-keep class com.google.crypto.tink.** { *; }
-keep class com.google.api.client.** { *; }
-keep class org.joda.time.** { *; }

# Keep annotations used by libraries
-keep @interface com.google.errorprone.annotations.*
-keep @interface javax.annotation.*
-keep @interface javax.annotation.concurrent.*

# Don't warn about missing classes
-dontwarn com.google.android.play.core.**
-dontwarn com.google.crypto.tink.**
-dontwarn com.google.api.client.**
-dontwarn org.joda.time.**
-dontwarn javax.annotation.**
-dontwarn com.google.errorprone.annotations.**

# Flutter Secure Storage + HTTP
-keep class io.flutter.plugins.fluttersecurestorage.** { *; }
-keep class com.squareup.okhttp3.** { *; }
-keep class com.google.gson.** { *; }
