//
//  StatisticsCalculator.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//

import Foundation

protocol StatisticsCalculating {

    // 유저 가입월 ~ 현재월의 "모든 월" 생성
    func makeAvailableYearMonths(userCreatedAt: Date, now: Date) -> [YearMonth]

    // 전체 요약
    func makeTotalSummary(from records: [SavingRecord]) -> SavingSummary

    // 전체 카테고리별
    func makeCategoryStatsAll(from records: [SavingRecord]) -> [CategoryStatItem]

    // 월별 요약(선택된 yearMonth)
    func makeMonthlySummary(from records: [SavingRecord], yearMonth: YearMonth) -> MonthlySummary

    // 감정 카운팅
    func makeEmotionCounts(from records: [SavingRecord]) -> [EmotionStatItem]

    // 전체 기록
    func makeEntireRecords(from records: [SavingRecord]) -> [SavingRecord]
}



final class StatisticsCalculator: StatisticsCalculating {

    // 가입일 ~ 현재월까지 "연속된 월" 생성
    func makeAvailableYearMonths(userCreatedAt: Date, now: Date) -> [YearMonth] {
        _ = Calendar.current
        let start = userCreatedAt.yearMonth
        let end = now.yearMonth

        // start가 end보다 미래면(이상 케이스) end만 반환
        if (start.year, start.month) > (end.year, end.month) {
            return [end]
        }

        var result: [YearMonth] = []
        var year = start.year
        var month = start.month

        while true {
            result.append(YearMonth(year: year, month: month))

            if year == end.year && month == end.month { break }

            month += 1
            if month == 13 {
                month = 1
                year += 1
            }
        }
        return result
    }

    // 전체 요약
    func makeTotalSummary(from records: [SavingRecord]) -> SavingSummary {
        let total = records.reduce(0) { $0 + $1.amount }
        return SavingSummary(totalAmount: total, totalCount: records.count)
    }

    // 전체 카테고리별
    func makeCategoryStatsAll(from records: [SavingRecord]) -> [CategoryStatItem] {
        // category(title) -> amount
        var sums: [SaveCategory: Int] = [:]

        for r in records {
            guard let cat = SaveCategory.byTitle(r.category) else { continue }
            sums[cat, default: 0] += r.amount
        }

        let total = sums.values.reduce(0, +)

        let items: [CategoryStatItem] = sums
            .map { (cat, amount) in
                let ratio = total == 0 ? 0 : Double(amount) / Double(total)
                let percent = ratio * 100
                return CategoryStatItem(category: cat, amount: amount, ratio: ratio, percent: percent)
            }
            .sorted { $0.amount > $1.amount }

        return items
    }

    // 월별 요약
    func makeMonthlySummary(from records: [SavingRecord], yearMonth: YearMonth) -> MonthlySummary {
        let monthlyRecords = records.filter { $0.createdAt.yearMonth == yearMonth }

        let amount = monthlyRecords.reduce(0) { $0 + $1.amount }
        let count = monthlyRecords.count

        let categoryStats = makeCategoryStatsAll(from: monthlyRecords)

        return MonthlySummary(
            yearMonth: yearMonth,
            amount: amount,
            count: count,
            categoryStats: categoryStats
        )
    }

    func makeEmotionCounts(from records: [SavingRecord]) -> [EmotionStatItem] {
        var countsById: [Int: Int] = [:]
        for r in records {
            countsById[r.emotionId, default: 0] += 1
        }

        let items: [EmotionStatItem] = countsById.compactMap { (id, count) in
            guard count > 0, let emo = SaveEmotion.byId(id) else { return nil }
            return EmotionStatItem(emotion: emo, count: count)
        }

        // 추천: 많이 선택된 감정이 먼저 보이게
        return items.sorted { $0.count > $1.count }
    }


    // 전체 기록 정렬 (최신순)
    func makeEntireRecords(from records: [SavingRecord]) -> [SavingRecord] {
        records.sorted { $0.createdAt > $1.createdAt }
    }
}
