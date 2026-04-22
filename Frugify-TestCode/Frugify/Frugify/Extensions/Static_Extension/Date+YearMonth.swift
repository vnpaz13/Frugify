//
//  Date+YearMonth.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//
// Date를 YearMonth로 바꿈 -> 월별 필터링 / 월 목록 생성에서 매번 Calendar 코드 반복 없어짐

import Foundation

extension Date {
    var yearMonth: YearMonth {
        let cal = Calendar.current
        return YearMonth(
            year: cal.component(.year, from: self),
            month: cal.component(.month, from: self)
        )
    }
}
