import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load the Flutter project's `.env` at configure time so that the App Links host
// declared in AndroidManifest stays in sync with SURVEY_FRONTEND_BASE_URL_<ENV>.
val dotenv = Properties().apply {
    val envFile = rootProject.file("../.env")
    if (envFile.exists()) {
        FileInputStream(envFile).use { load(it) }
    }
}

fun envHost(key: String, fallback: String): String {
    val raw = dotenv.getProperty(key)?.trim().orEmpty()
    if (raw.isEmpty()) return fallback
    return raw
        .removePrefix("https://")
        .removePrefix("http://")
        .substringBefore('/')
        .substringBefore(':')
}

android {
    namespace = "com.rs4it.king_abdulaziz_center_survey_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.rs4it.king_abdulaziz_center_survey_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["deepLinkHost"] =
                envHost("SURVEY_FRONTEND_BASE_URL_DEV", "survey-front-internal.system2030.com")
            manifestPlaceholders["appLabelSuffix"] = " Dev"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".staging"
            versionNameSuffix = "-staging"
            manifestPlaceholders["deepLinkHost"] =
                envHost("SURVEY_FRONTEND_BASE_URL_STAGING", "survey-front-internal.system2030.com")
            manifestPlaceholders["appLabelSuffix"] = " Staging"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["deepLinkHost"] =
                envHost("SURVEY_FRONTEND_BASE_URL_PROD", "survey-frontend.system2030.com")
            manifestPlaceholders["appLabelSuffix"] = ""
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.3")
    implementation("androidx.security:security-crypto:1.1.0-alpha06")
}
