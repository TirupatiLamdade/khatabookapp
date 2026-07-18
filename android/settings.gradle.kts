pluginManagement {
    val r = providers.gradleProperty("flutter.sdk")
    val flutterSdkPath = if (r.isPresent) r.get() else System.getenv("FLUTTER_ROOT")
    if (flutterSdkPath == null) {
        throw GradleException("Flutter SDK not found. Define location with flutter.sdk in local.properties or with FLUTTER_ROOT environment variable.")
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("dev.flutter.flutter-gradle-plugin") version "1.0.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}
dependencyResolutionManagement {
    repositoriesMode.set(org.gradle.api.initialization.resolve.RepositoriesMode.PREFER_SETTINGS)
    repositories {
        google()
        mavenCentral()
        // ही खालील ओळ नवीन जोडा, ज्यामुळे फ्लटरच्या फाईल्स मिळतील:
        maven { url = uri("https://storage.googleapis.com/download.flutter.io") }
    }
}

include(":app")