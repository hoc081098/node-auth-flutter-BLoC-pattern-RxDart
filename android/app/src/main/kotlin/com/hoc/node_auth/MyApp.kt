package com.hoc.node_auth

import android.app.Activity
import androidx.multidex.MultiDex
import com.google.crypto.tink.Aead
import com.google.crypto.tink.KeyTemplates
import com.google.crypto.tink.aead.AeadConfig
import com.google.crypto.tink.integration.android.AndroidKeysetManager
import com.google.crypto.tink.integration.android.AndroidKeystoreKmsClient
import io.flutter.app.FlutterApplication

class MyApp : FlutterApplication() {
  val aead: Aead by lazy {
    AndroidKeysetManager
      .Builder()
      .withSharedPref(this, KEYSET_NAME, PREF_FILE_NAME)
      .withKeyTemplate(KeyTemplates.get("AES256_GCM"))
      .withMasterKeyUri(MASTER_KEY_URI)
      .build()
      .keysetHandle
      .getPrimitive(Aead::class.java)
  }

  override fun onCreate() {
    super.onCreate()
    MultiDex.install(this)
    AeadConfig.register()
  }

  private companion object {
    private const val KEYSET_NAME = "nodeauth_keyset"
    private const val PREF_FILE_NAME = "nodeauth_pref"
    private const val MASTER_KEY_URI = "${AndroidKeystoreKmsClient.PREFIX}nodeauth_master_key"
  }
}

val Activity.myApp: MyApp get() = application as MyApp