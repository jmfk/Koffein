import XCTest
@testable import Koffein

final class SessionLengthTests: XCTestCase {
    func testFiniteSessionEndDates() {
        let start = Date(timeIntervalSince1970: 1_000)

        XCTAssertEqual(SessionLength.thirtyMinutes.endDate(from: start), start.addingTimeInterval(1_800))
        XCTAssertEqual(SessionLength.oneHour.endDate(from: start), start.addingTimeInterval(3_600))
        XCTAssertEqual(SessionLength.twoHours.endDate(from: start), start.addingTimeInterval(7_200))
        XCTAssertEqual(SessionLength.fourHours.endDate(from: start), start.addingTimeInterval(14_400))
        XCTAssertEqual(SessionLength.eightHours.endDate(from: start), start.addingTimeInterval(28_800))
    }

    func testEverySessionHasAFiniteTimeout() {
        XCTAssertTrue(SessionLength.allCases.allSatisfy { $0.interval > 0 })
    }

    @MainActor
    func testPowerAssertionStartsAndStops() {
        let controller = PowerAssertionController()

        controller.start(mode: .system, length: .oneHour)
        XCTAssertTrue(controller.isActive)
        XCTAssertEqual(controller.activeMode, .system)
        XCTAssertNil(controller.errorMessage)

        controller.stop()
        XCTAssertFalse(controller.isActive)
        XCTAssertNil(controller.activeMode)
    }
}
