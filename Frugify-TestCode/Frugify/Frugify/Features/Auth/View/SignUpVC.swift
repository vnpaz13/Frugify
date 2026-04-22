//
//  SignUpVC.swift
//  Frugify
//
//  Created by VnPaz on 12/24/25.
//

import UIKit

//@MainActor
final class SignUpVC: UIViewController {
    
    private let viewModel = SignUpViewModel()
    
    // MARK: - 회원가입 활성화 상태 변수 (이메일 중복, 닉네임 중복)
    private var isUserEmailAvailable: Bool = false
    private var lastCheckedUserEmail: String = ""
    
    private var isNicknameAvailable: Bool = false
    private var lastCheckedNickname: String = ""
    
    private var showPassword = false
    private var showPasswordCheck = false
    
    // MARK: - Scroll View Components
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Header UI
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "회원가입"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Frugify와 함께 절약 습관을 시작하세요"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .textSecondary
        return label
    }()
    
    // MARK: - Email
    private lazy var emailLabel: UILabel = makeFieldLabel("이메일")
    
    private lazy var emailContainerView: UIView = makeContainerView()
    private lazy var emailIconView: UIImageView = makeIconView(systemName: "envelope")
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "example@email.com"
        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = .basicGreen
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(emailChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var emailDupButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("중복확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .basicGreen
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(emailDupTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Password
    private lazy var pwLabel: UILabel = makeFieldLabel("비밀번호")
    
    private lazy var pwContainerView: UIView = makeContainerView()
    private lazy var pwIconView: UIImageView = makeIconView(systemName: "lock")
    
    private lazy var pwTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "6자 이상 입력하세요"
        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = .basicGreen
        textField.isSecureTextEntry = true
        textField.textContentType = .newPassword
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(pwChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var pwToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .textSecondary
        button.addTarget(self, action: #selector(pwVisibility), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Password Check
    private lazy var pwCheckLabel: UILabel = makeFieldLabel("비밀번호 확인")
    
    private lazy var pwCheckContainerView: UIView = makeContainerView()
    private lazy var pwCheckIconView: UIImageView = makeIconView(systemName: "lock")
    
    private lazy var pwCheckTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "비밀번호를 다시 입력하세요"
        textField.font = .systemFont(ofSize: 16)
        textField.tintColor = .basicGreen
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(pwCheckChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var pwCheckToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        button.tintColor = .textSecondary
        button.addTarget(self, action: #selector(pwCheckVisibility), for: .touchUpInside)
        return button
    }()
    
    // MARK: - 비밀번호 불일치 시 경고 문구
    private lazy var passwordWarningLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "비밀번호가 일치하지 않습니다."
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .systemRed
        label.isHidden = true
        return label
    }()
    
    // MARK: - Nickname
    private lazy var nicknameLabel: UILabel = makeFieldLabel("닉네임")
    
    private lazy var nicknameContainerView: UIView = makeContainerView()
    private lazy var nicknameIconView: UIImageView = makeIconView(systemName: "person")
    
    private lazy var nicknameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "닉네임 (최대 10자)"
        textField.tintColor = .basicGreen
        textField.font = .systemFont(ofSize: 16)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addTarget(self, action: #selector(nicknameChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var nicknameDupButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("중복확인", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        button.backgroundColor = .basicGreen
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(nicknameDupTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Sign Up Button
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("가입하기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .basicGreen
        button.layer.cornerRadius = 8
        button.isEnabled = false
        button.alpha = 0.5
        button.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - NavigationBar 숨기기
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        loadBackButton()
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextFieldDelegate()
        updateSignUpButtonState()
        keyboardDismissGesture()
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
    }
    
    private func setupHeader() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        ])
    }
    
    private func setupForm() {
        // Email
        contentView.addSubview(emailLabel)
        contentView.addSubview(emailContainerView)
        emailContainerView.addSubview(emailIconView)
        emailContainerView.addSubview(emailTextField)
        contentView.addSubview(emailDupButton)
        
        // Password
        contentView.addSubview(pwLabel)
        contentView.addSubview(pwContainerView)
        pwContainerView.addSubview(pwIconView)
        pwContainerView.addSubview(pwTextField)
        pwContainerView.addSubview(pwToggleButton)
        
        // Password Check
        contentView.addSubview(pwCheckLabel)
        contentView.addSubview(pwCheckContainerView)
        contentView.addSubview(passwordWarningLabel)
        pwCheckContainerView.addSubview(pwCheckIconView)
        pwCheckContainerView.addSubview(pwCheckTextField)
        pwCheckContainerView.addSubview(pwCheckToggleButton)
        
        
        // Nickname
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(nicknameContainerView)
        nicknameContainerView.addSubview(nicknameIconView)
        nicknameContainerView.addSubview(nicknameTextField)
        contentView.addSubview(nicknameDupButton)
        
        // SignUp Button
        contentView.addSubview(signUpButton)
        
        NSLayoutConstraint.activate([
            // Email
            emailLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 28),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            emailDupButton.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailDupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emailDupButton.widthAnchor.constraint(equalToConstant: 92),
            emailDupButton.heightAnchor.constraint(equalToConstant: 52),
            
            emailContainerView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 8),
            emailContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailContainerView.trailingAnchor.constraint(equalTo: emailDupButton.leadingAnchor, constant: -10),
            emailContainerView.heightAnchor.constraint(equalToConstant: 52),
            
            emailIconView.leadingAnchor.constraint(equalTo: emailContainerView.leadingAnchor, constant: 16),
            emailIconView.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            emailIconView.widthAnchor.constraint(equalToConstant: 20),
            emailIconView.heightAnchor.constraint(equalToConstant: 20),
            
            emailTextField.leadingAnchor.constraint(equalTo: emailIconView.trailingAnchor, constant: 12),
            emailTextField.trailingAnchor.constraint(equalTo: emailContainerView.trailingAnchor, constant: -16),
            emailTextField.centerYAnchor.constraint(equalTo: emailContainerView.centerYAnchor),
            
            // Password
            pwLabel.topAnchor.constraint(equalTo: emailContainerView.bottomAnchor, constant: 20),
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
            pwTextField.trailingAnchor.constraint(equalTo: pwToggleButton.leadingAnchor, constant: -8),
            pwTextField.centerYAnchor.constraint(equalTo: pwContainerView.centerYAnchor),
            
            pwToggleButton.trailingAnchor.constraint(equalTo: pwContainerView.trailingAnchor, constant: -16),
            pwToggleButton.centerYAnchor.constraint(equalTo: pwContainerView.centerYAnchor),
            pwToggleButton.widthAnchor.constraint(equalToConstant: 24),
            pwToggleButton.heightAnchor.constraint(equalToConstant: 24),
            
            // Password Check
            pwCheckLabel.topAnchor.constraint(equalTo: pwContainerView.bottomAnchor, constant: 20),
            pwCheckLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            pwCheckContainerView.topAnchor.constraint(equalTo: pwCheckLabel.bottomAnchor, constant: 8),
            pwCheckContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            pwCheckContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            pwCheckContainerView.heightAnchor.constraint(equalToConstant: 52),
            
            pwCheckIconView.leadingAnchor.constraint(equalTo: pwCheckContainerView.leadingAnchor, constant: 16),
            pwCheckIconView.centerYAnchor.constraint(equalTo: pwCheckContainerView.centerYAnchor),
            pwCheckIconView.widthAnchor.constraint(equalToConstant: 20),
            pwCheckIconView.heightAnchor.constraint(equalToConstant: 20),
            
            pwCheckTextField.leadingAnchor.constraint(equalTo: pwCheckIconView.trailingAnchor, constant: 12),
            pwCheckTextField.trailingAnchor.constraint(equalTo: pwCheckToggleButton.leadingAnchor, constant: -8),
            pwCheckTextField.centerYAnchor.constraint(equalTo: pwCheckContainerView.centerYAnchor),
            
            pwCheckToggleButton.trailingAnchor.constraint(equalTo: pwCheckContainerView.trailingAnchor, constant: -16),
            pwCheckToggleButton.centerYAnchor.constraint(equalTo: pwCheckContainerView.centerYAnchor),
            pwCheckToggleButton.widthAnchor.constraint(equalToConstant: 24),
            pwCheckToggleButton.heightAnchor.constraint(equalToConstant: 24),
            
            passwordWarningLabel.topAnchor.constraint(equalTo: pwCheckContainerView.bottomAnchor, constant: 6),
            passwordWarningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordWarningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Nickname
            nicknameLabel.topAnchor.constraint(equalTo: passwordWarningLabel.bottomAnchor, constant: 14),
            nicknameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            nicknameDupButton.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            nicknameDupButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nicknameDupButton.widthAnchor.constraint(equalToConstant: 92),
            nicknameDupButton.heightAnchor.constraint(equalToConstant: 52),
            
            nicknameContainerView.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8),
            nicknameContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nicknameContainerView.trailingAnchor.constraint(equalTo: nicknameDupButton.leadingAnchor, constant: -10),
            nicknameContainerView.heightAnchor.constraint(equalToConstant: 52),
            
            nicknameIconView.leadingAnchor.constraint(equalTo: nicknameContainerView.leadingAnchor, constant: 16),
            nicknameIconView.centerYAnchor.constraint(equalTo: nicknameContainerView.centerYAnchor),
            nicknameIconView.widthAnchor.constraint(equalToConstant: 20),
            nicknameIconView.heightAnchor.constraint(equalToConstant: 20),
            
            nicknameTextField.leadingAnchor.constraint(equalTo: nicknameIconView.trailingAnchor, constant: 12),
            nicknameTextField.trailingAnchor.constraint(equalTo: nicknameContainerView.trailingAnchor, constant: -16),
            nicknameTextField.centerYAnchor.constraint(equalTo: nicknameContainerView.centerYAnchor),
            
            // SignUp Button
            signUpButton.topAnchor.constraint(equalTo: nicknameContainerView.bottomAnchor, constant: 24),
            signUpButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            signUpButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            signUpButton.heightAnchor.constraint(equalToConstant: 52),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
            
        ])
        
        
    }
    
    private func signUpVisible(animated: Bool = true) {
        // signUpButton의 rect를 scrollView 좌표계로 변환
        let buttonRect = signUpButton.convert(signUpButton.bounds, to: scrollView)

        // 현재 scrollView에서 [보이는 영역]
        let visibleRect = CGRect(
            origin: scrollView.contentOffset,
            size: scrollView.bounds.size
        )

        // 약간의 여유
        let padding: CGFloat = 12
        let paddedButtonRect = buttonRect.insetBy(dx: 0, dy: -padding)

        // 이미 버튼이 완전히 보이면 아무 것도 안 함
        guard !visibleRect.contains(paddedButtonRect) else { return }

        // 가려져 있으면 그때만 올림
        scrollView.scrollRectToVisible(paddedButtonRect, animated: animated)
    }

    
    // MARK: - TextField Delegate
    private func setupTextFieldDelegate() {
        emailTextField.delegate = self
        pwTextField.delegate = self
        pwCheckTextField.delegate = self
        nicknameTextField.delegate = self
        
        emailTextField.returnKeyType = .next
        pwTextField.returnKeyType = .next
        pwCheckTextField.returnKeyType = .next
        nicknameTextField.returnKeyType = .done
        
        // 키보드 추천 바 없애버리기
        emailTextField.disableSuggestions()
        pwTextField.disableSuggestions()
        pwCheckTextField.disableSuggestions()
        nicknameTextField.disableSuggestions()
    }
    
    // MARK: - Button State
    private func updateSignUpButtonState() {
        let em = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pwC = (pwCheckTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let nn = (nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        let enabled = viewModel.isSignUpEnabled(
            email: em,
            password: pw,
            passwordCheck: pwC,
            nickname: nn,
            isUserEmailAvailable: isUserEmailAvailable,
            lastCheckedUserEmail: lastCheckedUserEmail,
            isNicknameAvailable: isNicknameAvailable,
            lastCheckedNickname: lastCheckedNickname
        )
        
        signUpButton.isEnabled = enabled
        signUpButton.alpha = enabled ? 1.0 : 0.5
    }
    
    
    // MARK: - Actions
    @objc private func emailChanged(_ textField: UITextField) {
        // 이메일이 바뀌면 이전 중복확인 결과는 무효!
        isUserEmailAvailable = false
        lastCheckedUserEmail = ""
        resetDupButton(emailDupButton)
        updateSignUpButtonState()
    }
    
    @objc private func pwChanged(_ textField: UITextField) {
        updatePasswordWarning()
        updateSignUpButtonState()
    }
    
    @objc private func pwCheckChanged(_ textField: UITextField) {
        updatePasswordWarning()
        updateSignUpButtonState()
    }
    
    @objc private func nicknameChanged(_ textField: UITextField) {
        // 닉네임을 바꾸면, 이전 중복확인 결과는 무효
        isNicknameAvailable = false
        lastCheckedNickname = ""
        resetDupButton(nicknameDupButton)
        updateSignUpButtonState()
    }
    
    @objc private func pwVisibility() {
        showPassword.toggle()
        pwTextField.isSecureTextEntry = !showPassword
        let iconName = showPassword ? "eye" : "eye.slash"
        pwToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc private func pwCheckVisibility() {
        showPasswordCheck.toggle()
        pwCheckTextField.isSecureTextEntry = !showPasswordCheck
        let iconName = showPasswordCheck ? "eye" : "eye.slash"
        pwCheckToggleButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    @objc private func emailDupTapped() {
        let userEmail = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userEmail.isEmpty else { return }
        
        Task {
            do {
                let isDup = try await self.viewModel.checkUserEmailDuplicate(userEmail)
                
                if isDup {
                    self.isUserEmailAvailable = false
                    self.lastCheckedUserEmail = ""
                    self.resetDupButton(self.emailDupButton)
                    self.showSimpleAlert(title: "이미 사용 중", message: "다른 이메일(ID)을 입력해 주세요.")
                } else {
                    self.isUserEmailAvailable = true
                    self.lastCheckedUserEmail = userEmail
                    self.setDupButtonVerified(self.emailDupButton)
                    self.showSimpleAlert(title: "사용 가능", message: "사용 가능한 이메일(ID)입니다.")
                }
                
                self.updateSignUpButtonState()
            } catch {
                print("dup check error:", error)
                let ns = error as NSError
                print("domain:", ns.domain, "code:", ns.code, "userInfo:", ns.userInfo)
                self.showSimpleAlert(title: "실패", message: "\(error)")
            }
        }
    }
    
    
    @objc private func nicknameDupTapped() {
        let nickname = (nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nickname.isEmpty else { return }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let available = try await self.viewModel.checkNicknameAvailable(nickname)
                
                if available {
                    self.isNicknameAvailable = true
                    self.lastCheckedNickname = nickname
                    self.setDupButtonVerified(self.nicknameDupButton)
                    self.showSimpleAlert(title: "사용 가능", message: "사용 가능한 닉네임입니다.")
                } else {
                    self.isNicknameAvailable = false
                    self.lastCheckedNickname = ""
                    self.resetDupButton(self.nicknameDupButton)
                    self.showSimpleAlert(title: "이미 사용 중", message: "다른 닉네임을 입력해 주세요.")
                }
                self.updateSignUpButtonState()
                
            } catch {
                self.isNicknameAvailable = false
                self.lastCheckedNickname = ""
                self.updateSignUpButtonState()
                self.showSimpleAlert(title: "오류", message: "중복 확인에 실패했어요.\n\(error.localizedDescription)")
            }
        }
    }
    
    @objc private func signUpTapped() {
        let userEmail = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let nickName = (nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard signUpButton.isEnabled else { return }
        
        // 중복 클릭 방지
        signUpButton.isEnabled = false
        signUpButton.alpha = 0.7
        
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.viewModel.register( email: userEmail, password: pw, nickname: nickName )
                // 자동 로그인 방지: 회원가입 직후 세션 제거
                try await SupabaseManager.shared.signOut()
                
                self.signUpAfterAlert(title: "완료", message: "회원가입이 완료됐어요!") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            catch { print("signUpTapped error:", error)
                self.signUpButton.isEnabled = true
                self.signUpButton.alpha = 1.0
                self.showSimpleAlert(title: "실패", message: "회원가입에 실패했어요.\n\(error.localizedDescription)")
            }
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension SignUpVC: UITextFieldDelegate {
    
    // 포커스 들어오면 placeholder 숨기기
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextField { emailTextField.placeholder = nil }
        if textField == pwTextField { pwTextField.placeholder = nil }
        if textField == pwCheckTextField { pwCheckTextField.placeholder = nil }
        if textField == nicknameTextField { nicknameTextField.placeholder = nil }
        
        guard textField == pwCheckTextField || textField == nicknameTextField else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self else { return }
            self.view.layoutIfNeeded()
            self.signUpVisible(animated: true)
        }
        
    }
    
    // 편집 끝났는데 비어있으면 placeholder 복구
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            let text = (emailTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { emailTextField.placeholder = "example@email.com" }
        }
        
        if textField == pwTextField {
            let text = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { pwTextField.placeholder = "6자 이상 입력하세요" }
        }
        
        if textField == pwCheckTextField {
            let text = (pwCheckTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { pwCheckTextField.placeholder = "비밀번호를 다시 입력하세요" }
        }
        
        if textField == nicknameTextField {
            let text = (nicknameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if text.isEmpty { nicknameTextField.placeholder = "닉네임 (최대 10자)" }
        }
        
        // 경고,버튼 상태 갱신
        updatePasswordWarning()
        updateSignUpButtonState()
    }
    
    // return 키 이동
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            pwTextField.becomeFirstResponder()
        } else if textField == pwTextField {
            pwCheckTextField.becomeFirstResponder()
        } else if textField == pwCheckTextField {
            nicknameTextField.becomeFirstResponder()
        } else if textField == nicknameTextField {
            view.endEditing(true)
            signUpTapped()
        }
        return true
    }
    
    // 닉네임 10자 제한
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField == nicknameTextField else { return true }
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        return updatedText.count <= 10
    }
}

// MARK: - UI Helper
private extension SignUpVC {
    
    func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .textSecondary
        return label
    }
    
    func makeContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .backgroundSecondary
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.cardBorder.cgColor
        return view
    }
    
    func makeIconView(systemName: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: systemName)
        imageView.tintColor = .textSecondary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
    
    func setDupButtonVerified(_ button: UIButton) {
        button.isEnabled = false
        button.setTitle("확인됨", for: .normal)
        button.backgroundColor = .textSecondary
        button.alpha = 0.9
    }
    
    func resetDupButton(_ button: UIButton) {
        button.isEnabled = true
        button.setTitle("중복확인", for: .normal)
        button.backgroundColor = .basicGreen
        button.alpha = 1.0
    }
    
    func updatePasswordWarning() {
        let password = (pwTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordCheck = (pwCheckTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 둘 다 입력 시작했을 때만 경고 노출
        if password.isEmpty || passwordCheck.isEmpty {
            passwordWarningLabel.isHidden = true
            return
        }
        passwordWarningLabel.isHidden = (password == passwordCheck)
    }
    
}
