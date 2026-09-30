import ServiceManagement
import SwiftUI

struct KoffeinSettings: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var message: String?

    var body: some View {
        Form {
            Toggle("Launch Koffein at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { value in
                    updateLaunchAtLogin(value)
                }

            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("Koffein only prevents sleep caused by inactivity. Closing the lid, choosing Sleep, or a critically low battery can still put the Mac to sleep.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 430, height: 190)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            message = nil
        } catch {
            launchAtLogin = SMAppService.mainApp.status == .enabled
            message = "macOS could not update the login setting: \(error.localizedDescription)"
        }
    }
}
