//
//  MainNewRecord+Actions.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

extension MainNewRecord {
    
    func setupButtons() {
        let buttonStack = getButtonStack()
        let cancelButton = getCancelButton()
        let saveButton = getSaveButton()
        
        buttonStack.axis = .horizontal
        buttonStack.spacing = 10
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        
        cancelButton.setTitle("초기화", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        cancelButton.setTitleColor(.textSecondary, for: .normal)
        cancelButton.backgroundColor = .backgroundSecondary
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemGray.cgColor
        cancelButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        cancelButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
        
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.backgroundColor = .basicGreen
        saveButton.layer.cornerRadius = 12
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.systemGray.cgColor
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        saveButton.addTarget(self, action: #selector(didTapSave), for: .touchUpInside)
        
        if buttonStack.arrangedSubviews.isEmpty {
            buttonStack.addArrangedSubview(cancelButton)
            buttonStack.addArrangedSubview(saveButton)
        }
    }
    
    // MARK: - 접었다 펼쳤다 버튼
    @objc func toggle() {
        setIsExpanded(!getIsExpanded())
        
        let toggleButton = getToggleButton()
        toggleButton.setImage(
            UIImage(systemName: getIsExpanded() ? "chevron.up" : "plus"),
            for: .normal
        )
        
        getFormHeight().constant = getIsExpanded() ? 463 : 0
        self.superview?.layoutIfNeeded()
        getSeparatorView().isHidden = getIsExpanded() ? false : true
        updateSaveButtonState()
    }
    
    // MARK: - 초기화
    func closeForm() {
        setIsExpanded(false)
        getFormHeight().constant = 0
        getSeparatorView().isHidden = true
        getToggleButton().setImage(UIImage(systemName: "plus"), for: .normal)
        endEditing(true) // 키보드 내리기
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.superview?.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - 저장 버튼 상태 업데이트
    func updateSaveButtonState() {
        let hasEmotion = (getSelectedEmotion() != nil)
        let hasCategory = (getSelectedCategory() != nil)
        
        let amountString = getAmountText().trimmingCharacters(in: .whitespacesAndNewlines)
        let hasAmount = !amountString.isEmpty && Int(amountString) != nil && Int(amountString)! > 0
        
        let enabled = hasEmotion && hasCategory && hasAmount
        let saveButton = getSaveButton()
        saveButton.isEnabled = enabled
        saveButton.alpha = enabled ? 1.0 : 0.35
    }
    
    // MARK: - 초기화 button눌렸을 때
    @objc func didTapReset() {
        endEditing(true)
        resetEmotionSelection()
        resetCategorySelection()
        resetAmountMemo()
        updateSaveButtonState()
    }
    
    // MARK: - 저장 버튼 눌렸을 때
    @objc func didTapSave() {
        
        guard getSaveButton().isEnabled,
              let amount = Int(getAmountText()),
              let emotion = getSelectedEmotion(),
              let category = getSelectedCategory()
        else {
            return
        }

        let memoText = getMemoText().trimmingCharacters(in: .whitespacesAndNewlines)
        let memo = memoText.isEmpty ? nil : memoText

        let handover = NewSavingRecord(
            emotionId: emotion.id,
            category: category.title,
            amount: amount,
            memo: memo
        )
        
        onSubmit?(handover)
        resetEmotionSelection()
        resetCategorySelection()
        resetAmountMemo()
        updateSaveButtonState()
        closeForm()
    }
}

