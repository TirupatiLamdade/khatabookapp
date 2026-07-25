plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.login_setup"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.login_setup"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // 🟢 १. Release Signing Config जोडा
    signingConfigs {
        create("release") {
            // जर तुम्ही .jks फाईल android/app/ फोल्डरमध्ये ठेवली असेल:
            storeFile = file("my-release-key.jks") // तुमच्या .jks फाईलचे नाव
            storePassword = "YOUR_STORE_PASSWORD"   // तुमचा Store Password
            keyAlias = "YOUR_KEY_ALIAS"             // तुमचा Key Alias
            keyPassword = "YOUR_KEY_PASSWORD"       // तुमचा Key Password
        }
    }

    buildTypes {
        release {
            // 🟢 २. इथे "debug" ऐवजी "release" साइनिंग कॉन्फिग वापरा
            signingConfig = signingConfigs.getByName("release")
            
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}