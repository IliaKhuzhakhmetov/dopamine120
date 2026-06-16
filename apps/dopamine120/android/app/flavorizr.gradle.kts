import com.android.build.gradle.AppExtension

val android = project.extensions.getByType(AppExtension::class.java)

android.apply {
    flavorDimensions("flavor-type")

    productFlavors {
        create("dev") {
            dimension = "flavor-type"
            applicationId = "com.example.dopamine120.dev"
            resValue(type = "string", name = "app_name", value = "DOPAMINE120 Dev")
        }
        create("prod") {
            dimension = "flavor-type"
            applicationId = "com.example.dopamine120"
            resValue(type = "string", name = "app_name", value = "DOPAMINE120")
        }
    }

    buildFeatures.resValues = true
}