//
//  SettingVC.swift
//  Frugify
//
//  Created by VnPaz on 1/3/26.
//
import UIKit
import SafariServices

@MainActor
final class SettingVC: UIViewController {
    
    private let viewModel = SettingViewModel()
    
    private var withdrawRow: SettingRowView!
    
    // MARK: - ScrollView
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - UI
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        return stackView
    }()
    
    // Rows
    private var nicknameRow: SettingRowView!
    private var emailRow: SettingRowView!
    private var darkModeRow: SettingRowView!
    private var deleteAllRow: SettingRowView!
    private var termsRow: SettingRowView!
    private var privacyRow: SettingRowView!
    private var versionRow: SettingRowView!
    private var logoutRow: SettingRowView!
    
    // MARK: - 개인정보 처리방침, 이용약관 주소
    private enum LegalURL {
        static let privacy = "https://frugifyservice.github.io/frugify-legal/privacy.html"
        static let terms   = "https://frugifyservice.github.io/frugify-legal/terms.html"
    }
    
    private func presentInAppBrowser(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            showAlert(title: "오류", message: "URL이 올바르지 않습니다.")
            return
        }
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .pageSheet
        present(safariVC, animated: true)
    }

    
    // MARK: - LifeCycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    
        setupLayout()
        setupRows()
        bindViewModel()
        
        Task { await viewModel.load() }
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupRows() {
        // 계정
        stackView.addArrangedSubview(makeSectionHeader("계정"))
        
        nicknameRow = SettingRowView(title: "닉네임", rightText: "-", actionText: "변경")
        nicknameRow.enableActionButtonTap(true)
        nicknameRow.onTapActionButton = { [weak self] in self?.presentNicknamePopup() }
        
        emailRow = SettingRowView(title: "아이디", rightText: "-", actionText: nil)
        
        stackView.addArrangedSubview(nicknameRow)
        stackView.addArrangedSubview(emailRow)
        stackView.addArrangedSubview(makeMajorSeparator())
        
        // 앱 설정
        stackView.addArrangedSubview(makeSectionHeader("앱 설정"))
        
        darkModeRow = SettingRowView(title: "화면 모드", rightText: viewModel.appearanceMode.title, actionText: nil)
        darkModeRow.enableRightTextTap(true)
        darkModeRow.onTapRightText = { [weak self] in self?.presentAppearanceSheet() }
        
        deleteAllRow = SettingRowView(title: "전체 기록 삭제", rightText: nil, actionText: nil)
        deleteAllRow.setTitleColor(.systemRed)
        deleteAllRow.enableLeftTextTap(true)
        deleteAllRow.onTapLeftText = { [weak self] in self?.confirmDeleteAll() }
        
        stackView.addArrangedSubview(darkModeRow)
        stackView.addArrangedSubview(deleteAllRow)
        
        stackView.addArrangedSubview(makeMajorSeparator())
        
        // 이용 안내
        stackView.addArrangedSubview(makeSectionHeader("이용 안내"))
        
        termsRow = SettingRowView(title: "이용약관", rightText: nil, actionText: nil)
        termsRow.enableLeftTextTap(false)
        termsRow.setIcon(systemName: "doc.text")
        termsRow.enableIconTap(true)
        termsRow.onTapIcon = { [weak self] in self?.openTerms() }
        
        privacyRow = SettingRowView(title: "개인정보 처리방침", rightText: nil, actionText: nil)
        privacyRow.enableLeftTextTap(false)
        privacyRow.setIcon(systemName: "doc.text")
        privacyRow.enableIconTap(true)
        privacyRow.onTapIcon = { [weak self] in self?.openPrivacy() }

        versionRow = SettingRowView(title: "앱 버전", rightText: appVersionText(), actionText: nil)
        
        // 문의
        let contactRow = SettingRowView(title: "문의 메일", rightText: "frugifyservice@gmail.com", actionText: nil)

        
        stackView.addArrangedSubview(termsRow)
        stackView.addArrangedSubview(privacyRow)
        stackView.addArrangedSubview(versionRow)
        stackView.addArrangedSubview(contactRow)
        stackView.addArrangedSubview(makeMajorSeparator())
        
        // 로그아웃
        logoutRow = SettingRowView(title: "로그아웃", rightText: nil, actionText: nil)
        logoutRow.setTitleColor(.systemRed)
        logoutRow.enableLeftTextTap(true)
        logoutRow.onTapLeftText = { [weak self] in self?.confirmLogout() }
        stackView.addArrangedSubview(logoutRow)
        
        // 회원탈퇴
        withdrawRow = SettingRowView(title: "회원 탈퇴", rightText: nil, actionText: nil)
        withdrawRow.setTitleColor(.systemRed)
        withdrawRow.enableLeftTextTap(true)
        withdrawRow.onTapLeftText = { [weak self] in self?.confirmWithdraw() }
        stackView.addArrangedSubview(withdrawRow)
    }
    
    // ViewModel 받아와서 VC에 반영
    private func bindViewModel() {
        viewModel.onProfileChanged = { [weak self] me in
            guard let self else { return }
            
            // 닉네임: nil/빈값이면 "닉네임 없음"
            let nick = (me?.nickname ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            nicknameRow.setRightText(nick.isEmpty ? "닉네임 없음" : nick)
            
        }
        
        // 로그인 방식 표시 문자열 변경 시 호출됨
        viewModel.onLoginDisplayChanged = { [weak self] text in
            self?.emailRow.setRightText(text)
        }
        
        // 화면 모드 변경 시 호출됨
        viewModel.onAppearanceChanged = { [weak self] mode in
            self?.darkModeRow.setRightText(mode.title)
        }
        
        // 에러 발생 시 호출됨
        viewModel.onError = { [weak self] msg in
            self?.showAlert(title: "오류", message: msg)
        }
        
        // 간단한 사용자 알림 발생 시 호출됨
        viewModel.onToast = { [weak self] msg in
            self?.showAlert(title: nil, message: msg)
        }
    }
    
    // MARK: - Section Header + Major Separator
    private func makeSectionHeader(_ title: String) -> UIView {
        let wrap = UIView()
        wrap.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        wrap.addSubview(label)
        NSLayoutConstraint.activate([
            wrap.heightAnchor.constraint(equalToConstant: 44),
            label.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8)
        ])
        return wrap
    }
    
    private func makeMajorSeparator() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .separator
        
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
        
        // 양 옆 inset 20
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 16), // 섹션 간 여백 포함
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            view.centerYAnchor.constraint(equalTo: container.centerYAnchor)
        ])
        
        return container
    }
    
    // MARK: - Actions
    private func presentNicknamePopup() {
        let current = viewModel.profile?.nickname ?? ""
        let popup = NicknameEditPopupVC(currentNickname: current, viewModel: viewModel)
        present(popup, animated: true)
    }
    
    private func presentAppearanceSheet() {
        let alert = UIAlertController(title: "화면 모드", message: nil, preferredStyle: .actionSheet)
        AppAppearanceMode.allCases.forEach { mode in
            alert.addAction(UIAlertAction(title: mode.title, style: .default, handler: { [weak self] _ in
                self?.viewModel.setAppearance(mode)
            }))
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }
    
    private func confirmDeleteAll() {
        let alert = UIAlertController(
            title: "전체 기록을 삭제하시겠습니까?",
            message: "삭제하시면 복구하실 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            Task { _ = await self.viewModel.deleteAllRecords() }
        }))
        present(alert, animated: true)
    }
    
    private func confirmLogout() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            Task {
                let ok = await self.viewModel.logout()
                if ok { self.routeToSignIn() }
            }
        }))
        present(alert, animated: true)
    }
    
    private func confirmWithdraw() {
        let alert = UIAlertController(
            title: "회원 탈퇴",
            message: "계정과 모든 기록이 삭제됩니다.\n삭제 후에는 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "탈퇴", style: .destructive, handler: { [weak self] _ in
            guard let self else { return }
            Task {
                let ok = await self.viewModel.withdraw()
                if ok {
                    // 탈퇴도 로그아웃처럼 SignIn으로
                    AppRouter.setRoot(.signIn, animated: true)
                }
            }
        }))
        present(alert, animated: true)
    }
    
    // MARK: - 이용약관, 개인정보처리방침 액션
    private func openTerms() {
        presentInAppBrowser(LegalURL.terms)
    }
    
    private func openPrivacy() {
        presentInAppBrowser(LegalURL.privacy)
    }
    
    private func routeToSignIn() {
        let signInVC = SignInVC()
        let nav = UINavigationController(rootViewController: signInVC)
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        } else {
            present(nav, animated: true)
        }
    }
    
    private func appVersionText() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
    
    private func showAlert(title: String?, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - 스크롤 올리기
    func scrollToTop(animated: Bool) {
        scrollView.setContentOffset(.zero, animated: animated)
    }
}
