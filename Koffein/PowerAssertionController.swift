import Foundation
import IOKit.pwr_mgt

enum KeepAwakeMode: String, CaseIterable, Identifiable {
    case system
    case display

    var id: Self { self }

    var title: String {
        switch self {
        case .system: "Mac awake"
        case .display: "Mac + display awake"
        }
    }

    var detail: String {
        switch self {
        case .system: "The display may turn off normally."
        case .display: "The display stays on too."
        }
    }

    var assertionType: CFString {
        switch self {
        case .system:
            kIOPMAssertionTypePreventUserIdleSystemSleep as CFString
        case .display:
            kIOPMAssertionTypePreventUserIdleDisplaySleep as CFString
        }
    }
}

enum SessionLength: String, CaseIterable, Identifiable {
    case thirtyMinutes
    case oneHour
    case twoHours
    case fourHours
    case indefinitely

    var id: Self { self }

    var title: String {
        switch self {
        case .thirtyMinutes: "30 minutes"
        case .oneHour: "1 hour"
        case .twoHours: "2 hours"
        case .fourHours: "4 hours"
        case .indefinitely: "Indefinitely"
        }
    }

    var interval: TimeInterval? {
        switch self {
        case .thirtyMinutes: 30 * 60
        case .oneHour: 60 * 60
        case .twoHours: 2 * 60 * 60
        case .fourHours: 4 * 60 * 60
        case .indefinitely: nil
        }
    }

    func endDate(from startDate: Date) -> Date? {
        interval.map { startDate.addingTimeInterval($0) }
    }
}

@MainActor
final class PowerAssertionController: ObservableObject {
    @Published private(set) var isActive = false
    @Published private(set) var activeMode: KeepAwakeMode?
    @Published private(set) var endDate: Date?
    @Published private(set) var errorMessage: String?
    @Published private(set) var now = Date()

    private var assertionID = IOPMAssertionID(0)
    private var countdownTask: Task<Void, Never>?

    deinit {
        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
        }
        countdownTask?.cancel()
    }

    func start(mode: KeepAwakeMode, length: SessionLength) {
        stop()

        let timeout = length.interval ?? 0
        var newAssertionID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithDescription(
            mode.assertionType,
            "Koffein keep-awake session" as CFString,
            mode.detail as CFString,
            "Koffein is keeping this Mac awake at the user's request." as CFString,
            nil,
            timeout,
            kIOPMAssertionTimeoutActionTurnOff as CFString,
            &newAssertionID
        )

        guard result == kIOReturnSuccess else {
            errorMessage = "macOS could not start the keep-awake session (error \(result))."
            return
        }

        assertionID = newAssertionID
        activeMode = mode
        endDate = length.endDate(from: Date())
        isActive = true
        errorMessage = nil
        beginTimer()
    }

    func stop() {
        countdownTask?.cancel()
        countdownTask = nil

        if assertionID != 0 {
            IOPMAssertionRelease(assertionID)
            assertionID = 0
        }

        isActive = false
        activeMode = nil
        endDate = nil
    }

    var remainingText: String {
        guard let endDate else { return "Until turned off" }
        let remaining = max(0, endDate.timeIntervalSince(now))
        return Duration.seconds(remaining).formatted(
            .time(pattern: remaining >= 3600 ? .hourMinute : .minuteSecond)
        ) + " remaining"
    }

    private func beginTimer() {
        now = Date()
        countdownTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                guard let self else { return }
                self.now = Date()
                if let endDate = self.endDate, self.now >= endDate {
                    self.stop()
                    return
                }
            }
        }
    }
}
