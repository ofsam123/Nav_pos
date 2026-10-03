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
// Older plugins pin compileSdk 33, but their AndroidX dependencies need 34+.
// Not raised further: package_info_plus 4.x fails to compile against 35+.
subprojects {
    val raiseCompileSdk: Project.() -> Unit = {
        val android = extensions.findByName("android")
        if (android != null && plugins.hasPlugin("com.android.library")) {
            val methods = android.javaClass.methods
            val current = methods.firstOrNull { it.name == "getCompileSdkVersion" && it.parameterCount == 0 }
                ?.invoke(android)?.toString()?.filter { it.isDigit() }?.toIntOrNull()
            if (current == null || current < 34) {
                methods.firstOrNull {
                    it.name == "compileSdkVersion" &&
                        it.parameterTypes.contentEquals(arrayOf(Int::class.javaPrimitiveType))
                }?.invoke(android, 34)
            }
        }
    }
    if (state.executed) raiseCompileSdk() else afterEvaluate { raiseCompileSdk() }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
