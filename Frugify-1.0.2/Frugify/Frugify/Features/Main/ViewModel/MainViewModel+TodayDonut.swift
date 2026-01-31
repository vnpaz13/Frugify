//
//  MainViewModel+TodayDonut.swift
//  Frugify
//
//  Created by VnPaz on 1/11/26.
//

import UIKit

extension MainViewModel {

    // MARK: - 오늘 총 절약 금액
    func todayTotalAmount() -> Int {
        return todayRecords.reduce(0) { $0 + $1.amount }
    }

    // MARK: - 오늘 기록 수
    func todayRecordCount() -> Int {
        return todayRecords.count
    }

    // MARK: - 오늘 도넛 데이터 생성 (카테고리별 합계 + 색상)
    func makeTodayDonutItems() -> [TodayDonutItem] {
        guard !todayRecords.isEmpty else { return [] }

        var sums: [String: Int] = [:]
        for record in todayRecords {
            if record.amount == 0 { continue }
            sums[record.category, default: 0] += record.amount
        }

        // 카테고리 색상 매핑
        let colorMap: [String: UIColor] = Dictionary(
            uniqueKeysWithValues: SaveCategory.all.map { ($0.title, $0.color) }
        )

        var items = sums.map { (title, amount) in
            TodayDonutItem(title: title, amount: amount, color: colorMap[title] ?? .systemGray3)
        }

        // 큰 금액부터 위로
        items.sort { $0.amount > $1.amount }
        return items
    }
}
