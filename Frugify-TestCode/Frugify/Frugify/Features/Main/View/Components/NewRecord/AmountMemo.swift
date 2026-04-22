//
//  AmountMemo.swift
//  Frugify
//
//  Created by VnPaz on 1/5/26.
//

import UIKit

class AmountMemo: UIView {
    
    private let amountLabel = UILabel()
    private let memoLabel = UILabel()
    private let amountTextField = UITextField()
    private let memoTextView = UITextView()
    private let memoPlaceholder = UILabel()
    
    var amountText: String {
        amountTextField.text ?? ""
    }
    
    var memoText: String {
        memoTextView.text ?? ""
    }
    
    // Event
    var onAmountChanged: (() -> Void)?
    var onBeginEditing: (() -> Void)?
    
    // MARK: - 스택 쌓기
    
    private let rootStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStack)
        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: topAnchor),
            rootStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            rootStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            rootStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 금액
        amountLabel.text = "절약 금액"
        amountLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        amountLabel.textColor = .textSecondary
        
        amountTextField.translatesAutoresizingMaskIntoConstraints = false
        amountTextField.font = .systemFont(ofSize: 16)
        amountTextField.keyboardType = .numberPad
        amountTextField.textColor = .label
        amountTextField.tintColor = .basicGreen
        
        amountTextField.backgroundColor = .backgroundSecondary
        amountTextField.layer.cornerRadius = 12
        amountTextField.layer.borderWidth = 1
        amountTextField.layer.borderColor = UIColor.systemGray.cgColor
        amountTextField.clipsToBounds = true
        
        amountTextField.addTarget(self, action: #selector(amountChanged), for: .editingChanged)
        
        let leftPad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        amountTextField.leftView = leftPad
        amountTextField.leftViewMode = .always
        amountTextField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // 메모
        memoLabel.text = "메모 (선택)"
        memoLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        memoLabel.textColor = .textSecondary
        
        memoTextView.translatesAutoresizingMaskIntoConstraints = false
        memoTextView.font = .systemFont(ofSize: 16)
        memoTextView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        memoTextView.isScrollEnabled = false
        memoTextView.textContainer.lineBreakMode = .byCharWrapping
        memoTextView.textContainer.widthTracksTextView = true
        
        memoTextView.tintColor = .basicGreen
        
        memoTextView.backgroundColor = .backgroundSecondary
        memoTextView.layer.cornerRadius = 12
        memoTextView.layer.borderWidth = 1
        memoTextView.layer.borderColor = UIColor.systemGray.cgColor
        memoTextView.clipsToBounds = true
        memoTextView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // 메모 placeholder
        memoPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        memoPlaceholder.text = "메모를 입력하세요 (18자 제한)"
        memoPlaceholder.font = .systemFont(ofSize: 16)
        memoPlaceholder.textColor = .textSecondary.withAlphaComponent(0.3)
        memoPlaceholder.numberOfLines = 1
        memoTextView.addSubview(memoPlaceholder)
        
        NSLayoutConstraint.activate([
            memoPlaceholder.topAnchor.constraint(equalTo: memoTextView.topAnchor, constant: 12),
            memoPlaceholder.leadingAnchor.constraint(equalTo: memoTextView.leadingAnchor, constant: 12),
            memoPlaceholder.trailingAnchor.constraint(lessThanOrEqualTo: memoTextView.trailingAnchor, constant: -12)
        ])
        
        // MARK: - 절약 금액 기입 스택
        let amountStack = UIStackView(arrangedSubviews: [amountLabel, amountTextField])
        amountStack.axis = .vertical
        amountStack.spacing = 6
        amountStack.alignment = .fill
        
        // MARK: - 메모 기입 스택
        let memoStack = UIStackView(arrangedSubviews: [memoLabel, memoTextView])
        memoStack.axis = .vertical
        memoStack.spacing = 6
        memoStack.alignment = .fill
        
        rootStack.addArrangedSubview(memoStack)
        rootStack.addArrangedSubview(amountStack)
        
        amountTextField.delegate = self
        memoTextView.delegate = self
        controlPlaceholders()
        
        memoTextView.returnKeyType = .next
        
        // 키보드 추천 바 없애버리기
        amountTextField.disableSuggestions()
        memoTextView.disableSuggestions()
    }
    
    private func controlPlaceholders() {
        if amountTextField.isFirstResponder {
            amountTextField.placeholder = nil
        } else {
            let isEmpty = (amountTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            amountTextField.placeholder = isEmpty ? "금액을 입력하세요" : nil
        }
        
        if memoTextView.isFirstResponder {
            memoPlaceholder.isHidden = true
        } else {
            let isEmpty = memoTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            memoPlaceholder.isHidden = !isEmpty
        }
    }
    
   
    
    @objc private func dismissKeyboard() {
        endEditing(true)
    }
 
    
    @objc private func amountChanged() {
        onAmountChanged?()
    }
    
    func reset() {
        amountTextField.text = nil
        memoTextView.text = nil
        controlPlaceholders()
    }
    
}

extension AmountMemo: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        controlPlaceholders()
        onBeginEditing?()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        controlPlaceholders()
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        controlPlaceholders()
    }
    
    // 금액 입력 제한 (숫자만, 최대 999,999,999)
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        // 숫자만 허용 (사실 안해도 되긴함 넘버패드 키보드라)
        if string.isEmpty == false { // 백스페이스는 허용
            let isNumberOnly = CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string))
            if !isNumberOnly { return false }
        }
        
        // 변경 후 문자열 계산
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        // 앞자리에 0만 계속 입력되는 것 방지 (선택)
        if updatedText.count > 1 && updatedText.first == "0" {
            return false
        }
        
        // 최대 길이 제한 (10자리)
        return updatedText.count <= 9
    }
}

extension AmountMemo: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        controlPlaceholders()
        onBeginEditing?()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        controlPlaceholders()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        controlPlaceholders()
    }
    
    // 메모 18자 제한
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        // 엔터(줄바꿈) 입력 막기
        if text == "\n" {
            amountTextField.becomeFirstResponder()
            return false
        }
        let currentText = textView.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        return updatedText.count <= 18
    }
}

