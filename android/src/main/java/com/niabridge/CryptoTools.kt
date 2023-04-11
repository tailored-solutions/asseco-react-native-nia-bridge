package com.ndt.ggmobileclient

import android.util.Base64
import java.security.*
import java.security.spec.PKCS8EncodedKeySpec
import java.security.spec.X509EncodedKeySpec
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey
import javax.crypto.spec.SecretKeySpec


data class RsaKeys(val PublicKey: ByteArray, val PublicKeyBase64: String, val PrivateKey: ByteArray, val PrivateKeyBase64: String)
data class CipherData(val DataBase64: String, val KeyBase64: String)

class CryptoTools {

    companion object {

        fun generateRsaKeys(): RsaKeys {
            val kpg: KeyPairGenerator = KeyPairGenerator.getInstance("RSA")
            kpg.initialize(2048)
            val keyPair: KeyPair = kpg.genKeyPair()
            val pri: ByteArray = keyPair.private.encoded
            val pub: ByteArray = keyPair.public.encoded
            val privateKey = Base64.encodeToString(pri, Base64.DEFAULT)
            val publicKey = Base64.encodeToString(pub, Base64.DEFAULT)
            return RsaKeys(pub, publicKey, pri, privateKey)
        }

        fun encrypt(data: String, publicKeyB64: String): CipherData {
            try {
                var bData = data.toByteArray(Charsets.UTF_8);
                var countFillChars = 16 - (bData.size % 16);
                if(countFillChars != 0 && countFillChars != 16){
                    bData = bData + ByteArray(countFillChars, { _ -> 0x20.toByte() })
                }
                //countFillChars = 16 - (bData.size % 16);

                //-------------
                val keygen = KeyGenerator.getInstance("AES")
                keygen.init(256)
                val key: SecretKey = keygen.generateKey()
                val cipherAes = Cipher.getInstance("AES_256/ECB/NoPadding")
                cipherAes.init(Cipher.ENCRYPT_MODE, key)
                val aesData: ByteArray = cipherAes.doFinal(bData)


                val aesCfgData = key.encoded
                val pubKey = loadPublicKey(publicKeyB64)

                val cipherRsa = Cipher.getInstance("RSA/ECB/PKCS1Padding");
                cipherRsa.init(Cipher.ENCRYPT_MODE, pubKey);
                val keyData = cipherRsa.doFinal(aesCfgData)

                return CipherData(Base64.encodeToString(aesData, Base64.DEFAULT), Base64.encodeToString(keyData, Base64.DEFAULT))

            } catch (e: Exception) {
                e.printStackTrace()
                throw e
            }
        }

        fun decrypt(cData: CipherData, privateKeyB64: String): String {
            try {
                val privKey = loadPrivateKey(privateKeyB64)
                val cipherRsa = Cipher.getInstance("RSA/ECB/PKCS1Padding")
                cipherRsa.init(Cipher.DECRYPT_MODE, privKey)
                val keyData = cipherRsa.doFinal(Base64.decode(cData.KeyBase64, Base64.DEFAULT))

                val bKey = keyData.copyOfRange(0, keyData.size)
                val key: SecretKey = SecretKeySpec(bKey, 0, bKey.size, "AES")

                val cipherAes = Cipher.getInstance("AES_256/ECB/NoPadding")
                cipherAes.init(Cipher.DECRYPT_MODE, key)
                val data: ByteArray = cipherAes.doFinal(Base64.decode(cData.DataBase64, Base64.DEFAULT))
                return String(data, Charsets.UTF_8)

            } catch (e: Exception) {
                throw e
            }
        }

        fun sign(data: String, privateKeyB64: String): String {
            try {
                val privKey = loadPrivateKey(privateKeyB64)
                val signature = Signature.getInstance("SHA256withRSA")
                signature.initSign(privKey)
                signature.update(data.toByteArray(Charsets.UTF_8))
                val signData = signature.sign()
                return Base64.encodeToString(signData, Base64.DEFAULT)
            } catch (e: Exception) {
                e.printStackTrace()
                throw e
            }
        }


        //*********************************************************************

        private fun loadPrivateKey(privateKeyB64: String): PrivateKey {
            val privKey = Base64.decode(privateKeyB64,  Base64.DEFAULT)
            return KeyFactory.getInstance("RSA").generatePrivate(PKCS8EncodedKeySpec(privKey))
        }

        private fun loadPublicKey(publicKeyB64: String): PublicKey? {
            val pubKey = Base64.decode(publicKeyB64,  Base64.DEFAULT)
            return  KeyFactory.getInstance("RSA").generatePublic(X509EncodedKeySpec(pubKey))
        }


    }
}
