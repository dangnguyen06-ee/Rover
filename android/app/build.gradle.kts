plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}
 
android {
    namespace = "com.example.vision_sandbox"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
 
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
 
    defaultConfig {
        applicationId = "com.example.vision_sandbox"
        // MediaPipe Tasks requires API 24+. Overriding flutter.minSdkVersion
        // (which defaults lower) explicitly here.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
 
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
 
kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}
 
dependencies {
    // MediaPipe's Gesture Recognizer task, plus the CameraX pieces our
    // native platform view needs to show a live preview and pull frames.
    // "latest.release" is what Google's own docs recommend for this
    // library, since pinning an exact version tends to go stale fast.
    implementation("com.google.mediapipe:tasks-vision:latest.release")
    implementation("androidx.camera:camera-core:1.3.4")
    implementation("androidx.camera:camera-camera2:1.3.4")
    implementation("androidx.camera:camera-lifecycle:1.3.4")
    implementation("androidx.camera:camera-view:1.3.4")
}
 
flutter {
    source = "../.."
}