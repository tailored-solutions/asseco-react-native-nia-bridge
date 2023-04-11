package com.niabridge.api

import com.google.gson.annotations.SerializedName

class LoginResponse : BaseResponse {
    @SerializedName("InResponseTo")
    val InResponseTo: String
    @SerializedName("AccessToken")
    val AccessToken: String

    constructor(irt: String, at: String, ec: Int)
            :super(ec)
    {
        InResponseTo = irt
        AccessToken = at
    }
}
