package com.niabridge.api

import com.google.gson.annotations.SerializedName

class RegisterResponse : BaseResponse {
    @SerializedName("ApplicationId")
    val ApplicationId: String
    @SerializedName("OtpSecret")
    val OtpSecret: String
    @SerializedName("PartitionId")
    val PartitionId: Int

    constructor(aid: String, otpSec: String, pid: Int, ec: Int)
            :super(ec)
    {
        ApplicationId = aid
        OtpSecret = otpSec
        PartitionId = pid
    }
}
