//
// MainNewRecord.swift
// Frugify
//
// Created by VnPaz on 1/3/26.
//

import UIKit

final class MainNewRecord: UIView {
    // MARK: - MainVC로 넘겨주기
    var onSubmit: ((NewSavingRecord) -> Void)?
    var onBeginEditing: (() -> Void)?
    
    // MARK: - 접힌 카드 Property
    private let newSaveCard = UIView()
    private let iconView = UIImageView()
    private let titleLabel = UILabel()
    private let toggleButton = UIButton(type: .system)
    
    // MARK: - 구분선
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .cardBorder
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - 새 절약 기록 입력시 펼쳐졌을 때 요소들이 들어가는 스택뷰
    private let formStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()
    
    // MARK: - 감정 종류
    private let emotionLabel = UILabel()
    private let emotions = SaveEmotion.all
    
    // MARK: - 카테고리 종류
    private let categoryLabel = UILabel()
    private let categories = SaveCategory.all
    
    // MARK: - 선택한 감정 저장
    private var emotionCards: [EmotionCard] = []
    private var selectedEmotion: SaveEmotion?
    
    // MARK: - 선택한 카테고리 저장
    private var categoryCards: [CategoryCard] = []
    private var selectedCategory: SaveCategory?
    
    // MARK: - AmountMemo 받아오기
    private let amountMemo = AmountMemo()
    
    // MARK: - 초기화, 저장 버튼
    private let buttonStack = UIStackView()
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    // MARK: - 큰 틀
    private let formContainer = UIView()
    private var formHeight: NSLayoutConstraint!
    private var isExpanded = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("MainNewRecord init")
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupUI() {
        
        translatesAutoresizingMaskIntoConstraints = false
        // 카드
        newSaveCard.translatesAutoresizingMaskIntoConstraints = false
        newSaveCard.backgroundColor = .systemBackground
        newSaveCard.layer.cornerRadius = 16
        newSaveCard.layer.borderWidth = 1
        newSaveCard.layer.borderColor = UIColor.systemGray.cgColor
        
        // 헤더
        let headerRow = UIView()
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "pencil")
        iconView.tintColor = .basicGreen
        iconView.contentMode = .scaleAspectFit
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "새 절약 기록"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        toggleButton.translatesAutoresizingMaskIntoConstraints = false
        toggleButton.backgroundColor = .basicGreen
        toggleButton.tintColor = .white
        toggleButton.layer.cornerRadius = 12
        toggleButton.setImage(UIImage(systemName: "plus"), for: .normal)
        toggleButton.addTarget(self, action: #selector(toggle), for: .touchUpInside)
        
        // MARK: - 감정 선택 문구
        emotionLabel.text = "어떤 기분이세요?"
        emotionLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        emotionLabel.textColor = .textSecondary
        
        // MARK: - 카테고리 문구
        categoryLabel.text = "카테고리"
        categoryLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        categoryLabel.textColor = .textSecondary
        
        
        // MARK: - View 쌓기
        self.addSubview(newSaveCard)
        
        newSaveCard.addSubview(headerRow)
        headerRow.addSubview(iconView)
        headerRow.addSubview(titleLabel)
        headerRow.addSubview(toggleButton)
        newSaveCard.addSubview(separatorView)
        newSaveCard.addSubview(formContainer)
        formContainer.addSubview(formStack)
        formContainer.translatesAutoresizingMaskIntoConstraints = false
        formContainer.clipsToBounds = true
        formStack.translatesAutoresizingMaskIntoConstraints = false
        
        // MARK: - 새 기록 절약 접혀있을 때 치수 잡기
        NSLayoutConstraint.activate([
            newSaveCard.topAnchor.constraint(equalTo: topAnchor),
            newSaveCard.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            newSaveCard.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            newSaveCard.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            headerRow.topAnchor.constraint(equalTo: newSaveCard.topAnchor, constant: 18),
            headerRow.leadingAnchor.constraint(equalTo: newSaveCard.leadingAnchor, constant: 16),
            headerRow.trailingAnchor.constraint(equalTo: newSaveCard.trailingAnchor, constant: -16),
            headerRow.heightAnchor.constraint(equalToConstant: 24),
            
            iconView.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            iconView.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            
            toggleButton.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor),
            toggleButton.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 36),
            toggleButton.heightAnchor.constraint(equalToConstant: 36),
            
            separatorView.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: 19),
            separatorView.leadingAnchor.constraint(equalTo: newSaveCard.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: newSaveCard.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            formContainer.topAnchor.constraint(equalTo: headerRow.bottomAnchor, constant: 8),
            formContainer.leadingAnchor.constraint(equalTo: newSaveCard.leadingAnchor, constant: 16),
            formContainer.trailingAnchor.constraint(equalTo: newSaveCard.trailingAnchor, constant: -16),
            formContainer.bottomAnchor.constraint(equalTo: newSaveCard.bottomAnchor, constant: -12),
            
            formStack.topAnchor.constraint(equalTo: formContainer.topAnchor, constant: 24),
            formStack.leadingAnchor.constraint(equalTo: formContainer.leadingAnchor),
            formStack.trailingAnchor.constraint(equalTo: formContainer.trailingAnchor),
        ])
        
        formHeight = formContainer.heightAnchor.constraint(equalToConstant: 0)
        formHeight.isActive = true
        separatorView.isHidden = true
        
        // MARK: - formStack에 하나씩 쌓기
        
        // 감정선택
        let emotionCard = emotions.map { emotion -> EmotionCard in
            let card = EmotionCard(emotion: emotion)
            card.onTap = { [weak self] tappedCard in
                self?.selectEmotionCard(tappedCard)
            }
            return card
        }
        
        setEmotionCards(emotionCard)
        
        let emotionScroll = horizontalScrollView(
            height: 80,
            spacing: 12,
            items: emotionCard
        )
        
        let emotionStack = UIStackView(arrangedSubviews: [emotionLabel, emotionScroll])
        emotionStack.axis = .vertical
        emotionStack.spacing = 6
        emotionStack.alignment = .fill
        
        formStack.addArrangedSubview(emotionStack)
        
        // 카테고리 선택
        let firstRow = Array(categories.prefix(7))
        let secondRow = Array(categories.dropFirst(7))
        
        let firstCateCard = firstRow.map { category -> CategoryCard in
            let card = CategoryCard(category: category)
            card.onTap = { [weak self] tappedCard in
                self?.selectCategoryCard(tappedCard)
            }
            return card
        }
        
        let secondCateCard = secondRow.map { category -> CategoryCard in
            let card = CategoryCard(category: category)
            card.onTap = { [weak self] tappedCard in
                self?.selectCategoryCard(tappedCard)
            }
            return card
        }
        
        setCategoryCards(firstCateCard + secondCateCard)
        
        let firstCateScroll = horizontalScrollView(
            height: 36,
            spacing: 5,
            items: firstCateCard
        )
        
        let secondCateScroll = horizontalScrollView(
            height: 36,
            spacing: 5,
            items: secondCateCard
        )
        
        let categoryStack = UIStackView(arrangedSubviews: [categoryLabel, firstCateScroll, secondCateScroll])
        categoryStack.axis = .vertical
        categoryStack.spacing = 4
        categoryStack.alignment = .fill
        formStack.addArrangedSubview(categoryStack)
        
        // MARK: - 절약 금액 기입, 메모 기입 스택 쌓기
        formStack.addArrangedSubview(amountMemo)
        amountMemo.onAmountChanged = { [weak self] in
            self?.updateSaveButtonState()
        }
        
        amountMemo.onBeginEditing = { [weak self] in
            self?.onBeginEditing?()
        }
        
        // MARK: - 초기화 버튼, 저장 버튼 스택 쌓기
        setupButtons()
        formStack.addArrangedSubview(buttonStack)
        
        // MARK: - 저장 버튼 상태 체크
        updateSaveButtonState()
    }
}

