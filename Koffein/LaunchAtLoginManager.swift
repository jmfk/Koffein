import Foundation
import ServiceManagement

@MainActor
enum LaunchAtLoginManager {
    private static let configuredKey = "didConfigureLaunchAtLogin"
    private static let statusKey = "launchAtLoginLastStatus"

    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func configureDefaultIfNeeded() {
        guard Bundle.main.bundleURL.path.hasPrefix("/Applications/") else { return }

        let defaults = UserDefaults.standard
        let currentStatus = SMAppService.mainApp.status
        guard !defaults.bool(forKey: configuredKey) || currentStatus == .notFound else {
            recordStatus()
            return
        }

        defer { defaults.set(true, forKey: configuredKey) }

        do {
            if currentStatus != .enabled && currentStatus != .requiresApproval {
                try SMAppService.mainApp.register()
            }
            recordStatus()
        } catch {
            defaults.set("error", forKey: statusKey)
        }
    }

    static func setEnabled(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }
        UserDefaults.standard.set(true, forKey: configuredKey)
        recordStatus()
    }

    static func recordStatus() {
        let status: String
        switch SMAppService.mainApp.status {
        case .enabled:
            status = "enabled"
        case .requiresApproval:
            status = "requires-approval"
        case .notFound:
            status = "not-found"
        case .notRegistered:
            status = "not-registered"
        @unknown default:
            status = "unknown"
        }
        UserDefaults.standard.set(status, forKey: statusKey)
    }
}
