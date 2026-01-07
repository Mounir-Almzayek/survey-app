import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Register Hardware KeyStore Handler
    HardwareKeyStoreHandler.register(with: self.registrar(forPlugin: "HardwareKeyStoreHandler")!)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
