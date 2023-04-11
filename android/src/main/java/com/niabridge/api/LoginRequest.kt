package com.niabridge.api

import com.google.gson.annotations.SerializedName
import com.ndt.ggmobileclient.CryptoTools

class LoginRequest : BaseRequest {
    @SerializedName("Credentials")
    val Credentials: Credentials
    @SerializedName("SessionID")
    val SessionID: String
    @SerializedName("Signature")
    val Signature: String

    constructor(cred: Credentials, sid: String, protocolVersion: String, appInfo: ApplicationInfo, privateKeyB64: String)
            :super(protocolVersion, appInfo)
    {
        Credentials = cred
        SessionID = sid

        val sData = Credentials.ApplicationId + Credentials.Otp + Credentials.PartitionId.toString() + SessionID
        Signature = CryptoTools.sign(sData, privateKeyB64)
    }
}
