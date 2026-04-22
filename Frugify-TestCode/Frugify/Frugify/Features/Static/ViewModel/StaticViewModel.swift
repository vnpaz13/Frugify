//
//  StaticViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

// MARK: - 월별 카테고리 바 차트 아이템
struct CategoryBarItem {
    let category: String
    let amount: Int
    let ratio: Double      // 0.0 ~ 1.0
    let color: UIColor
}

@MainActor
final class StaticViewModel {

    // MARK: - Output (VC로 전달되는 출력 모델)
    struct SummaryOutput {
        let totalAmount: Int
        let count: Int
    }

    struct MonthsOutput {
        let availableMonths: [YearMonth]
        let selectedMonth: YearMonth
    }

    struct MonthlyOutput {
        let totalAmount: Int
        let count: Int
        let items: [CategoryBarItem]
        let selectedMonth: YearMonth
    }

    struct EmotionOutput {
        let topThreeEmotions: [(emotion: SaveEmotion, count: Int)]
        let totalEmotionKinds: Int
        let allRows: [EmotionStatRow]
    }
    
    struct EmotionAmountOutput {
        let topThree: [(emotion: SaveEmotion, amount: Int)]
        let all: [(emotion: SaveEmotion, amount: Int)]
    }

    // MARK: - Bind (VC에서 바인딩하는 콜백)
    var onSummary: ((SummaryOutput) -> Void)?
    var onMonths: ((MonthsOutput) -> Void)?
    var onMonthly: ((MonthlyOutput) -> Void)?
    var onEmotion: ((EmotionOutput) -> Void)?
    var onEmotionAmount: ((EmotionAmountOutput) -> Void)?

    // MARK: - 상태 (ViewModel 내부 상태)
    private(set) var availableMonths: [YearMonth] = []
    private(set) var selectedMonth: YearMonth = .from(Date())
    private(set) var allEmotionStatsRows: [EmotionStatRow] = []

    // MARK: - 매핑 (표시용 데이터 변환)
    // 카테고리명(String) -> SaveCategory
    private let categoryMap: [String: SaveCategory] = Dictionary(
        uniqueKeysWithValues: SaveCategory.all.map { ($0.title, $0) }
    )

    // 감정 id(Int) -> SaveEmotion
    private let emotionMapById: [Int: SaveEmotion] = Dictionary(
        uniqueKeysWithValues: SaveEmotion.all.map { ($0.id, $0) }
    )

    // 상위 3개 감정 랭크 메달 색상 (금/은/동)
    private let medalColors: [UIColor] = [
        UIColor(red: 0.83, green: 0.69, blue: 0.22, alpha: 1.0), // Gold
        UIColor(red: 0.66, green: 0.66, blue: 0.66, alpha: 1.0), // Silver
        UIColor(red: 0.75, green: 0.52, blue: 0.35, alpha: 1.0)  // Bronze
    ]

    // MARK: - 공개 API
    /// 화면 진입 시 필요한 모든 통계를 갱신하고 VC로 출력
    func refreshAll() async {
        // 전체 기록을 한 번 가져와서 요약/감정 계산에 재사용
        let allRecords = await fetchAllRecordsSafely()
        renderSummary(with: allRecords)

        // 월 리스트(선택 가능한 월) 준비
        await bootstrapMonthsIfNeeded()

        // 선택 월 기준 월별 통계 로드
        await loadMonthlyAndRender(selectedMonth)

        // 감정 Top/전체 랭킹 계산
        renderEmotion(with: allRecords)
        
        // 감정 별 금액 계산
        renderEmotionAmount(with: allRecords)

    }

    /// 월을 선택했을 때 월별 통계만 새로 로드
    func selectMonth(_ ym: YearMonth) async {
        selectedMonth = ym
        await loadMonthlyAndRender(ym)
    }

    // MARK: - Fetch Helper (데이터 가져오기)
    /// 전체 기록을 안전하게 가져오기 (실패하면 빈 배열 반환)
    private func fetchAllRecordsSafely() async -> [SavingRecord] {
        do {
            return try await SupabaseManager.shared.fetchAllMyRecords()
        } catch {
            return []
        }
    }

    // MARK: - 요약 (전체 합계/건수)
    /// 전체 기록으로 요약 카드(총합/건수) 출력
    private func renderSummary(with records: [SavingRecord]) {
        let total = records.reduce(0) { $0 + $1.amount }
        onSummary?(.init(totalAmount: total, count: records.count))
    }

