package com.niabridge.api

import com.google.gson.annotations.SerializedName

class RegisterRequest : BaseRequest {
    @SerializedName("AccessToken")
    val AccessToken: String
    @SerializedName("SessionID")
    val SessionID: String
    @SerializedName("ApplicationPublicKey")
    val ApplicationPublicKey: String

    constructor(accessToken: String, protocolVersion: String, appInfo: ApplicationInfo, applicationPublicKey: String)
        :super(protocolVersion, appInfo)
    {
        AccessToken = accessToken
        SessionID = ""
        ApplicationPublicKey = applicationPublicKey
    }
}
