import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

// १. मुख्य बिल्ड डिरेक्टरीचा पाथ बदलणे
val newBuildDir: Directory = rootProject.layout.buildDirectory
    .dir("../../build")
    .get()

rootProject.layout.buildDirectory.value(newBuildDir)

// २. सर्व सब-प्रोजेक्ट्ससाठी बिल्ड डिरेक्टरी सेट करणे
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ३. 'clean' टास्क दुरुस्त करणे (इथे .get() जोडले आहे)
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory.get())
}