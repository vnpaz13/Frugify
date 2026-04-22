//
//  FrugifyTests.swift
//  FrugifyTests
//
//  Created by VnPaz on 12/24/25.
//

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

    // MARK: - TestCase
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


// MARK: - TEST CODE　(MainViewModel)
//func calculateStreakForTest(records: [SavingRecord]) -> Int {
//    let calendar = Calendar.current
//    
//    let todayStart = calendar.startOfDay(for: Date())
//    let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart)!
//    
//    let recordedDays: Set<Date> = Set(
//        records.map { calendar.startOfDay(for: $0.createdAt) }
//    )
//    
//    let baseDay: Date
//    if recordedDays.contains(todayStart) {
//        baseDay = todayStart
//    } else {
//        guard recordedDays.contains(yesterdayStart) else { return 0 }
//        baseDay = yesterdayStart
//    }
//    
//    var streak = 0
//    
//    while true {
//        guard let day = calendar.date(byAdding: .day, value: -streak, to: baseDay) else { break }
//        
//        if recordedDays.contains(day) {
//            streak += 1
//        } else {
//            break
//        }
//    }
//    
//    return streak
//}
