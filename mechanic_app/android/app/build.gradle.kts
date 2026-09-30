import com.google.firebase.crashlytics.buildtools.gradle.CrashlyticsExtension
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    // #120: Firebase config per flavour, and the build ID Crashlytics needs to start.
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}

// google-services.json per flavour (src/dev/, src/prod/) is git-ignored (PLAN §12.8). Without
// it (CI, a fresh checkout) the build still works and the app runs on its in-memory fakes.
googleServices {
    missingGoogleServicesStrategy =
        com.google.gms.googleservices.GoogleServicesPlugin.MissingGoogleServicesStrategy.WARN
}

// Upload key for Play (PLAN §12.7). Restored from secrets by release-android.yml; never in git.
val keyProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}

android {
    namespace = "com.roadside.mechanic_app"
    compileSdk = maxOf(flutter.compileSdkVersion, 36)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // flutter_local_notifications (M4 offers) needs core library desugaring.
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // Placeholder until the client confirms the app name and package (HANDOFF §4.6).
        // Firebase apps (the mechanic Firebase wiring issue) are registered against this id, so settle it before then.
        applicationId = "com.roadside.mechanic"
        minSdk = 24 // PLAN §3
        targetSdk = 36 // Android 16, required for Play from 31 Aug 2026 (PLAN §13)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "env"
    productFlavors {
        // `flutter run --flavor dev -t lib/main_dev.dart`: installs next to prod.
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            manifestPlaceholders["appName"] = "Roadside Mechanic Dev"
        }
        create("prod") {
            dimension = "env"
            manifestPlaceholders["appName"] = "Roadside Mechanic"
        }
    }

    signingConfigs {
        if (keyProperties.isNotEmpty()) {
            create("upload") {
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Local `flutter run --release` falls back to the debug key; CI release builds
            // always have key.properties.
            signingConfig = signingConfigs.findByName("upload") ?: signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            // The R8 mapping goes to Crashlytics only when the prod project is configured.
            configure<CrashlyticsExtension> {
                mappingFileUploadEnabled = file("src/prod/google-services.json").exists()
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
