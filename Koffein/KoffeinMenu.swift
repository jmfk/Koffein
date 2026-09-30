import AppKit
import SwiftUI

struct KoffeinMenu: View {
    @ObservedObject var power: PowerAssertionController
    @AppStorage("preferredMode") private var preferredModeRaw = KeepAwakeMode.system.rawValue
    @AppStorage("preferredLength") private var preferredLengthRaw = SessionLength.oneHour.rawValue

    private var preferredMode: KeepAwakeMode {
        KeepAwakeMode(rawValue: preferredModeRaw) ?? .system
    }

    private var preferredLength: SessionLength {
        SessionLength(rawValue: preferredLengthRaw) ?? .oneHour
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if power.isActive {
                activeSession
            } else {
                sessionControls
            }

            if let errorMessage = power.errorMessage {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Divider()

            HStack {
                Button {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    power.stop()
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
            .font(.caption)
        }
        .padding(18)
        .frame(width: 310)
    }

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: power.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
                .font(.title2)
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(power.isActive ? .orange : .secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text("Koffein")
                    .font(.headline)
                Text(power.isActive ? "Keeping your Mac awake" : "Ready when you are")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var activeSession: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(power.activeMode?.title ?? "Active")
                    .font(.body.weight(.medium))
                Text(power.remainingText)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            Button(role: .destructive) {
                power.stop()
            } label: {
                Text("Let Mac Sleep")
                    .frame(maxWidth: .infinity)
            }
            .controlSize(.large)
        }
    }

    private var sessionControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Keep", selection: $preferredModeRaw) {
                ForEach(KeepAwakeMode.allCases) { mode in
                    Text(mode.title).tag(mode.rawValue)
                }
            }
            .pickerStyle(.radioGroup)

            HStack {
                Text("For")
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("Duration", selection: $preferredLengthRaw) {
                    ForEach(SessionLength.allCases) { length in
                        Text(length.title).tag(length.rawValue)
                    }
                }
                .labelsHidden()
                .frame(width: 150)
            }

            Button {
                power.start(mode: preferredMode, length: preferredLength)
            } label: {
                Text("Start Koffein")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.orange)
        }
    }
}
