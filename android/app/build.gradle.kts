plugins {
    id("com.android.application") version "8.5.2"
}

android {
    namespace = "com.example.android"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.android"
        minSdk = 21
        targetSdk = 33
        versionCode = 1
        versionName = "1.0"
    }

    sourceSets {
        getByName("main").manifest.srcFile("src/main/AndroidManifest.xml")
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

dependencies {
    implementation(libs.retrofit)
    implementation(libs.converter.gson)
    implementation(libs.lifecycle.viewmodel)
    implementation(libs.lifecycle.livedata)
    implementation(libs.appcompat.v141)
    implementation(libs.material.v190)
}
