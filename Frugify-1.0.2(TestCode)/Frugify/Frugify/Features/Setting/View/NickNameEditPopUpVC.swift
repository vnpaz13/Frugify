//
//  NickNameEditPopUpVC.swift
//  Frugify
//
//  Created by VnPaz on 1/13/26.
//

import UIKit

@MainActor
final class NicknameEditPopupVC: UIViewController {
    
    // MARK: - Dependencies
    private let currentNickname: String
    private let viewModel: SettingViewModel
    
    // MARK: - State
    private var isChecked = false
    private var lastCheckedNickname: String = ""
    
    // MARK: - UI
    private let dimView = UIView()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    
    private let textField = UITextField()
    private let dupButton = UIButton(type: .system)
    
    private let cancelButton = UIButton(type: .system)
    private let saveButton = UIButton(type: .system)
    
    init(currentNickname: String, viewModel: SettingViewModel) {
        self.currentNickname = currentNickname
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindActions()
        keyboardDismissGesture()
    }
    
    private func setupUI() {
        view.backgroundColor = .clear
        
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.35)
        dimView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimView)
        
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 16
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        titleLabel.text = "닉네임 변경"
        titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textAlignment = .center
        
        textField.text = nil
        textField.placeholder = "10자 이내로 입력"
        textField.borderStyle = .roundedRect
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartInsertDeleteType = .no
        textField.textContentType = .password
        textField.addTarget(self, action: #selector(textFieldDidBegin), for: .editingDidBegin)
        textField.addTarget(self, action: #selector(textFieldDidEnd), for: .editingDidEnd)
        
        var dupConfig = UIButton.Configuration.filled()
        dupConfig.title = "중복"
        dupConfig.baseBackgroundColor = .systemGreen
        dupConfig.baseForegroundColor = .white
        dupConfig.cornerStyle = .medium
        dupConfig.contentInsets = NSDirectionalEdgeInsets(
            top: 12,
            leading: 18,
            bottom: 12,
            trailing: 18
        )

        dupButton.configuration = dupConfig
        dupButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        var cancelConfig = UIButton.Configuration.filled()
        cancelConfig.title = "취소"
        cancelConfig.baseBackgroundColor = .secondarySystemBackground
        cancelConfig.baseForegroundColor = .label
        cancelConfig.cornerStyle = .medium
        cancelConfig.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 0,
            bottom: 14,
            trailing: 0
        )

        cancelButton.configuration = cancelConfig
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        var saveConfig = UIButton.Configuration.filled()
        saveConfig.title = "저장"
        saveConfig.baseBackgroundColor = .systemGreen
        saveConfig.baseForegroundColor = .white
        saveConfig.cornerStyle = .medium
        saveConfig.contentInsets = NSDirectionalEdgeInsets(
            top: 14,
            leading: 0,
            bottom: 14,
            trailing: 0
        )

        saveButton.configuration = saveConfig
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let textFieldStack = UIStackView(arrangedSubviews: [textField, dupButton])
        textFieldStack.axis = .horizontal
        textFieldStack.spacing = 12
        textFieldStack.alignment = .fill
        
        let buttonStack = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        
        let root = UIStackView(arrangedSubviews: [titleLabel, textFieldStack, buttonStack])
        root.axis = .vertical
        root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(root)
        
        NSLayoutConstraint.activate([
            dimView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dimView.topAnchor.constraint(equalTo: view.topAnchor),
            dimView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            root.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            root.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            root.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
            
            dupButton.widthAnchor.constraint(equalToConstant: 90)
        ])
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissSelf))
        dimView.addGestureRecognizer(tap)
    }
    
    private func bindActions() {
        cancelButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        dupButton.addTarget(self, action: #selector(checkDuplicate), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveNickname), for: .touchUpInside)
        textField.addTarget(self, action: #selector(onTextChanged), for: .editingChanged)
    }
    
    @objc private func onTextChanged() {
        // 텍스트 변경되면 중복확인 무효화
        isChecked = false
        lastCheckedNickname = ""
    }
    
    @objc private func checkDuplicate() {
        let nick = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard nick.count >= 1 && nick.count <= 10 else {
            showAlert(title: "닉네임", message: "닉네임 1~10자 입력해주세요.")
            return
        }
        
        Task {
            let available = await viewModel.checkNicknameAvailable(nick)
            if available {
                isChecked = true
                lastCheckedNickname = nick
                showAlert(title: "사용 가능", message: "사용 가능한 닉네임입니다.")
            } else {
                isChecked = false
                lastCheckedNickname = ""
                showAlert(title: "중복", message: "이미 사용 중인 닉네임입니다.")
            }
        }
    }
    
    @objc private func saveNickname() {
        let nickname = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)

        // 길이 / 공백 검증
        guard nickname.count >= 1 && nickname.count <= 10 else {
            showAlert(title: "닉네임", message: "닉네임을 1~10자 이내로 입력해주세요.")
            return
        }

        // 중복 확인 여부 검사
        guard isChecked, lastCheckedNickname == nickname else {
            showAlert(title: "중복 확인", message: "저장 전에 닉네임 중복 확인 해주세요.")
            return
        }

        // 서버 업데이트
        Task {
            let ok = await viewModel.updateNickname(nickname)
            if ok {
                dismiss(animated: true) { [weak self] in
                    self?.viewModel.onToast?("닉네임이 변경되었습니다.")
                }
            }
        }
    }

    @objc private func textFieldDidBegin() {
        textField.placeholder = nil
    }

    @objc private func textFieldDidEnd() {
        if (textField.text ?? "").isEmpty {
            textField.placeholder = "10자 이내로 입력해주세요"
        }
    }

    @objc private func dismissSelf() {
        dismiss(animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
