package com.niabridge.api

import com.google.gson.annotations.SerializedName

open class BaseResponse (
    @SerializedName("ErrorCode")
    val ErrorCode: Int
)
