package com.niabridge

import java.net.URLEncoder

class ConstantFunctions {
    companion object {
        private const val GgRealm: String = "urn:nia:demo:android:1@mobile" // for interactive login by embedded browser
        val SpRealm: String = "urn:nia:demo:android:1" // for API

        fun InteractiveLoginUrl(envName: String): String {
            return "${Constants.FederationProviderUrl(envName)}?response_type=code&scope=openid&client_id=${
                URLEncoder.encode(
                    GgRealm,
                    "utf-8"
                )
            }&redirect_uri=${URLEncoder.encode(Constants.ReplyUrl, "utf-8")}"
        }

        val AppName: String = "GGMobileApp1"
        val ApiTestPath: String = "/mobilebackend1/token/GetAttributes"
    }
}