// MARK: - Getter / Setter
extension MainNewRecord {
    
    // Emotion
    func getEmotionCards() -> [EmotionCard] { emotionCards }
    func setEmotionCards(_ cards: [EmotionCard]) { emotionCards = cards }
    func getSelectedEmotion() -> SaveEmotion? { selectedEmotion }
    func setSelectedEmotion(_ emotion: SaveEmotion?) { selectedEmotion = emotion }
    
    // Category
    func getCategoryCards() -> [CategoryCard] { categoryCards }
    func setCategoryCards(_ cards: [CategoryCard]) { categoryCards = cards }
    func getSelectedCategory() -> SaveCategory? { selectedCategory }
    func setSelectedCategory(_ category: SaveCategory?) { selectedCategory = category }
    
    // AmountMemo
    func getAmountText() -> String { amountMemo.amountText }
    func getMemoText() -> String { amountMemo.memoText }
    func resetAmountMemo() { amountMemo.reset() }
    
    // Buttons / UI elements
    func getButtonStack() -> UIStackView { buttonStack }
    func getCancelButton() -> UIButton { cancelButton }
    func getSaveButton() -> UIButton { saveButton }
    func getToggleButton() -> UIButton { toggleButton }
    func getSeparatorView() -> UIView { separatorView }
    func getFormHeight() -> NSLayoutConstraint { formHeight }
    
    // Expand state
    func getIsExpanded() -> Bool { isExpanded }
    func setIsExpanded(_ value: Bool) { isExpanded = value }
    
    
    // 새 절약 기록 폼을 접는다 (UI + 상태 동기화)
    func collapse(animated: Bool) {
        
        // 상태 먼저 접힘으로 변경
        setIsExpanded(false)
        
        // 접힌 상태 UI
        getSeparatorView().isHidden = true
        getToggleButton().setImage(
            UIImage(systemName: "plus"),
            for: .normal
        )
        
        // 높이를 0으로 만들어서 내용 숨김
        let heightConstraint = getFormHeight()
        heightConstraint.constant = 0
        
        // 레이아웃 반영 (필요하면 애니메이션)
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        } else {
            self.layoutIfNeeded()
        }
    }
    
    // 탭 이동 등으로 화면을 떠날 때: 접기 + 선택/입력값 초기화
    func resetToInitialState(animated: Bool = false) {
        // 1) 선택 초기화 (너가 이미 만들어둔 함수 재사용)
        resetEmotionSelection()
        resetCategorySelection()
        
        // 2) 입력 초기화
        resetAmountMemo()
        
        // 3) 저장 버튼 상태 갱신
        updateSaveButtonState()
        
        // 4) 접기 (UI까지 접히도록)
        collapse(animated: animated)
    }
    
}


