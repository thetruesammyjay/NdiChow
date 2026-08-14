import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(FileInputStream(localPropertiesFile))
}

val flutterVersionCode = localProperties.getProperty("flutter.versionCode")?.toIntOrNull() ?: 1
val flutterVersionName = localProperties.getProperty("flutter.versionName") ?: "1.0"
val releaseSigningKeys = listOf(
    "MYAPP_UPLOAD_KEY_ALIAS",
    "MYAPP_UPLOAD_KEY_PASSWORD",
    "MYAPP_UPLOAD_STORE_FILE",
    "MYAPP_UPLOAD_STORE_PASSWORD",
)
val hasReleaseSigning = releaseSigningKeys.all {
    !localProperties.getProperty(it).isNullOrBlank()
}

android {
    namespace = "com.thetruesammyjay.ndichow"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = localProperties.getProperty("MYAPP_UPLOAD_KEY_ALIAS")
                keyPassword = localProperties.getProperty("MYAPP_UPLOAD_KEY_PASSWORD")
                storeFile = file(localProperties.getProperty("MYAPP_UPLOAD_STORE_FILE"))
                storePassword = localProperties.getProperty("MYAPP_UPLOAD_STORE_PASSWORD")
            }
        }
    }

    defaultConfig {
        applicationId = "com.thetruesammyjay.ndichow"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isShrinkResources = true
            isMinifyEnabled = true
        }
    }
}

flutter {
    source = "../.."
}
