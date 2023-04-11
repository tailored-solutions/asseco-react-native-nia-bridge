package com.niabridge

import dev.turingcomplete.kotlinonetimepassword.HmacAlgorithm
import dev.turingcomplete.kotlinonetimepassword.TimeBasedOneTimePasswordConfig
import java.util.concurrent.TimeUnit

class Constants {

  companion object {

    fun FederationProviderUrl(envName: String): String {
      return when (envName) {
        "NIA TEST" -> "https://tnia.eidentita.cz/FPSTS/oauth2/authorize"
        else -> "https://unsupported.profile"
      }
    }

    fun BackendUrl(envName: String): String {
      return when (envName) {
        "NIA TEST" -> "https://tnia.identitaobcana.cz"
        else -> "https://unsupported.profile"
      }
    }

    val ReplyUrl: String = "https://mobile.login"
    // sample: "https://dev.government-gateway.net/FPSTS/oauth2/authorize?response_type=code&scope=openid&client_id=urn%3Acgg%3Ademo%3Aandroid%40mobile&redirect_uri=https%3A%2F%2Fmobile.login"

    val EnvelopVersion: String = "1.0"
    val ProtocolVersion: String = "1.0"

    val AccessToken: String = "accessToken"
    val InteractiveLoginError: String = "iLoginError"
    fun ApiBaseUrl(envName: String): String {
      return when (envName) {
        "NIA TEST" -> "https://tma.identitaobcana.cz"
        else -> "https://unsupported.profile"
      }
    }

    val ApiRegisterPath: String = "/MobileApi/Register"
    val ApiLoginPath: String = "/MobileApi/Login"

    val AppVersion: String = "v1.3"

    val PreferencesLabel: String = "NiaBridgePreferences"

    val OtpConfig = TimeBasedOneTimePasswordConfig(codeDigits = 6,
      hmacAlgorithm = HmacAlgorithm.SHA1,
      timeStep = 30,
      timeStepUnit = TimeUnit.SECONDS)


    fun ServerPublicKey(envName: String): String {
      return when (envName) {
        "NIA TEST" -> "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxv+oZ/69lrOvtXmW9UjWZuX9UOdo7Hfq0ePSHICfWjQkgoToQN4ep7IQhSgY/dS8rVfSgYk6noQgeeMemFDiJ+uNGFvyrq6uwUvpQlUimjdgZMgw5J06tgVJLF32FJi98cEU/2M3d7B/opl/TmeY4vWGTErqewGFfOuhPr6KrPXUHfyyiLffgQLZ/LDGpyjZYi6dRqtcPT6g+G5xKsefR/HE0Rn+5YPT/oUv2X1BZdhNr2qrIlx+qy3oPveu3J4RaWb5yZy22pTJybQ8SqHMdBMs31VTazAfOA48/TQiHi2eWsiBguXvxFsojl0zVsrQ20x/Eu/WFoer1cbaTtaIRQIDAQAB"
        else -> ""
      }
    }


    //---------storage keys
    val IsRegistered: String = "IsRegistered"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val ApplicationId: String = "ApplicationId"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val OtpSecret: String = "OtpSecret"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val PartitionId: String = "PartitionId"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val ApplicationPrivateKey: String = "ApplicationPrivateKey"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val ApplicationPublicKey: String = "ApplicationPublicKey"
      get() {
        return "${AppConfig.Environment}_${field}"
      }
    val EnvName: String = "EnvName"

  }
}
