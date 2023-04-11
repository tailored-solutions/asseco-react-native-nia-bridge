package com.niabridge.api

import com.google.gson.annotations.SerializedName

open class EnvelopeBase {
    @SerializedName("EnvelopeVersion")
    val EnvelopeVersion: String
    @SerializedName("Data")
    val Data: String
    @SerializedName("Key")
    val Key: String

    constructor( ev: String, data: String, key: String)
    {
        EnvelopeVersion = ev
        Data = data
        Key = key
    }
}
