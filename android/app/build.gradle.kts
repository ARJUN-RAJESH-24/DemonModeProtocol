plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter plugin must always be last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.demon_mode"

    // Modern SDK
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.demon_mode"

        minSdk = flutter.minSdkVersion
        targetSdk = 34

        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["redirectSchemeName"] = "demonmode"
        manifestPlaceholders["redirectHostName"] = "callback"
    }

    // Java/Kotlin modernization

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    


    buildTypes {
        release {
            // Replace with your release keystore later
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Enable/Improve build performance
    packaging {
        resources {
            excludes += setOf(
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

flutter {
    source = "../.."
}


tasks.withType<JavaCompile> {
    options.compilerArgs.add("-Xlint:-options")
}
