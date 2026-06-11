import Flutter
import HealthKit
import UIKit

public class PlatformBridgePlugin: NSObject, FlutterPlugin {
  private let health = HealthBridge()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "platform_bridge", binaryMessenger: registrar.messenger())
    let instance = PlatformBridgePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  /// True when the Screen Time stack is usable on this OS (the entitlement
  /// is still checked at runtime by each call).
  private var screenTimeAvailable: Bool {
    #if canImport(FamilyControls) && canImport(ManagedSettings)
      if #available(iOS 16.0, *) { return true }
    #endif
    return false
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "support":
      result([
        "canList": false,  // Apple provides no installed-apps API.
        "canBlock": screenTimeAvailable,
        "canReadHealth": HKHealthStore.isHealthDataAvailable(),
        "platform": "ios",
      ])

    case "requestBlockingAccess":
      #if canImport(FamilyControls) && canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
          ScreenTimeBridge.shared.requestAuthorization { verdict in
            result(["result": verdict])
          }
          return
        }
      #endif
      result(["result": "unsupported"])

    case "requestHealthAccess":
      let metrics = args["metrics"] as? [String] ?? []
      health.requestAccess(metrics: metrics) { verdict in
        result(["result": verdict])
      }

    case "pickApps":
      #if canImport(FamilyControls) && canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
          let selection = args["selection"] as? [String: Any] ?? [:]
          let apps = selection["apps"] as? [[String: Any]] ?? []
          let appIds = apps.compactMap { $0["id"] as? String }
          let categoryIds = selection["categoryIds"] as? [String] ?? []
          ScreenTimeBridge.shared.pickApps(
            encodedApplicationTokenIds: appIds,
            encodedCategoryTokenIds: categoryIds
          ) { selection in
            result(selection)
          }
          return
        }
      #endif
      result(["apps": [], "categoryCount": 0])

    case "setBlocking":
      #if canImport(FamilyControls) && canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
          let selection = args["selection"] as? [String: Any] ?? [:]
          let apps = selection["apps"] as? [[String: Any]] ?? []
          let appIds = apps.compactMap { $0["id"] as? String }
          let categoryIds = selection["categoryIds"] as? [String] ?? []
          let enabled = args["enabled"] as? Bool ?? false
          ScreenTimeBridge.shared.setBlocking(
            encodedApplicationTokenIds: appIds,
            encodedCategoryTokenIds: categoryIds,
            enabled: enabled)
        }
      #endif
      result(nil)

    case "isBlocking":
      #if canImport(FamilyControls) && canImport(ManagedSettings)
        if #available(iOS 16.0, *) {
          result(["blocking": ScreenTimeBridge.shared.isBlocking()])
          return
        }
      #endif
      result(["blocking": false])

    case "readHealth":
      let metrics = args["metrics"] as? [String] ?? []
      let start = (args["start"] as? NSNumber).map {
        Date(timeIntervalSince1970: $0.doubleValue / 1000)
      } ?? Date.distantPast
      let end = (args["end"] as? NSNumber).map {
        Date(timeIntervalSince1970: $0.doubleValue / 1000)
      } ?? Date()
      health.read(metrics: metrics, start: start, end: end) { values in
        result(["values": values])
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
