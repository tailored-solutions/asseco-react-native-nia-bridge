package com.niabridge

import android.content.Context
import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactContext
import com.ndt.ggmobileclient.CipherData
import com.ndt.ggmobileclient.CryptoTools
import com.niabridge.api.*
import okhttp3.*
import java.io.IOException
import java.util.concurrent.TimeUnit
import com.google.gson.Gson
import dev.turingcomplete.kotlinonetimepassword.TimeBasedOneTimePasswordGenerator
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.RequestBody.Companion.toRequestBody
import java.util.*

class NiaApi {

  var context: ReactContext

  var isLogged: Boolean
  var AccessToken: String

  lateinit var envEnum: Array<String>

  constructor(providedContext: ReactContext) {
    context = providedContext
    AccessToken = ""
    isLogged = false
  }

  private fun CreateOkHttpClient(): OkHttpClient {
    val builder = OkHttpClient().newBuilder()
      .connectTimeout(60, TimeUnit.SECONDS)
      .readTimeout(60, TimeUnit.SECONDS)
      .writeTimeout(60, TimeUnit.SECONDS)
    return builder.build()
  }

  fun callApiRegister(accessToken: String, destination: String, promise: Promise) {

    try {
      val client = CreateOkHttpClient()
      val rsaKeys = CryptoTools.generateRsaKeys()

      val reqData = RegisterRequest(
        accessToken,
        Constants.ProtocolVersion,
        ApplicationInfo(),
        rsaKeys.PublicKeyBase64
      )
      val jsonData = Gson().toJson(reqData)
      val cData = CryptoTools.encrypt(jsonData, Constants.ServerPublicKey(AppConfig.Environment))

      val apiEnv = EnvelopeRequest(
        Constants.EnvelopVersion,
        cData!!.DataBase64,
        cData!!.KeyBase64
      )
      val jsonEnv = Gson().toJson(apiEnv)

      val reqBody = jsonEnv.toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())
      val request = Request.Builder()
        //.url(Constants.ApiBaseUrl(AppConfig.Environment) + Constants.ApiRegisterPath)
        .url(destination + Constants.ApiRegisterPath)
        .post(reqBody)
        .build()

      Log.d("NiaApi-Register", "\n\rConnecting to API ...")
      client.newCall(request).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
          Log.e("NiaApi-Register", e.toString())
          promise.reject(e)
        }

