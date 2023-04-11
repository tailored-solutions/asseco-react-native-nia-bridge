package com.niabridge.api

import com.google.gson.annotations.SerializedName
import java.util.*

class EnvelopeResponse: EnvelopeBase {
    @SerializedName("ServerTimeUtc")
    val ServerTimeUtc: Date

    constructor( ev: String, data: String, key: String,  serverTimeUtc: Date)
        :super(ev, data, key)
    {
            ServerTimeUtc = serverTimeUtc
    }
}
