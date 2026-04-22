//
//  SignUpViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

final class SignUpViewModel {
    
    func isSignUpEnabled(
        email: String,
        password: String,
        passwordCheck: String,
        nickname: String,
        isUserEmailAvailable: Bool,
        lastCheckedUserEmail: String,
        isNicknameAvailable: Bool,
        lastCheckedNickname: String
    ) -> Bool {
        let em = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let pwC = passwordCheck.trimmingCharacters(in: .whitespacesAndNewlines)
        let nn = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 1) 기본 입력값 채워짐
        let basicFilled = !em.isEmpty && !pw.isEmpty && !pwC.isEmpty && !nn.isEmpty
        // 2) 비밀번호 일치
        let passwordMatched = (pw == pwC)
        // 3) 이메일 중복확인 완료 + 현재 이메일이 "확인했던 이메일"과 동일
        let userEmailVerified = isUserEmailAvailable && (em == lastCheckedUserEmail)
        // 4) 닉네임 중복확인 완료 + 현재 닉네임이 "확인했던 닉네임"과 동일
        let nicknameVerified = isNicknameAvailable && (nn == lastCheckedNickname)
        
        return basicFilled && passwordMatched && userEmailVerified && nicknameVerified
    }
    
    // true = 이미 존재(중복)
    func checkUserEmailDuplicate(_ userEmail: String) async throws -> Bool {
        return try await SupabaseManager.shared.checkUserEmailDuplicate(userEmail)
    }
    
    // true = 사용 가능(테이블에 없음)
    func checkNicknameAvailable(_ nickName: String) async throws -> Bool {
        return try await SupabaseManager.shared.checkNicknameAvailable(nickName)
    }
    
    func register(email: String, password: String, nickname: String) async throws {
        try await SupabaseManager.shared.register(email: email, password: password, nickname: nickname)
    }
}
