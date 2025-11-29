allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Esta línea suele venir por defecto, NO LA BORRES si tiene números (ej. 8.0.0)
        // Si copiaste la mía que tenía "...", BÓRRALA.
        classpath("com.android.tools.build:gradle:8.2.1") // (El número puede variar, deja el que estaba)
        
        // AGREGA ESTA LÍNEA ASÍ:
        classpath("com.google.gms:google-services:4.3.15")
    }
}

dependencies {
    

}
