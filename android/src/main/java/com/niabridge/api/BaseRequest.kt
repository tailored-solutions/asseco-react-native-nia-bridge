package com.niabridge.api

import com.google.gson.annotations.SerializedName

open class BaseRequest(
    @SerializedName("ProtocolVersion")
    val ProtocolVersion : String,
    @SerializedName("Application")
    val Application: ApplicationInfo
)
