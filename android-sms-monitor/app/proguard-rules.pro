# Add project specific ProGuard rules here.
-keep class com.bdpayx.smsmonitor.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
