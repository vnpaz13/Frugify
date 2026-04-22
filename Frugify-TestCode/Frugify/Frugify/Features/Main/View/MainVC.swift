//
//  MainVC.swift
//  Frugify
//
//  Created by VnPaz on 1/1/26.
//

import UIKit

@MainActor
final class MainVC: UIViewController {
    
    private let viewModel = MainViewModel()    
    private var nicknameObserver: NSObjectProtocol?

    // MARK: - 스크롤뷰, 컨텐트뷰, 스택뷰 설정
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .systemBackground
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    // Sections (화면을 요소 별로 쪼갰음)
    private let headerView = MainHeader()
    private let newRecordView = MainNewRecord()
    private let todaySaveView = MainTodaySave()
    private let todayRecordListView = MainTodayRecordList()
    
    private var dateTimer: Timer?
    
    private var headerTitle: String = "절약 기록"
    
    private static let headerDateFormatter: DateFormatter = {
        let dateF = DateFormatter()
        dateF.locale = Locale(identifier: "ko_KR")
        dateF.dateFormat = "yyyy년 M월 d일 (E)"
        return dateF
    }()
    
    
    // MARK: - Streak Badge 계산
    private var streakDays: Int = 0
    
    private func fetchStreakAndApply() {
        Task { [weak self] in
            guard let self else { return }
            let streak = await self.viewModel.fetchStreakDays()
            
            self.streakDays = streak
            self.updateHeaderDate()
            
        }
    }
    
    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated)
        updateHeaderDate()
        fetchStreakAndApply()
        fetchTodayRecordsAndApply()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newRecordView.onSubmit = { [weak self] record in
            guard let self else { return }
            print("MainVC received:", record)
            
            Task {
                do {
                    let saved = try await self.viewModel.createSavingRecord(record)
                    self.fetchStreakAndApply()
                    self.fetchTodayRecordsAndApply()
                    print("saved:", saved)
                } catch {
                    print("createSavingRecord error:", error)
                }
            }
        }
        
        newRecordView.onBeginEditing = { [weak self] in
            guard let self else { return }

            // 키보드 애니메이션/레이아웃 갱신 후 스크롤
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                guard let self else { return }
                self.view.layoutIfNeeded()
                self.resetSaveVisible(animated: true)
            }
        }
        
        view.backgroundColor = .systemBackground
        
        setupLayout()
        moveToTodayEntire()
        startDateTimer()
        fetchNicknameAndApply()
        bindTodayRecordDelete()
        keyboardDismissGesture()
        
        // 닉네임 변경시 닉네임 받아오기
        nicknameObserver = NotificationCenter.default.addObserver(
            forName: .nicknameDidChange,
            object: nil,
            queue: .main
        ) { [weak self] note in
            guard let self else { return }

            Task { @MainActor in
                if let nickname = note.userInfo?["nickname"] as? String {
                    self.headerTitle = "\(nickname)님의 절약 기록"
                    self.updateHeaderDate()
                }
            }
        }
    }
    
    deinit {
        dateTimer?.invalidate()
        if let nicknameObserver {
            NotificationCenter.default.removeObserver(nicknameObserver)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        newRecordView.resetToInitialState(animated: false)
    }
    
    private func setupLayout() {
        view.addSubview(headerView)
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 66),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
        
        // 섹션 순서대로 쌓기
        stackView.addArrangedSubview(newRecordView)
        stackView.addArrangedSubview(todaySaveView)
        stackView.addArrangedSubview(todayRecordListView)
    }
    
    // MARK: - 오늘의 전체기록 이동 함수
    private func moveToTodayEntire() {
        todayRecordListView.onTapMore = { [weak self] in
            guard let self else { return }
            let todayEntireVC = TodayEntireVC()
            todayEntireVC.hidesBottomBarWhenPushed = true
            todayEntireVC.records = self.viewModel.todayRecords
            self.navigationController?.pushViewController(todayEntireVC, animated: true)
        }
    }
    
    // MARK: - Header
    private func updateHeaderDate() {
        let dateText = Self.headerDateFormatter.string(from: Date())
        headerView.render(title: headerTitle, dateText: dateText, streakDays: streakDays)
    }
    
    private func startDateTimer() {
        dateTimer?.invalidate()
        dateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateHeaderDate()
            }
        }
    }
    
    private func fetchNicknameAndApply() {
        Task { [weak self] in
            guard let self else { return }
            let nickname = await self.viewModel.fetchNickname() ?? "사용자"
            
            self.headerTitle = "\(nickname)님의 절약 기록"
            self.updateHeaderDate()
            
        }
    }
    
    // MARK: - 오늘 기록 상태를 화면에 반영
    private func fetchTodayRecordsAndApply() {
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.refreshTodayRecords()
            
            let hasToday = self.viewModel.hasTodayRecords()
            let records = self.viewModel.todayRecords
            
            // 1) 상태 반영: 기록이 있으면 도넛 카드(요약) 보여주기
            self.todaySaveView.apply(hasTodayRecords: hasToday)
            
            // 2) 도넛 데이터는 "기록이 있을 때" 무조건 업데이트
            if hasToday {
                let donutItems = self.viewModel.makeTodayDonutItems()
                let totalAmount = self.viewModel.todayTotalAmount()
                let recordCount = self.viewModel.todayRecordCount()
                
                self.todaySaveView.applyDonut(
                    items: donutItems,
                    totalAmount: totalAmount,
                    recordCount: recordCount
                )
            }
            
            // 3) 리스트 반영
            self.todayRecordListView.apply(records: records)
        }
    }
    
    // MARK: - 절약 기록 삭제 반영
    private func bindTodayRecordDelete() {
        todayRecordListView.onTapDelete = { [weak self] record, completion in
            guard let self else { completion(false)
                return }
            
            let alert = UIAlertController(
                title: "기록을 삭제하시겠습니까?",
                message: "삭제하면 복구할 수 없어요.",
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel) { _ in
                completion(false)
            })
            
            alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
                guard let self else { completion(false)
                    return }
                Task {
                    do {
                        try await self.viewModel.deleteSavingRecord(id: record.id)
                        self.fetchStreakAndApply()
                        self.fetchTodayRecordsAndApply()
                        completion(true)
                    } catch {
                        print("삭제 실패:", error)
                        completion(false)
                    }
                }
            })
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - 기록 삭제 알림창
    private func presentDeleteConfirm(for record: SavingRecord) {
        let alert = UIAlertController(
            title: "기록을 삭제하시겠습니까?",
            message: "삭제하면 복구할 수 없어요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            guard let self else { return }
            Task {
                do {
                    try await self.viewModel.deleteSavingRecord(id: record.id)
                    self.fetchStreakAndApply()
                    self.fetchTodayRecordsAndApply()
                } catch {
                    print("삭제 실패:", error)
                    self.presentDeleteError()
                }
            }
        })
        
        present(alert, animated: true)
    }
    
    private func presentDeleteError() {
        let alert = UIAlertController(
            title: "삭제에 실패했어요",
            message: "잠시 후 다시 시도해 주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - 스크롤 올리기
    func scrollToTop(animated: Bool) {
        scrollView.setContentOffset(.zero, animated: animated)
    }
    
    private func resetSaveVisible(animated: Bool = true) {
        // MainNewRecord 안의 버튼 스택을 타겟으로
        let targetView = newRecordView.getButtonStack()
        // targetView의 rect를 scrollView 좌표계로 변환
        let targetRect = targetView.convert(targetView.bounds, to: scrollView)
        // 현재 scrollView의 보이는 영역
        let visibleRect = CGRect(
            origin: scrollView.contentOffset,
            size: scrollView.bounds.size
        )
        
        let padding: CGFloat = 16
        let paddedRect = targetRect.insetBy(dx: 0, dy: -padding)
        // 이미 완전히 보이면 스킵
        guard !visibleRect.contains(paddedRect) else { return }

        scrollView.scrollRectToVisible(paddedRect, animated: animated)
    }

}

