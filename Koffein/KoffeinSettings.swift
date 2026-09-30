import SwiftUI

struct KoffeinSettings: View {
    @State private var launchAtLogin = LaunchAtLoginManager.isEnabled
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

            Text("Koffein starts in the menu bar, but never enables a keep-awake session automatically.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("Koffein only prevents sleep caused by inactivity. Closing the lid, choosing Sleep, or a critically low battery can still put the Mac to sleep.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 430, height: 220)
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            try LaunchAtLoginManager.setEnabled(enabled)
            message = nil
        } catch {
            launchAtLogin = LaunchAtLoginManager.isEnabled
            message = "macOS could not update the login setting: \(error.localizedDescription)"
        }
    }
}
