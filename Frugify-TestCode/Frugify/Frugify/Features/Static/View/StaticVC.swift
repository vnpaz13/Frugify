//
//  StaticVC.swift
//  Frugify
//
//  Created by VnPaz on 1/1/26.
//

import UIKit

final class StaticVC: UIViewController {

    // MARK: - 의존성 (ViewModel)
    private let viewModel = StaticViewModel()

    // MARK: - ScrollView 구성
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true 
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - 컴포넌트
    // 전체 요약 카드 (총 절약 금액 / 기록 수)
    private let summaryCard = SummaryCardView()

    // 월별 요약 카드 (월 선택 + 카테고리별 금액)
    private let monthlyCard = MonthlySummaryCardView()

    // 감정 Top 3 요약 뷰
    private let emotionTopView = EmotionTopView()

    // 감정 전체 통계 시트에서 사용할 Row 데이터
    private var allEmotionStatsRows: [EmotionStatRow] = []
    
    // 감정 별 절약 금액 뷰
    private let emotionAmountView = EmotionAmountCardView()

    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated)

        // 화면 진입 시 모든 통계 데이터 갱신
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.refreshAll()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        bindActions()
    }

    // MARK: - ViewModel 바인딩
    // ViewModel -> View 로 데이터 전달 바인딩
    private func bindViewModel() {
        // 전체 요약 데이터 바인딩
        viewModel.onSummary = { [weak self] output in
            guard let self else { return }

            self.summaryCard.configure(
                totalAmount: output.totalAmount,
                count: output.count
            )
        }

        // 선택 가능한 월 목록 바인딩
        viewModel.onMonths = { [weak self] output in
            guard let self else { return }

            self.monthlyCard.setAvailableMonths(
                output.availableMonths,
                selected: output.selectedMonth
            )
        }

        // 선택된 월의 월별 통계 바인딩
        viewModel.onMonthly = { [weak self] output in
            guard let self else { return }

            self.monthlyCard.render(
                totalAmount: output.totalAmount,
                items: output.items,
                count: output.count
            )
        }

        // 감정 통계 데이터 바인딩
        viewModel.onEmotion = { [weak self] output in
            guard let self else { return }

            // 전체 감정 통계 Row 저장 (시트에서 사용)
            self.allEmotionStatsRows = output.allRows

            // Top 3 감정 요약 뷰 갱신
            self.emotionTopView.configure(
                topThreeEmotions: output.topThreeEmotions,
                totalEmotionKinds: output.totalEmotionKinds
            )
        }
        
        // 감정 별 금액 데이터 바인딩
        viewModel.onEmotionAmount = { [weak self] output in
            guard let self else { return }

            let rows = output.all.map { (title: $0.emotion.title, amount: $0.amount) }
            self.emotionAmountView.render(rows: rows)
        }
    }

    // MARK: - 사용자 액션 바인딩
    // UI 이벤트 -> 화면 전환 / ViewModel 액션 처리
    private func bindActions() {
        // 요약 카드에서 카테고리 상세로 이동
        summaryCard.onTapCategory = { [weak self] in
            guard let self else { return }

            let vc = CategoryDetailVC()
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }

        // 월 선택 시 ViewModel에 선택 월 전달
        monthlyCard.onSelectMonth = { [weak self] ym in
            guard let self else { return }

            Task { [weak self] in
                guard let self else { return }
                await self.viewModel.selectMonth(ym)
            }
        }

        // 감정 전체 보기 버튼 -> Bottom Sheet 표시
        emotionTopView.onTapAllButton = { [weak self] in
            guard let self else { return }

            let sheetVC = EmotionAllStatsSheetVC(
                rows: self.allEmotionStatsRows
            )

            // iOS Sheet 설정
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 18
            }

            self.present(sheetVC, animated: true)
        }
        
        emotionAmountView.onToggleExpand = { [weak self] isExpanded in
            guard let self else { return }
            guard isExpanded else { return }

            // contentSize 갱신 이후에 스크롤 먹이기
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                self.scrollView.layoutIfNeeded()

                let rectInScroll = self.emotionAmountView.convert(self.emotionAmountView.bounds, to: self.scrollView)

                let visibleHeight = self.scrollView.bounds.height
                - self.scrollView.adjustedContentInset.top
                - self.scrollView.adjustedContentInset.bottom

                let targetY = max(-self.scrollView.adjustedContentInset.top,
                                  rectInScroll.maxY - visibleHeight + 16)

                self.scrollView.setContentOffset(CGPoint(x: 0, y: targetY), animated: true)
            }
        }

    }

    // MARK: - 레이아웃 설정
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(summaryCard)
        contentView.addSubview(monthlyCard)
        contentView.addSubview(emotionTopView)
        contentView.addSubview(emotionAmountView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            summaryCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            summaryCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            summaryCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            monthlyCard.topAnchor.constraint(equalTo: summaryCard.bottomAnchor, constant: 22),
            monthlyCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            monthlyCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            emotionTopView.topAnchor.constraint(equalTo: monthlyCard.bottomAnchor, constant: 22),
            emotionTopView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emotionTopView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emotionAmountView.topAnchor.constraint(equalTo: emotionTopView.bottomAnchor, constant: 22),
            emotionAmountView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emotionAmountView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emotionAmountView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
           
        ])
    }
    
    // MARK: - 스크롤 올리기
    func scrollToTop(animated: Bool) {
        scrollView.setContentOffset(.zero, animated: animated)
    }
}

