plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
}

android {
    compileSdk = 34
    defaultConfig {
        applicationId = "com.example.book_management_app_2"
        minSdkVersion = 21
        targetSdkVersion = 34
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.debug
        }
    }
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.0")
}