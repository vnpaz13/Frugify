//
//  CategoryDetailViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/16/26.
//
import UIKit

@MainActor
final class CategoryDetailViewModel {

    // MARK: - Output (View에 전달할 결과 묶음)
    // ViewController가 이 데이터를 받아서 화면에 뿌림
    struct Output {
        let totalAmount: Int          // 전체 절약 금액
        let items: [CategoryBarItem]  // 카테고리별 바 그래프 데이터
    }

    // ViewController가 구독하는 콜백
    var onOutput: ((Output) -> Void)?

    // MARK: - 카테고리 매핑
    // 서버에서 오는 문자열 category -> 앱 내부 SaveCategory로 변환하기 위함
    private let categoryMap: [String: SaveCategory] =
        Dictionary(uniqueKeysWithValues: SaveCategory.all.map { ($0.title, $0) })

    // MARK: - Public API
    // VC에서 호출하는 유일한 함수
    func refresh() async {
        do {
            // 서버에서 내 모든 기록 가져오기
            let records = try await SupabaseManager.shared.fetchAllMyRecords()

            // 화면에 필요한 데이터로 가공
            let output = buildOutput(from: records)

            // 결과를 VC로 전달
            onOutput?(output)
        } catch {
            // 에러가 나면 빈 상태로 전달 (화면 크래시 방지)
            onOutput?(.init(totalAmount: 0, items: []))
        }
    }

    // MARK: - 데이터 가공 로직
    // 기록 배열 -> 카테고리 통계 결과
    private func buildOutput(from records: [SavingRecord]) -> Output {

        // 전체 절약 금액 계산
        let totalAmount = records.reduce(0) { $0 + $1.amount }

        // 카테고리별 금액 합산
        var categoryAmountMap: [String: Int] = [:]
        for record in records {
            categoryAmountMap[record.category, default: 0] += record.amount
        }

        // 금액이 큰 순서대로 정렬
        let sorted = categoryAmountMap.sorted { $0.value > $1.value }

        // 화면에서 쓰는 CategoryBarItem으로 변환
        let items: [CategoryBarItem] = sorted.map { (rawCategory, amount) in
            let ratio = totalAmount == 0 ? 0 : Double(amount) / Double(totalAmount)
            let category = categoryMap[rawCategory]

            return CategoryBarItem(
                category: category?.title ?? rawCategory, // 표시 이름
                amount: amount,                           // 금액
                ratio: ratio,                             // 비율
                color: category?.color ?? .systemGray     // 표시 색상
            )
        }

        return Output(
            totalAmount: totalAmount,
            items: items
        )
    }
}
