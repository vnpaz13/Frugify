//
//  SettingViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation
import UIKit

@MainActor
final class SettingViewModel {
    
    // MARK: - Output
    private(set) var profile: UserRow? {
        didSet { onProfileChanged?(profile) }
    }
    
    // 설정 화면 "아이디" 줄에 표시할 문자열
    private(set) var loginDisplayText: String = "-" {
        didSet { onLoginDisplayChanged?(loginDisplayText) }
    }
    
    // 화면 모드 설정
    private(set) var appearanceMode: AppAppearanceMode = AppAppearanceMode.load() {
        didSet { onAppearanceChanged?(appearanceMode) }
    }
    
    // MARK: - Callbacks (View -> VC)
    var onProfileChanged: ((UserRow?) -> Void)?
    var onLoginDisplayChanged: ((String) -> Void)?
    var onAppearanceChanged: ((AppAppearanceMode) -> Void)?
    var onError: ((String) -> Void)?
    var onToast: ((String) -> Void)?   
    
    // MARK: - 불러오기
    // 로그인한 사용자의 프로필 정보를 불러오고, 로그인 방식을 확인 후 설정에서 표시할 아이디 문자열 생성
    func load() async {
        do {
            // 프로필 조회
            let me = try await SupabaseManager.shared.fetchMyProfile()
            // profile didSet 실행 -> onProfileChanged 콜백을 통해 닉네임 UI 갱신
            self.profile = me
            
            // Supabase Auth에서 로그인 provider 조회
            let provider = try await SupabaseManager.shared.fetchAuthProvider()
            // loginDisplayText didSet이 실행되며 onLoginDisplayChanged 콜백을 통해 아이디 UI 갱신
            self.loginDisplayText = makeLoginDisplayText(provider: provider, email: me.userEmail)
            
        } catch {
            onError?(error.localizedDescription)
        }
    }

    // 아이디 항목에 표시할 문자열 결정
    private func makeLoginDisplayText(provider: String?, email: String?) -> String {
        
        // 이메일은 여러 분기에서 사용되므로, 공백 제거 후 한 번만 정규화 해서 재사용
        let normalEmail = (email ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch provider {
        case "apple":
            return "애플 계정으로 접속"
        case "google":
            return "구글 계정으로 접속"
        case "email":
            // 이메일 로그인 : 이메일이 있으면 보여주고, 없으면 "-"
            return normalEmail.isEmpty ? "-" : normalEmail
        default:
            break
        }
        
        // provider 못 얻었을 때: apple private relay면 애플로 처리
        if normalEmail.contains("privaterelay.appleid.com") {
            return "애플 계정으로 접속"
        }
        // 그 외: 이메일이 있으면 이메일, 없으면 "-"
        return normalEmail.isEmpty ? "-" : normalEmail
    }


    // MARK: - 다크모드
    func setAppearance(_ mode: AppAppearanceMode) {
        self.appearanceMode = mode
        mode.save()
        AppearanceManager.apply(mode: mode)
    }
    
    // MARK: - 닉네임
    func checkNicknameAvailable(_ nickname: String) async -> Bool {
        do {
            return try await SupabaseManager.shared.checkNicknameAvailable(nickname)
        } catch {
            onError?(error.localizedDescription)
            return false
        }
    }
    
    func updateNickname(_ nickname: String) async -> Bool {
        do {
            let updated = try await SupabaseManager.shared.updateMyNickname(nickname)
            self.profile = updated
            // Main에 즉시 반영시키는 이벤트
            NotificationCenter.default.post(
                name: .nicknameDidChange,
                object: nil,
                userInfo: ["nickname": nickname]
            )
            return true
        } catch {
            onError?(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 전체 기록 삭제
    func deleteAllRecords() async -> Bool {
        do {
            try await SupabaseManager.shared.deleteAllMyRecords()
            onToast?("전체 기록을 삭제했어요.")
            return true
        } catch {
            onError?(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 로그아웃
    func logout() async -> Bool {
        do {
            try await SupabaseManager.shared.signOut()
            return true
        } catch {
            onError?(error.localizedDescription)
            return false
        }
    }
    
    // MARK: - 회원 탈퇴
    func withdraw() async -> Bool {
        do {
            try await SupabaseManager.shared.withdrawAccount()
            return true
        } catch {
            onError?(error.localizedDescription)
            return false
        }
    }
}

// MARK: - 화면모드 열거형
enum AppAppearanceMode: Int, CaseIterable {
    case system = 0
    case dark = 1
    case light = 2
    
    var title: String {
        switch self {
        case .system: return "시스템 기본값"
        case .dark: return "다크모드"
        case .light: return "라이트모드"
        }
    }
    
    static func load() -> AppAppearanceMode {
        let view = UserDefaults.standard.integer(forKey: "appAppearanceMode")
        return AppAppearanceMode(rawValue: view) ?? .system
    }
    
    func save() {
        UserDefaults.standard.set(self.rawValue, forKey: "appAppearanceMode")
    }
}

// MARK: - 화면모드 적용
enum AppearanceManager {
    static func apply(mode: AppAppearanceMode) {
        let style: UIUserInterfaceStyle
        switch mode {
        case .system: style = .unspecified
        case .dark: style = .dark
        case .light: style = .light
        }

        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
            let activeScene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
            activeScene?.windows.forEach { $0.overrideUserInterfaceStyle = style }
        }
    }
}

// MARK: - 닉네임 변경 시 Main에 전달
extension Notification.Name {
    static let nicknameDidChange = Notification.Name("nicknameDidChange")
}
