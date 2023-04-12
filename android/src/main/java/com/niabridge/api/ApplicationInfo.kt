package com.niabridge.api

import com.google.gson.annotations.SerializedName
import com.niabridge.ConstantFunctions
import com.niabridge.Constants

class ApplicationInfo {
    @SerializedName("ApplicationName")
    var ApplicationName : String
    @SerializedName("ApplicationVersion")
    var ApplicationVersion : String
    @SerializedName("MobileOs")
    var MobileOs : String
    @SerializedName("MobileOsVersion")
    var MobileOsVersion : String
    @SerializedName("Maker")
    var Maker : String
    @SerializedName("Model")
    var Model : String
    @SerializedName("SpRealm")
    var SpRealm : String

    constructor(destination: String) {
        ApplicationName = ConstantFunctions.AppName
        ApplicationVersion = Constants.AppVersion
        SpRealm =  destination
        MobileOs = "Android"
        MobileOsVersion = android.os.Build.VERSION.RELEASE
        Model = android.os.Build.MODEL
        Maker = android.os.Build.MANUFACTURER
    }
}
