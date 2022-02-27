package com.hoc.node_auth

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {
  private lateinit var cryptoChannel: MethodChannel
  private lateinit var mainScope: CoroutineScope

  //region Lifecycle
  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    Log.d("Flutter", "configureFlutterEngine flutterEngine=$flutterEngine $this")

    mainScope = MainScope()
    cryptoChannel = MethodChannel(
      flutterEngine.dartExecutor.binaryMessenger,
      CRYPTO_CHANNEL,
    ).apply { setMethodCallHandler(MethodCallHandlerImpl()) }
  }

  override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
    super.cleanUpFlutterEngine(flutterEngine)
    Log.d("Flutter", "cleanUpFlutterEngine flutterEngine=$flutterEngine $this")

    cryptoChannel.setMethodCallHandler(null)
    mainScope.cancel()
  }
  //endregion

  private inner class MethodCallHandlerImpl : MethodChannel.MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
      when (call.method) {
        ENCRYPT_METHOD -> encrypt(call, result)
        DECRYPT_METHOD -> decrypt(call, result)
        else -> result.notImplemented()
      }
    }
  }

  //region Handlers
  private fun encrypt(
    call: MethodCall,
    result: MethodChannel.Result
  ) {
    val plaintext = checkNotNull(call.arguments<String?>()) { "plaintext must be not null" }

    mainScope.launch {
      runCatching {
        withContext(Dispatchers.IO) {
          myApp.aead.encrypt(plaintext.encodeToByteArray(), null).let(::String)
        }
      }
        .onSuccess { result.success(it) }
        .onFailureExceptCancellationException { result.error(CRYPTO_ERROR_CODE, it.message, null) }
    }
  }

  private fun decrypt(
    call: MethodCall,
    result: MethodChannel.Result
  ) {
    val ciphertext = checkNotNull(call.arguments<String?>()) { "ciphertext must be not null" }

    mainScope.launch {
      runCatching {
        withContext(Dispatchers.IO) {
          myApp.aead.decrypt(ciphertext.encodeToByteArray(), null).let(::String)
        }
      }
        .onSuccess { result.success(it) }
        .onFailureExceptCancellationException { result.error(CRYPTO_ERROR_CODE, it.message, null) }
    }
  }
  //endregion

  private companion object {
    const val CRYPTO_CHANNEL = "com.hoc.node_auth/crypto"
    const val CRYPTO_ERROR_CODE = "com.hoc.node_auth/crypto_error"
    const val ENCRYPT_METHOD = "encrypt"
    const val DECRYPT_METHOD = "decrypt"
  }
}

private inline fun <T> Result<T>.onFailureExceptCancellationException(action: (throwable: Throwable) -> Unit): Result<T> {
  return onFailure {
    if (it is CancellationException) throw it
    action(it)
  }
}