        override fun onResponse(call: Call, response: Response) {
          var logMsg = ""
          try {
            if (!response.isSuccessful) {
              promise.reject(Exception(
                "\n\rRegister request failed. ErrorCode: ${response.code}, Msg: ${
                  response.body!!.string()
                }"
              ))
              return
            }

            val respBody = response.body!!.string()
            var isRegisted = false
            logMsg += "\n\rRegister env. response: $respBody"

            val apiEnv = Gson().fromJson(respBody, EnvelopeResponse::class.java)

            val jsonData = CryptoTools.decrypt(
              CipherData(apiEnv.Data, apiEnv.Key),
              rsaKeys.PrivateKeyBase64
            )

            logMsg += "\n\rRegister response: $jsonData"

            val regResponse = Gson().fromJson(jsonData, RegisterResponse::class.java)

            if (regResponse.ErrorCode == 0) {
              val sharedPref = context.getSharedPreferences(Constants.PreferencesLabel, Context.MODE_PRIVATE)
              with(sharedPref.edit()) {
                putBoolean(Constants.IsRegistered, true)
                putString(Constants.ApplicationId, regResponse.ApplicationId)
                putString(Constants.OtpSecret, regResponse.OtpSecret)
                putInt(Constants.PartitionId, regResponse.PartitionId)
                putString(Constants.ApplicationPrivateKey, rsaKeys.PrivateKeyBase64)
                putString(Constants.ApplicationPublicKey, rsaKeys.PublicKeyBase64)
                apply()
              }
              isRegisted = true
              logMsg += "\n\rRegister finished. You can login."
              promise.resolve(true)
            } else {
              isRegisted = false
              logMsg += "\n\rRegister failed. ErrorCode: ${regResponse.ErrorCode}"
              promise.reject(Exception(logMsg))
            }

            Log.d("NiaApi-Register", logMsg)
          } catch (e: Exception) {
            promise.reject(e)
            Log.e("NiaApi-Register", "\n\rException (API call):")
            Log.e("NiaApi-Register", "\n\r${e.stackTraceToString()}")
          }
        }
      })
    } catch (e: Exception) {
      promise.reject(e)
      Log.e("NiaApi-Register", "\n\rException (callApiRegister):")
      Log.e("NiaApi-Register", "\n\r${e.stackTraceToString()}")
    }
  }

  fun callLogin(destination: String, promise: Promise) {
    try {
      val sharedPref = context.getSharedPreferences(Constants.PreferencesLabel, Context.MODE_PRIVATE)
      val applicationId = sharedPref.getString(Constants.ApplicationId, "").toString()
      val otpSecret = sharedPref.getString(Constants.OtpSecret, "").toString()
      val partitionId = sharedPref.getInt(Constants.PartitionId, 0)
      val publicKeyB64 = sharedPref.getString(Constants.ApplicationPublicKey, "").toString()
      val privateKeyB64 = sharedPref.getString(Constants.ApplicationPrivateKey, "").toString()

      Log.d("NiaApi-Login", "\n\rAppID: $applicationId, OTP: $otpSecret, PartID: $partitionId")
      if (applicationId === "" || otpSecret === "" || publicKeyB64 === "" || privateKeyB64 === "" || partitionId == 0) {
        promise.reject(Exception("All stored values are empty. Please register device again."))
        return
      }
      val timeBasedOneTimePasswordGenerator = TimeBasedOneTimePasswordGenerator(otpSecret.toByteArray(), Constants.OtpConfig)
      val otp = timeBasedOneTimePasswordGenerator.generate(Date(System.currentTimeMillis()))

      val client = CreateOkHttpClient()
      val sessionID = UUID.randomUUID()
      val reqData = LoginRequest(
        com.niabridge.api.Credentials(applicationId, otp, partitionId),
        sessionID.toString(),
        Constants.ProtocolVersion,
        ApplicationInfo(),
        privateKeyB64
      )
      val jsonData = Gson().toJson(reqData)
      val cData = CryptoTools.encrypt(jsonData, Constants.ServerPublicKey(AppConfig.Environment))

      val apiEnv = EnvelopeRequest(
        Constants.EnvelopVersion,
        cData!!.DataBase64,
        cData!!.KeyBase64
      )

      val jsonEnv = Gson().toJson(apiEnv)

      val reqBody = jsonEnv.toRequestBody("application/json; charset=utf-8".toMediaTypeOrNull())
      val request = Request.Builder()
        //.url(Constants.ApiBaseUrl(AppConfig.Environment) + Constants.ApiLoginPath)
        .url(destination + Constants.ApiLoginPath)
        .post(reqBody)
        .build()

      Log.d("NiaApi-Login", "\n\rConnecting to API ...")
      client.newCall(request).enqueue(object : Callback {
        override fun onFailure(call: Call, e: IOException) {
          promise.reject(e)
          Log.e("NiaApi-Login", e.toString())
        }

        override fun onResponse(call: Call, response: Response) {
          var logMsg = ""
          try {
            if (!response.isSuccessful) {
              promise.reject(Exception(
                "\n\rLogin request failed. ErrorCode: ${response.code}, Msg: ${
                  response.body!!.string()
                }"
              ))
              return
            }

            val respBody = response.body!!.string()
            logMsg += "\n\rLogin env. response: $respBody"

            val apiEnv = Gson().fromJson(respBody, EnvelopeResponse::class.java)
            val jsonData = CryptoTools.decrypt(CipherData(apiEnv.Data, apiEnv.Key), privateKeyB64)

            logMsg += "\n\rLogin response: $jsonData"

            val loginResponse = Gson().fromJson(jsonData, LoginResponse::class.java)

            if (loginResponse.ErrorCode === 0) {
              AccessToken = loginResponse.AccessToken
              logMsg += "\n\rInResponseTo: " + loginResponse.InResponseTo
              logMsg += "\n\rAccessToken: $AccessToken"
              logMsg += "\n\rLogin finished. Try to TEST button"
              isLogged = true
              promise.resolve(true)
            } else {

              logMsg += "\n\rLogin failed. ErrorCode: ${loginResponse.ErrorCode}"
              promise.reject(Exception(logMsg))
              isLogged = false
            }

            Log.d("NiaApi-Login", logMsg)

          } catch (e: Exception) {
            promise.reject(e)

            Log.e("NiaApi-Login", logMsg)
            Log.e("NiaApi-Login", "\n\rException (API call):")
            Log.e("NiaApi-Login", "\n\r${e.stackTraceToString()}")
          }
        }
      })

    } catch (e: Exception) {
      promise.reject(e)
      Log.e("NiaApi-Login", "\n\rException (onClickBtnLogin):")
      Log.e("NiaApi-Login", "\n\r${e.stackTraceToString()}")
    }
  }

  fun isLoggedIn(promise: Promise) {
    if (AccessToken.isEmpty()) {
      promise.reject(Exception("Access token is empty. Please log in"))
      Log.e("NiaApi-IsLoggedIn", "\n\rError: Access token is NULL or empty. Please, log in")
    } else {
      promise.resolve(true)
    }
  }

  fun cleanDevice(promise: Promise) {
    val sharedPref = context.getSharedPreferences(Constants.PreferencesLabel, Context.MODE_PRIVATE)
    with(sharedPref.edit()) {
      putBoolean(Constants.IsRegistered, false)
      putString(Constants.ApplicationId, "")
      putString(Constants.OtpSecret, "")
      putString(Constants.ApplicationPublicKey, "")
      putString(Constants.ApplicationPrivateKey, "")
      putInt(Constants.PartitionId, 0)
      apply()
    }
    promise.resolve(true)
    Log.d("NiaApi-CleanDevice", "\n\rApplication was unregistered.")
  }
}

