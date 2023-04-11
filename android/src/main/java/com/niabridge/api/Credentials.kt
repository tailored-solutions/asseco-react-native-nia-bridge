package com.niabridge.api

import com.google.gson.annotations.SerializedName

class Credentials {
    @SerializedName("ApplicationId")
    var ApplicationId : String
    @SerializedName("Otp")
    var Otp : String
    @SerializedName("PartitionId")
    var PartitionId : Int

    constructor(appId :String, otp : String, pid: Int) {
        ApplicationId = appId
        Otp = otp
        PartitionId = pid
    }
}
