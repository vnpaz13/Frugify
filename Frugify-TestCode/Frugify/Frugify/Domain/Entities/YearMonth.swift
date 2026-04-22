//
//  YearMonth.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import Foundation

struct YearMonth: Equatable, Hashable {
    let year: Int
    let month: Int  // 1...12

    var titleKR: String { "\(year)년 \(month)월" }

    static func from(_ date: Date, calendar: Calendar = .current) -> YearMonth {
        let calendar = calendar.dateComponents([.year, .month], from: date)
        return .init(year: calendar.year!, month: calendar.month!)
    }

    func startDate(calendar: Calendar = .current) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: 1))!
    }

    func endDate(calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .month, value: 1, to: startDate(calendar: calendar))!
    }

    static func makeAvailableMonths(from createdAt: Date, to now: Date, calendar: Calendar = .current) -> [YearMonth] {
        let start = YearMonth.from(createdAt, calendar: calendar)
        let end = YearMonth.from(now, calendar: calendar)

        var resultMonth: [YearMonth] = []
        var current = start

        while true {
            resultMonth.append(current)
            if current == end { break }
            let next = calendar.date(byAdding: .month, value: 1, to: current.startDate(calendar: calendar))!
            current = YearMonth.from(next, calendar: calendar)
        }
        return resultMonth
    }
}

// (KST 기준 월 → UTC Date로 변환)
extension YearMonth {
    func monthRange(in timeZone: TimeZone) -> (start: Date, end: Date) {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone

        // year/month로 해당 월 1일 00:00(KST)
        var comps = DateComponents()
        comps.year = year
        comps.month = month
        comps.day = 1
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        let start = cal.date(from: comps)!

        // 다음 달 1일 00:00(KST)
        let end = cal.date(byAdding: .month, value: 1, to: start)!

        return (start, end)
    }
}
