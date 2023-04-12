package com.niabridge

import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class NiaBridgeModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

  var niaApi: NiaApi = NiaApi(reactApplicationContext,)

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun register(niaAccessToken: String, destination: String, promise: Promise) {
    Log.d("NIA", "Register method called with destination: $destination and token: $niaAccessToken")

    niaApi.callApiRegister(niaAccessToken, destination, promise)
  }

  @ReactMethod
  fun login(destination: String, promise: Promise) {
    Log.d("NIA", "Login method called with destination: $destination")
    niaApi.callLogin(destination, promise)
  }

  @ReactMethod
  fun isLoggedIn(promise: Promise) {
    Log.d("NIA", "IsLoggedIn method called")
    niaApi.isLoggedIn(promise)
  }

  @ReactMethod
  fun logoutAndClear(promise: Promise) {
    Log.d("NIA", "LogoutAndClear method called")
    niaApi.cleanDevice(promise)
  }

  @ReactMethod
  fun isDeviceRegistered(promise: Promise) {
    Log.d("NIA", "IsDeviceRegistered method called")
    niaApi.isDeviceRegistered(promise)
  }

  @ReactMethod
  fun getToken(promise: Promise) {
    Log.d("NIA", "GetToken method called")
    niaApi.getLoginToken(promise)
  }

  companion object {
    const val NAME = "NiaBridge"
  }
}
