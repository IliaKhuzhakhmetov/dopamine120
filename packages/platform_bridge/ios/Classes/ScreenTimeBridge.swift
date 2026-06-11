import Flutter
import SwiftUI
import UIKit

#if canImport(FamilyControls) && canImport(ManagedSettings)
import FamilyControls
import ManagedSettings

/// Screen Time integration: FamilyControls authorization, the system
/// FamilyActivityPicker, and ManagedSettings shield enforcement.
///
/// Everything here needs the com.apple.developer.family-controls
/// entitlement and a physical device; without them calls fail at runtime
/// (returned as denied/unsupported), but the code always compiles.
@available(iOS 16.0, *)
final class ScreenTimeBridge {
    static let shared = ScreenTimeBridge()

    private let store = ManagedSettingsStore()
    private weak var pickerHost: UIViewController?

    func requestAuthorization(completion: @escaping (String) -> Void) {
        Task { @MainActor in
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                completion("granted")
            } catch FamilyControlsError.restricted {
                completion("restricted")
            } catch {
                // Includes missing entitlement and simulator.
                completion("denied")
            }
        }
    }

    /// Presents the system picker; resolves with `{apps, categoryIds, categoryCount}`
    /// where ids are base64-encoded opaque Screen Time tokens
    /// (no names or icons -- Apple never reveals them to us).
    /// The encoded ids passed in are pre-checked in the picker, so a stored
    /// selection can be re-opened and edited instead of starting from scratch.
    func pickApps(
        encodedApplicationTokenIds: [String],
        encodedCategoryTokenIds: [String],
        completion: @escaping ([String: Any]) -> Void
    ) {
        DispatchQueue.main.async {
            guard self.pickerHost == nil, let root = Self.rootViewController() else {
                completion(["apps": [], "categoryCount": 0])
                return
            }
            var initialSelection = FamilyActivitySelection()
            initialSelection.applicationTokens = Self.decodedTokens(
                encodedApplicationTokenIds,
                as: ApplicationToken.self
            )
            initialSelection.categoryTokens = Self.decodedTokens(
                encodedCategoryTokenIds,
                as: ActivityCategoryToken.self
            )
            let sheet = PickerSheet(initialSelection: initialSelection) { [weak self] selection in
                self?.pickerHost?.dismiss(animated: true)
                self?.pickerHost = nil
                guard let selection else {
                    completion(["apps": [], "categoryCount": 0])
                    return
                }
                let appIds = Self.encodedTokens(selection.applicationTokens)
                let categoryIds = Self.encodedTokens(selection.categoryTokens)
                let apps: [[String: Any?]] = appIds.map { id in
                    ["id": id, "name": nil, "icon": nil]
                }
                completion([
                    "apps": apps,
                    "categoryIds": categoryIds,
                    "categoryCount": categoryIds.count,
                ])
            }
            let host = UIHostingController(rootView: sheet)
            self.pickerHost = host
            root.present(host, animated: true)
        }
    }

    /// Shields the given encoded app/category tokens (or clears the shield).
    func setBlocking(
        encodedApplicationTokenIds: [String],
        encodedCategoryTokenIds: [String],
        enabled: Bool
    ) {
        let applicationTokens: Set<ApplicationToken> = Self.decodedTokens(
            encodedApplicationTokenIds,
            as: ApplicationToken.self
        )
        let categoryTokens: Set<ActivityCategoryToken> = Self.decodedTokens(
            encodedCategoryTokenIds,
            as: ActivityCategoryToken.self
        )

        if enabled && (!applicationTokens.isEmpty || !categoryTokens.isEmpty) {
            store.shield.applications = applicationTokens.isEmpty ? nil : applicationTokens
            store.shield.applicationCategories = categoryTokens.isEmpty
                ? nil
                : .specific(categoryTokens)
        } else {
            store.shield.applications = nil
            store.shield.applicationCategories = nil
        }
    }

    func isBlocking() -> Bool {
        if let shielded = store.shield.applications, !shielded.isEmpty {
            return true
        }
        if let categories = store.shield.applicationCategories, categories != .none {
            return true
        }
        return false
    }

    private static func encodedTokens<T: Codable>(_ tokens: Set<T>) -> [String] {
        let encoder = JSONEncoder()
        return tokens.compactMap { token in
            guard let data = try? encoder.encode(token) else { return nil }
            return data.base64EncodedString()
        }
    }

    private static func decodedTokens<T: Codable>(_ ids: [String], as type: T.Type) -> Set<T>
    where T: Hashable {
        let decoder = JSONDecoder()
        return Set(
            ids.compactMap { id in
                guard let data = Data(base64Encoded: id) else { return nil }
                return try? decoder.decode(type, from: data)
            }
        )
    }

    private static func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
    }
}

@available(iOS 16.0, *)
private struct PickerSheet: View {
    @State private var selection: FamilyActivitySelection
    let onDone: (FamilyActivitySelection?) -> Void

    init(
        initialSelection: FamilyActivitySelection,
        onDone: @escaping (FamilyActivitySelection?) -> Void
    ) {
        _selection = State(initialValue: initialSelection)
        self.onDone = onDone
    }

    var body: some View {
        NavigationView {
            FamilyActivityPicker(selection: $selection)
                .navigationTitle("Choose apps")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { onDone(nil) }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { onDone(selection) }
                    }
                }
        }
    }
}
#endif
