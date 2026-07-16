plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

// Create a function to load the .env file
fun getEnvProperty(key: String): String {
    val envFile = rootProject.file(".env")
    if (envFile.exists()) {
        val properties = Properties()
        properties.load(envFile.inputStream())
        return properties.getProperty(key) ?: ""
    }
    return ""
}

android {
    namespace = "com.example.geo_mugger"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.geo_mugger"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        
        val apiKey = getEnvProperty("MY_API_KEY")
        
        // Pass it to Java/Kotlin code
        buildConfigField("String", "MY_API_KEY", "\"$apiKey\"")
        
        // Pass it to Manifest (if needed)
        manifestPlaceholders["apiKey"] = apiKey

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}


kotlin {
    compilerOptions {
        jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
    }
}




flutter {
    source = "../.."
}
