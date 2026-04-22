//
//  SupabaseManager.swift
//  Frugify
//
//  Created by VnPaz on 12/24/25.
//

import Foundation
import Supabase

@MainActor
// MARK: - SupabaseKey숨기기
final class SupabaseManager {
    
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        guard let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_KEY") as? String else {
            fatalError("SUPABASE_KEY not found in Info.plist")
        }
        
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://gmgsizkjdvqfcyooimno.supabase.co")!,
            supabaseKey: supabaseKey
        )
    }
    
    func register(email: String, password: String, nickname: String) async throws {
        try await client.auth.signUp(
            email: email,
            password: password,
            data: [
                "nickname": .string(nickname)
            ]
        )
    }
    
    // MARK: - 소셜 (구글) 로그인
    enum SocialProvider {
        case google
        case apple
        
        var supabaseProvider: Provider {
            switch self {
            case .google: return .google
            case .apple:  return .apple
            }
        }
    }
    
    private let oauthRedirectURL = URL(string: "frugify://auth-callback")!
    
    //  모든 소셜 OAuth는 여기로 통일
    func startOAuth(_ provider: SocialProvider, queryParams: [(String, String)]? = nil) async throws {
        try await client.auth.signInWithOAuth(
            provider: provider.supabaseProvider,
            redirectTo: oauthRedirectURL,
            queryParams: queryParams ?? []
        )
    }
    
    // MARK: - 기존 함수명 유지 (호출부 최소 수정용)
    
    // Google OAuth 시작
    func startGoogleOAuth() async throws {
        try await startOAuth(.google)
    }
    
    // Google OAuth 시작 (계정 선택창 강제 등 옵션 필요할 때)
    func startGoogleOAuth(promptSelectAccount: Bool) async throws {
        let params: [(String, String)]? = promptSelectAccount ? [("prompt", "select_account")] : nil
        try await startOAuth(.google, queryParams: params)
    }
    
    // Apple OAuth 시작
    func startAppleOAuth() async throws {
        try await startOAuth(.apple)
    }
}

// MARK: - extension
extension SupabaseManager {
    
    // 로그인(Auth)
    func signIn(email: String, password: String) async throws {
        try await client.auth.signIn(email: email, password: password)
    }
    
    // 로그인 후 내 프로필(public.users) 가져오기
    func fetchMyProfile() async throws -> UserRow {
        let user = try await client.auth.user()
        
        // id로 조회 (users.id = auth.users.id)
        let rows: [UserRow] = try await client
            .from("users")
            .select("id, user_email, nickname, created_at")
            .eq("id", value: user.id)
            .limit(1)
            .execute()
            .value
        
        guard let me = rows.first else {
            throw NSError(domain: "Profile", code: 404, userInfo: [NSLocalizedDescriptionKey: "프로필을 찾을 수 없어요."])
        }
        return me
    }
    
    // 편의: 로그인 + 프로필까지 한번에
    func signInAndFetchProfile(email: String, password: String) async throws -> UserRow {
        try await signIn(email: email, password: password)
        return try await fetchMyProfile()
    }
    
    // LogSessionCheck 로그인 성공 여부 확인
    func hasValidSession() async -> Bool {
        do {
            _ = try await client.auth.user()
            return true
        } catch {
            return false
        }
    }
    
