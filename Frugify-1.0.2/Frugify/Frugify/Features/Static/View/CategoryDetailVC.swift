//
//  CategoryDetailVC.swift
//  Frugify
//
//  Created by VnPaz on 1/15/26.
//

import UIKit

final class CategoryDetailVC: UIViewController {

    // MARK: - ViewModel
    // 데이터 가져오기 + 가공 + Output 전달
    private let viewModel = CategoryDetailViewModel()

    // MARK: - UI

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    // scrollView 안에 들어가는 컨텐츠 컨테이너 (오토레이아웃 안정화)
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let headerCard: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 18
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.masksToBounds = true
        return view
    }()

    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "총 절약 금액"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    private let headerAmountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGreen
        label.textAlignment = .center
        label.text = "0원"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        return label
    }()

    private let listStack: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 18
        return stackView
    }()

    // MARK: - LifeCycle

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "카테고리별 내역"
        loadBackButton()

        setupUI()
        renderLoading()

        bindViewModel()

        // 화면 진입 시 데이터 로드 트리거 (실제 fetch/계산은 ViewModel이 담당)
        Task { [weak self] in
            guard let self else { return }
            await self.viewModel.refresh()
        }
    }

    // MARK: - Bind (ViewModel -> View)
    
    // ViewModel이 만든 Output을 받아서 화면에 그린다
    private func bindViewModel() {
        viewModel.onOutput = { [weak self] output in
            guard let self else { return }
            self.render(output)
        }
    }

    // MARK: - UI Layout
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(headerCard)
        headerCard.addSubview(headerTitleLabel)
        headerCard.addSubview(headerAmountLabel)

        contentView.addSubview(listStack)

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

            headerCard.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            headerTitleLabel.topAnchor.constraint(equalTo: headerCard.topAnchor, constant: 18),
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerTitleLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),

            headerAmountLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 8),
            headerAmountLabel.leadingAnchor.constraint(equalTo: headerCard.leadingAnchor, constant: 16),
            headerAmountLabel.trailingAnchor.constraint(equalTo: headerCard.trailingAnchor, constant: -16),
            headerAmountLabel.bottomAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: -18),

            listStack.topAnchor.constraint(equalTo: headerCard.bottomAnchor, constant: 18),
            listStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            listStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            listStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
        ])
    }

    // MARK: - Render

    // 로딩 상태 UI (데이터 fetch 전에 잠깐 보여주기)
    private func renderLoading() {
        headerAmountLabel.text = "불러오는 중…"

        // 기존 리스트 제거
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let label = UILabel()
        label.text = "카테고리별 통계를 불러오는 중이에요."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        listStack.addArrangedSubview(label)
    }

    // ViewModel Output을 받아서 최종 UI를 구성한다
    private func render(_ output: CategoryDetailViewModel.Output) {
        // 상단 총액 갱신
        headerAmountLabel.text = Self.formatWon(output.totalAmount)

        // 기존 리스트 제거
        listStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 데이터가 없으면 Empty UI
        if output.items.isEmpty {
            let empty = UILabel()
            empty.text = "아직 절약 기록이 없어요."
            empty.textColor = .secondaryLabel
            empty.font = .systemFont(ofSize: 15)
            empty.textAlignment = .center
            empty.numberOfLines = 0
            listStack.addArrangedSubview(empty)
            return
        }

        // 카테고리별 BarView 생성/추가
        for item in output.items {
            let row = CategoryBarView()
            row.configure(item: item)
            listStack.addArrangedSubview(row)
        }
    }

    // MARK: - 금액(정수)을 “1,234원” 형태로 포맷

    private static func formatWon(_ value: Int) -> String {
        let numFormatter = NumberFormatter()
        numFormatter.numberStyle = .decimal
        let formattedAmount = numFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
        return "\(formattedAmount)원"
    }
}
