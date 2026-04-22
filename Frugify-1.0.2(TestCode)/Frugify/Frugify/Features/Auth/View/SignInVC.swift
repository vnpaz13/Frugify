//
//  SignInVC.swift
//  Frugify
//
//  Created by VnPaz on 12/24/25.
//

import UIKit
import AuthenticationServices

@MainActor
class SignInVC: UIViewController {
    
    private let viewModel = SignInViewModel()
    
    // MARK: - properties
    private var showPassword: Bool = false
    
    // MARK: - 스크롤뷰
    private lazy var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - UI Components
    private lazy var  titleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Frugify"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "절약의 즐거움을 기록하세요!"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - ID 입력
    
    private lazy var idLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "아이디"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var idContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cardBorder.cgColor
        return view
    }()
    
    private lazy var idIconView : UIImageView = {
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "envelope")
        iconView.tintColor = .textSecondary
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private lazy var idTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "example@email.com"
        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = .basicGreen
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(idChanged), for: .editingChanged)
        return textField
    }()
    
    // MARK: - 비밀번호 입력
    
    private lazy var pwLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "비밀번호"
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var pwContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cardBorder.cgColor
        return view
    }()
    
    private lazy var pwIconView : UIImageView = {
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = UIImage(systemName: "lock")
        iconView.tintColor = .textSecondary
        iconView.contentMode = .scaleAspectFit
        return iconView
    }()
    
    private lazy var pwTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "비밀번호를 입력하세요"
        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = .basicGreen
        textField.isSecureTextEntry = true
        textField.keyboardType = .default
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(pwChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var passwordToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .textSecondary
        button.addTarget(self, action: #selector(pwVisibility), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 로그인 버튼
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("로그인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .basicGreen
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 구분선
    private lazy var dividerLeftView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .cardBorder
        return view
    }()
    
    private lazy var dividerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "또는"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var dividerRightView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .cardBorder
        return view
    }()
    
    // MARK: - Footer (아래항목)
    private lazy var footerStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()
    
    private lazy var noAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "계정이 없으신가요?"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.setTitleColor(.basicGreen, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - 소셜 로그인 프로퍼티
    private lazy var googleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // 버튼 외형
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.clipsToBounds = true
        
        // system 버튼 기본 타이틀/이미지 사용 안 함
        button.setTitle(nil, for: .normal)
        button.setImage(nil, for: .normal)
        
        // 내부 뷰 구성
        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.contentMode = .scaleAspectFit
        iconView.image = UIImage(named: "google_logo")?.withRenderingMode(.alwaysOriginal)
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Google로 로그인"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        // 스택뷰로 정렬 (가운데 정렬)
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isUserInteractionEnabled = false // 터치는 버튼이 받게
        
        button.addSubview(stack)
        
        NSLayoutConstraint.activate([
            // 로고 크기 고정
            iconView.widthAnchor.constraint(equalToConstant: 20),
            iconView.heightAnchor.constraint(equalToConstant: 20),
            
            // 스택뷰를 버튼 중앙에
            stack.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            // 너무 길 때 좌우로 삐져나가지 않게 안전장치(선택)
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: button.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: button.trailingAnchor, constant: -16),
        ])
        
        button.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.separator.cgColor
        button.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - NavigationBar 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar(animated)
    }
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegate()
        keyboardDismissGesture()
        updateLoginButtonState()
    }
    
    // MARK: - keyboardNotification 해제
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
        
        setupHeader()
        setupForm()
        setupDivider()
        setupFooter()
        setupSocialButtons()
    }
    
    // Header
    private func setupHeader() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupForm() {
        // ID
        contentView.addSubview(idLabel)
        contentView.addSubview(idContainerView)
        idContainerView.addSubview(idIconView)
        idContainerView.addSubview(idTextField)
        
        // Password
        contentView.addSubview(pwLabel)
        contentView.addSubview(pwContainerView)
        pwContainerView.addSubview(pwIconView)
        pwContainerView.addSubview(pwTextField)
        pwContainerView.addSubview(passwordToggleButton)
        
        // Login Button
        contentView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            // ID
            idLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            idLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            idContainerView.topAnchor.constraint(equalTo: idLabel.bottomAnchor, constant: 8),
            idContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            idContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            idContainerView.heightAnchor.constraint(equalToConstant: 52),
            
            idIconView.leadingAnchor.constraint(equalTo: idContainerView.leadingAnchor, constant: 16),
            idIconView.centerYAnchor.constraint(equalTo: idContainerView.centerYAnchor),
            idIconView.widthAnchor.constraint(equalToConstant: 20),
            idIconView.heightAnchor.constraint(equalToConstant: 20),
            
            idTextField.leadingAnchor.constraint(equalTo: idIconView.trailingAnchor, constant: 12),
            idTextField.trailingAnchor.constraint(equalTo: idContainerView.trailingAnchor, constant: -16),
            idTextField.centerYAnchor.constraint(equalTo: idContainerView.centerYAnchor),
            
            // Password
            pwLabel.topAnchor.constraint(equalTo: idContainerView.bottomAnchor, constant: 20),
            pwLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            pwContainerView.topAnchor.constraint(equalTo: pwLabel.bottomAnchor, constant: 8),
            pwContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pwContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pwContainerView.heightAnchor.constraint(equalToConstant: 52),
            
            pwIconView.leadingAnchor.constraint(equalTo: pwContainerView.leadingAnchor, constant: 16),
            pwIconView.centerYAnchor.constraint(equalTo: pwContainerView.centerYAnchor),
            pwIconView.widthAnchor.constraint(equalToConstant: 20),
            pwIconView.heightAnchor.constraint(equalToConstant: 20),
            
            pwTextField.leadingAnchor.constraint(equalTo: pwIconView.trailingAnchor, constant: 12),
            pwTextField.trailingAnchor.constraint(equalTo: passwordToggleButton.leadingAnchor, constant: -8),
            pwTextField.centerYAnchor.constraint(equalTo: pwContainerView.centerYAnchor),
            
            passwordToggleButton.trailingAnchor.constraint(equalTo: pwContainerView.trailingAnchor, constant: -16),
            passwordToggleButton.centerYAnchor.constraint(equalTo: pwContainerView.centerYAnchor),
            passwordToggleButton.widthAnchor.constraint(equalToConstant: 24),
            passwordToggleButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: pwContainerView.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
    private func setupDivider() {
        // MARK: - Divider
        contentView.addSubview(dividerLeftView)
        contentView.addSubview(dividerLabel)
        contentView.addSubview(dividerRightView)
        
        NSLayoutConstraint.activate([
            // Divider Left
            dividerLeftView.topAnchor.constraint(equalTo: loginButton.bottomAnchor,constant: 32),
            dividerLeftView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            dividerLeftView.trailingAnchor.constraint(equalTo: dividerLabel.leadingAnchor,constant: -16),
            dividerLeftView.heightAnchor.constraint(equalToConstant: 1),
            
            // Divider Label
            dividerLabel.centerYAnchor.constraint(equalTo: dividerLeftView.centerYAnchor),
            dividerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            // Divider Right
            dividerRightView.centerYAnchor.constraint(equalTo: dividerLeftView.centerYAnchor),
            dividerRightView.leadingAnchor.constraint(equalTo: dividerLabel.trailingAnchor,constant: 16),
            dividerRightView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -16),
            dividerRightView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    
    private func setupFooter() {
        contentView.addSubview(footerStackView)
        footerStackView.addArrangedSubview(noAccountLabel)
        footerStackView.addArrangedSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            footerStackView.topAnchor.constraint(equalTo: dividerLeftView.bottomAnchor, constant: 16),
            footerStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
    
    private func setupSocialButtons() {
        contentView.addSubview(googleButton)
        contentView.addSubview(appleButton)
        
        NSLayoutConstraint.activate([
            googleButton.topAnchor.constraint(equalTo: footerStackView.bottomAnchor, constant: 12),
            googleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            googleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            googleButton.heightAnchor.constraint(equalToConstant: 52),
            
            appleButton.topAnchor.constraint(equalTo: googleButton.bottomAnchor, constant: 12),
            appleButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            appleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            appleButton.heightAnchor.constraint(equalToConstant: 52),
            
            // 스크롤 길이는 마지막(애플)로 결정
            appleButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    // MARK: - TextField Delegate
    
    private func setupTextFieldDelegate() {
        
        idTextField.delegate = self
        pwTextField.delegate = self
        
        // 다음/완료 키 느낌
        idTextField.returnKeyType = .next
        pwTextField.returnKeyType = .done
        
        // 키보드 추천 바 없애버리기
        idTextField.disableSuggestions()
        pwTextField.disableSuggestions()
        
    }
    
    // MARK: - 로그인 버튼
    private func updateLoginButtonState() {
        let id = (idTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let enabled = viewModel.isLoginEnabled(email: id, password: pw)
        loginButton.isEnabled = enabled
        loginButton.alpha = enabled ? 1.0 : 0.5
    }
    
    
    // MARK: - Action
    @objc private func idChanged(_ textField: UITextField) {
        updateLoginButtonState()
    }
    
    @objc private func pwChanged(_ textField: UITextField) {
        updateLoginButtonState()
    }
    
    @objc private func pwVisibility() {
        showPassword.toggle()
        
        let wasFirstResponder = pwTextField.isFirstResponder
        pwTextField.isSecureTextEntry = !showPassword
        if wasFirstResponder {
            pwTextField.becomeFirstResponder()
        }
        let iconName = showPassword ? "eye" : "eye.slash"
        passwordToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc private func loginTapped() {
        let email = (idTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        loginButton.isEnabled = false
        loginButton.alpha = 0.7
        
        Task { [weak self] in
            guard let self else { return }
            do {
                _ = try await self.viewModel.signInAndFetchProfile(email: email, password: pw)
                AppRouter.setRoot(.main, animated: true)
            } catch {
                self.loginButton.isEnabled = true
                self.loginButton.alpha = 1.0
                self.showSimpleAlert(title: "로그인 실패!", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func signUpTapped() {
        let signUpVC = SignUpVC()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    // MARK: - 소셜 로그인 Action
    @objc private func googleTapped() {
        
        // 비동기 작업 시작 (OAuth는 asnyc)
        Task { [weak self] in
            
            // self가 해제 되었으면 작업 중단 (메모리 누수 방지)
            guard let self else { return }
            
            do {
                // Google OAuth 로그인 시작, 계정 선택 화면 띄우기)
                try await SupabaseManager.shared.startGoogleOAuth(promptSelectAccount: true)
                // OAuth 종료 후 현재 세션이 유효한지 확인
                let loggedIn = await SupabaseManager.shared.hasValidSession()
                // 로그인 성공시 메인 화면으로 루트 전환
                if loggedIn {
                    AppRouter.setRoot(.main, animated: true)
                }
                
            } catch {
                // 사용자가 로그인 중 취소한 경우 (에러 알림 표시하지 않음)
                let nsError = error as NSError
                if nsError.domain == ASWebAuthenticationSessionError.errorDomain,
                   nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    return
                }
                // 그 외 오류 발생 시 에러 메시지 표시
                self.showSimpleAlert(title: "실패", message: error.localizedDescription)
            }
        }
    }
    
    
    @objc private func appleTapped() {
        
        // 비동기 작업 시작 (OAuth는 asnyc)
        Task { [weak self] in
            
            // self가 해제 되었으면 작업 중단 (메모리 누수 방지)
            guard let self else { return }
            
            do {
                // Apple OAuth 로그인 시작
                try await SupabaseManager.shared.startAppleOAuth()
                // OAuth 종료 후 현재 세션이 유효한지 확인
                let loggedIn = await SupabaseManager.shared.hasValidSession()
                // 로그인 성공 시 메인 화면으로 루트 전환
                if loggedIn {
                    AppRouter.setRoot(.main, animated: true)
                }
                
            } catch {
                // 사용자가 로그인 중 취소한 경우 (에러 알림 표시하지 않음)
                let nsError = error as NSError
                if nsError.domain == ASWebAuthenticationSessionError.errorDomain,
                   nsError.code == ASWebAuthenticationSessionError.canceledLogin.rawValue {
                    return
                }
                // 그 외 오류 발생 시 에러 메시지 표시
                self.showSimpleAlert(title: "실패", message: error.localizedDescription)
                
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension SignInVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == idTextField {
            idTextField.placeholder = nil
        }
        if textField == pwTextField {
            pwTextField.placeholder = nil
        }
    }
    
    // 편집 끝났을 때 비어있으면 placeholder 복구
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == idTextField {
            let text = (idTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty {
                idTextField.placeholder = "example@email.com"
                idTextField.textColor = .label
            }
        }
        
        if textField == pwTextField {
            let text = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty {
                pwTextField.placeholder = "비밀번호를 입력하세요"
                pwTextField.text = ""
                pwTextField.isSecureTextEntry = true
                showPassword = false
                passwordToggleButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            }
        }
        updateLoginButtonState()
    }
    
    // MARK: - 입력 글자수 제한
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if textField == idTextField {
            return updatedText.count <= 50
        }
        if textField == pwTextField {
            return updatedText.count <= 18
        }
        return true
    }
    // MARK: - return 키 동작
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == idTextField {
            pwTextField.becomeFirstResponder()
            return true
        }
        if textField == pwTextField {
            view.endEditing(true)
            // 활성화된 상태(유효한 입력)일 때만 로그인 시도
            guard loginButton.isEnabled else { return true }
            loginTapped()
            return true
        }
        return true
    }
}
