import UIKit
import Flutter
import CryptoSwift

private extension String {
  static let CRYPTO_CHANNEL = "com.hoc.node_auth/crypto"
  static let CRYPTO_ERROR_CODE = "com.hoc.node_auth/crypto_error"
  static let ENCRYPT_METHOD = "encrypt"
  static let DECRYPT_METHOD = "decrypt"
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let flutterVC = window?.rootViewController as! FlutterViewController

    let cryptoChannel = FlutterMethodChannel(
      name: .CRYPTO_CHANNEL,
      binaryMessenger: flutterVC.binaryMessenger
    )
    cryptoChannel.setMethodCallHandler { call, result in
      switch call.method {
      case .ENCRYPT_METHOD: encrypt(call: call, result: result)
      case .DECRYPT_METHOD: decrypt(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

private enum AESConfig {
  static let iv: [UInt8] = "_hoc081098_auth_".bytes
  static let key: [UInt8] = "__hoc081098_nodejs_auth_rxdart__".bytes

  static let backgroundQueue = DispatchQueue.global(qos: .userInitiated)

  static func gcm() -> GCM { GCM(iv: AESConfig.iv, mode: .combined) }
}

private func complete(result: @escaping FlutterResult, with error: Error) {
  debugPrint("[NODE_AUTH] Error: ", error)

  executeOnMain {
    result(
      FlutterError(
        code: .CRYPTO_ERROR_CODE,
        message: error.localizedDescription,
        details: nil
      )
    )
  }
}

private func executeOnMain(block: @escaping () -> Void) {
  if Thread.isMainThread {
    block()
  } else {
    DispatchQueue.main.async {
      block()
    }
  }
}

private func useAES(
  input: String,
  result: @escaping FlutterResult,
  inputToBytes: (String) -> [UInt8]?,
  bytesToString: @escaping ([UInt8]) -> String?,
  block: @escaping (AES, [UInt8]) throws -> [UInt8]
) {
  guard let inputBytes = inputToBytes(input) else {
    print("[NODE_AUTH] Error: inputToBytes returns nil")

    executeOnMain {
      result(
        FlutterError(
          code: .CRYPTO_ERROR_CODE,
          message: "An unexpected error occurred!",
          details: nil
        )
      )
    }
    return
  }

  AESConfig.backgroundQueue.async {
    let start = DispatchTime.now()

    do {
      let aes = try AES(
        key: AESConfig.key,
        blockMode: AESConfig.gcm(),
        padding: .noPadding
      )

      let outputBytes = try block(aes, inputBytes)
      guard let stringResult = bytesToString(outputBytes) else {
        print("[NODE_AUTH] Error: bytesToString returns nil")

        executeOnMain {
          result(
            FlutterError(
              code: .CRYPTO_ERROR_CODE,
              message: "An unexpected error occurred!",
              details: nil
            )
          )
        }
        return
      }

      let end = DispatchTime.now()
      let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
      let millisTime = Double(nanoTime) / 1_000_000
      print("[NODE_AUTH] Input: \(input)")
      print("[NODE_AUTH] Output: \(stringResult)")
      print("[NODE_AUTH] Time: \(millisTime) ms")

      executeOnMain { result(stringResult) }
    } catch {
      complete(result: result, with: error)
    }
  }
}

private func encrypt(call: FlutterMethodCall, result: @escaping FlutterResult) {
  useAES(
    input: call.arguments as! String,
    result: result,
    inputToBytes: { $0.bytes },
    bytesToString: base64Encode(bytes:)
  ) { aes, bytes in try aes.encrypt(bytes) }
}


private func decrypt(call: FlutterMethodCall, result: @escaping FlutterResult) {
  useAES(
    input: call.arguments as! String,
    result: result,
    inputToBytes: base64Decode(s:),
    bytesToString: { .init(bytes: $0, encoding: .utf8) }
  ) { aes, bytes in try aes.decrypt(bytes) }
}

func base64Decode(s: String) -> [UInt8]? {
  Data(base64Encoded: s)?.bytes
}

func base64Encode(bytes: [UInt8]) -> String {
  Data(bytes).base64EncodedString()
}
