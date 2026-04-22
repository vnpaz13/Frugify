//
//  FrugifyTests.swift
//  FrugifyTests
//
//  Created by VnPaz on 12/24/25.
//

//import Testing
//@testable import Frugify
//
//struct FrugifyTests {
//
//    @Test func example() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }
//
//}

// MARK: - Streak 계산 테스트

import XCTest
@testable import Frugify

final class MainViewModelTests: XCTestCase {

    func testStreak_whenContinuousDays_shouldReturnCorrectStreak() {
        let vm = MainViewModel()

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 오늘 포함 3일 연속 기록
        let records = [
            makeRecord(daysAgo: 0),
            makeRecord(daysAgo: 1),
            makeRecord(daysAgo: 2)
        ]

        let streak = vm.calculateStreakForTest(records: records)

        XCTAssertEqual(streak, 3)
    }

    func testStreak_whenTodayMissing_shouldStartFromYesterday() {
        let vm = MainViewModel()

        let records = [
            makeRecord(daysAgo: 1),
            makeRecord(daysAgo: 2)
        ]

        let streak = vm.calculateStreakForTest(records: records)

        XCTAssertEqual(streak, 2)
    }

    func testStreak_whenNoContinuousDays_shouldReturnZero() {
        let vm = MainViewModel()

        let records = [
            makeRecord(daysAgo: 2),
            makeRecord(daysAgo: 4)
        ]

        let streak = vm.calculateStreakForTest(records: records)

        XCTAssertEqual(streak, 0)
    }

    // MARK: - Helper
    private func makeRecord(daysAgo: Int) -> SavingRecord {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date())!

        return SavingRecord(
            id: Int.random(in: 1...1000),
            amount: 1000,
            userId: UUID(),
            emotionId: 1,
            memo: nil,
            category: "식비",
            createdAt: date,
            updatedAt: date
        )
    }
}
