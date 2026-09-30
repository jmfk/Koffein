import SwiftUI

@main
struct KoffeinApp: App {
    @StateObject private var power = PowerAssertionController()

    var body: some Scene {
        MenuBarExtra {
            KoffeinMenu(power: power)
        } label: {
            Label("Koffein", systemImage: power.isActive ? "cup.and.saucer.fill" : "cup.and.saucer")
        }
        .menuBarExtraStyle(.window)

        Settings {
            KoffeinSettings()
        }
    }
}