    // 현재 로그인 provider 가져오기: "apple" / "google" / "email" 등
    func fetchAuthProvider() async throws -> String? {
        
        // Supabase Auth에 저장된 현재 로그인 사용자 정보 가져오기
        let user = try await client.auth.user()

        // appMetadata["provider"]는 AnyJSON 같은 타입이라, String 캐스팅이 아니라 패턴매칭으로 꺼내야 함
        if let value = user.appMetadata["provider"] {
            switch value {
            case .string(let providerString):
                return providerString
            default:
                break
            }
        }
        return nil
    }

    
    // LogOut
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    // MARK: - 새 절약 기록 만들기
    func createSavingRecord(_ record: NewSavingRecord) async throws -> SavingRecord {
        let user = try await client.auth.user()
        
        let request = CreateRecordRequest(
            userId: user.id,
            emotionId: record.emotionId,
            category: record.category,
            amount: record.amount,
            memo: record.memo
        )
        
        let rows: [SavingRecord] = try await client
            .from("records")
            .insert(request)
            .select()
            .execute()
            .value
        
        guard let record = rows.first else {
            throw NSError(
                domain: "records",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: "저장 결과를 받지 못했어요."]
            )
        }
        return record
    }
    
    // MARK: - 이메일, 닉네임 중복 체크를 위한 Supabase 조회
    func checkUserEmailDuplicate(_ userEmail: String) async throws -> Bool {
        let result: [UserInfoDup] = try await SupabaseManager.shared.client
            .from("users")
            .select("id")
            .eq("user_email", value: userEmail)
            .limit(1)
            .execute()
            .value
        
        return !result.isEmpty
    }
    
    func checkNicknameAvailable(_ nickname: String) async throws -> Bool {
        let result: [UserInfoDup] = try await SupabaseManager.shared.client
            .from("users")
            .select("id")
            .eq("nickname", value: nickname)
            .limit(1)
            .execute()
            .value
        
        return result.isEmpty   // 비어있으면 사용 가능
    }
    
    // MARK: - Streak Badge 계산
    func fetchRecords(from start: Date, to end: Date) async throws -> [SavingRecord] {
        let user = try await client.auth.user()
        
        let rows: [SavingRecord] = try await client
            .from("records")
            .select()
            .eq("user_id", value: user.id)
            .gte("created_at", value: start)
            .lt("created_at", value: end)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return rows
    }
    
    // MARK: - 절약 기록 삭제
    func deleteSavingRecord(id: Int) async throws {
        try await client
            .from("records")
            .delete()
            .eq("id", value: id)
            .execute()
    }
    
    // MARK: - 닉네임 업데이트 (public.users)
    func updateMyNickname(_ newNickname: String) async throws -> UserRow {
        let user = try await client.auth.user()
        
        // users 테이블에서 내 row 업데이트
        let rows: [UserRow] = try await client
            .from("users")
            .update(["nickname": newNickname])
            .eq("id", value: user.id)
            .select("id, user_email, nickname, created_at")
            .limit(1)
            .execute()
            .value
        
        guard let updated = rows.first else {
            throw NSError(domain: "users", code: 500, userInfo: [NSLocalizedDescriptionKey: "닉네임 업데이트 결과를 받지 못했어요."])
        }
        return updated
    }
    
    // MARK: - 전체 기록 삭제 (records)
    func deleteAllMyRecords() async throws {
        let user = try await client.auth.user()
        try await client
            .from("records")
            .delete()
            .eq("user_id", value: user.id)
            .execute()
    }
    
    // MARK: - 내 전체 절약 기록 가져오기
    func fetchAllMyRecords() async throws -> [SavingRecord] {
        let user = try await client.auth.user()
        
        let rows: [SavingRecord] = try await client
            .from("records")
            .select()
            .eq("user_id", value: user.id)
            .order("created_at", ascending: false)
            .execute()
            .value
        
        return rows
    }
    
    // MARK: - 계정 생성일 받아오기
    // 계정 생성일(public.users.created_at)
    func fetchMyCreatedAt() async throws -> Date {
        let profile = try await fetchMyProfile()
        return profile.createdAt
    }
    
    // MARK: - 회원 탈퇴 (서버에서 auth.users까지 삭제)
       func withdrawAccount() async throws {
           // 1) access token 얻기
           let session = try await client.auth.session
           let token = session.accessToken

           // 2) Edge Function 호출
           try await callWithdrawFunction(accessToken: token)

           // 3) 로컬 세션 정리
           try await client.auth.signOut()
       }

       private func callWithdrawFunction(accessToken: String) async throws {
           // 내 EndpointURL
           let url = URL(string: "https://gmgsizkjdvqfcyooimno.supabase.co/functions/v1/delete-account")!

           var req = URLRequest(url: url)
           req.httpMethod = "POST"
           req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
           req.setValue("application/json", forHTTPHeaderField: "Content-Type")
           req.httpBody = Data("{}".utf8)

           let (data, resp) = try await URLSession.shared.data(for: req)

           guard let http = resp as? HTTPURLResponse else {
               throw NSError(domain: "withdraw", code: -1, userInfo: [NSLocalizedDescriptionKey: "서버 응답이 올바르지 않습니다."])
           }
           guard (200..<300).contains(http.statusCode) else {
               let msg = String(data: data, encoding: .utf8) ?? "탈퇴 처리 실패"
               throw NSError(domain: "withdraw", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: msg])
           }
       }
}