    // MARK: - 월 목록 (선택 가능한 월 생성)
    /// 사용자 가입일 ~ 현재까지의 월 리스트를 생성 
    private func bootstrapMonthsIfNeeded() async {
        guard availableMonths.isEmpty else {
            onMonths?(.init(availableMonths: availableMonths, selectedMonth: selectedMonth))
            return
        }

        do {
            let createdAt = try await SupabaseManager.shared.fetchMyCreatedAt()
            let now = Date()

            // 가입일 ~ 현재까지 월 생성
            availableMonths = YearMonth.makeAvailableMonths(from: createdAt, to: now)

            // 기본 선택 월은 "현재 월" (없으면 마지막 월)
            let current = YearMonth.from(now)
            selectedMonth = availableMonths.contains(current) ? current : (availableMonths.last ?? current)

            onMonths?(.init(availableMonths: availableMonths, selectedMonth: selectedMonth))
        } catch {
            // 가입일 조회 실패 시: 현재 월만 제공
            let current = YearMonth.from(Date())
            availableMonths = [current]
            selectedMonth = current
            onMonths?(.init(availableMonths: availableMonths, selectedMonth: current))
        }
    }

    // MARK: - 월별 통계 (카테고리 바 차트)
    // 선택한 월의 기록을 가져와 월별 총합/카테고리 비율 아이템을 출력
    private func loadMonthlyAndRender(_ ym: YearMonth) async {
        do {
            // 1) KST 기준 월 시작/끝 만들기
            let kst = TimeZone(identifier: "Asia/Seoul")!
            let (startKST, endKST) = ym.monthRange(in: kst)
            
            // 2) 그 Date를 그대로 Supabase 쿼리에 사용 (Date는 절대시간이라 OK)
            let rows = try await SupabaseManager.shared.fetchRecords(from: startKST, to: endKST)

            let totalAmount = rows.reduce(0) { $0 + $1.amount }
            let items = buildCategoryItems(from: rows, totalAmount: totalAmount)

            onMonthly?(.init(totalAmount: totalAmount, count: rows.count, items: items, selectedMonth: ym))
        } catch {
            onMonthly?(.init(totalAmount: 0, count: 0, items: [], selectedMonth: ym))
        }
    }

    /// 월별 기록을 카테고리별로 합산하여 그래프 아이템 목록 생성
    private func buildCategoryItems(from rows: [SavingRecord], totalAmount: Int) -> [CategoryBarItem] {
        var map: [String: Int] = [:]

        // 카테고리별 합산
        for record in rows {
            map[record.category, default: 0] += record.amount
        }

        // 금액 내림차순 정렬
        let sorted = map.sorted { $0.value > $1.value }

        // 표시용 모델로 변환
        return sorted.map { (raw, amount) in
            let ratio = totalAmount == 0 ? 0 : Double(amount) / Double(totalAmount)
            let cate = categoryMap[raw]

            return CategoryBarItem(
                category: cate?.title ?? raw,
                amount: amount,
                ratio: ratio,
                color: cate?.color ?? .systemGray
            )
        }
    }

    // MARK: - 감정 통계 (Top3 / 전체 랭킹)
    /// 전체 기록을 기반으로 감정별 횟수/랭킹을 계산해 출력
    private func renderEmotion(with records: [SavingRecord]) {
        guard !records.isEmpty else {
            allEmotionStatsRows = []
            onEmotion?(.init(topThreeEmotions: [], totalEmotionKinds: 0, allRows: []))
            return
        }

        // 감정별 횟수 집계
        var emotionCountMap: [Int: Int] = [:]
        for record in records {
            emotionCountMap[record.emotionId, default: 0] += 1
        }

        // 감정 종류 수
        let totalEmotionKinds = emotionCountMap.count

        // 횟수 내림차순 정렬
        let sorted = emotionCountMap.sorted { $0.value > $1.value }

        // Top3 감정
        let topThreeEmotions: [(SaveEmotion, Int)] = sorted
            .prefix(3)
            .compactMap { (emotionId, count) in
                guard let emotion = emotionMapById[emotionId] else { return nil }
                return (emotion, count)
            }

        // 전체 랭킹 Row 생성
        allEmotionStatsRows = sorted.enumerated().compactMap { (index, element) in
            let emotionId = element.key
            let count = element.value

            guard let emotion = emotionMapById[emotionId] else { return nil }

            let rank = index + 1
            let medalColor: UIColor? = (rank <= 3) ? medalColors[rank - 1] : nil

            return EmotionStatRow(
                rank: rank,
                title: emotion.title,
                countText: "\(count)회",
                medalColor: medalColor
            )
        }

        // VC로 출력
        onEmotion?(.init(
            topThreeEmotions: topThreeEmotions,
            totalEmotionKinds: totalEmotionKinds,
            allRows: allEmotionStatsRows
        ))
    }
    
    private func renderEmotionAmount(with records: [SavingRecord]) {
        guard !records.isEmpty else {
            onEmotionAmount?(.init(topThree: [], all: []))
            return
        }

        // emotionId별 금액 합산
        var amountMap: [Int: Int] = [:]
        for record in records {
            amountMap[record.emotionId, default: 0] += record.amount
        }

        // 금액 내림차순 정렬
        let sorted: [(SaveEmotion, Int)] = amountMap
            .sorted { $0.value > $1.value }
            .compactMap { (emotionId, amount) in
                guard let emotion = emotionMapById[emotionId] else { return nil }
                return (emotion, amount)
            }

        let topThree = Array(sorted.prefix(3))
        onEmotionAmount?(.init(topThree: topThree, all: sorted))
    }

}
