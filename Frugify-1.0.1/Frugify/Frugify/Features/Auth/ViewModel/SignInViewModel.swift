//
//  SignInViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

final class SignInViewModel {
    
    func isLoginEnabled(email: String, password: String) -> Bool {
        let id = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pw = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return !id.isEmpty && !pw.isEmpty
    }
    
    func signInAndFetchProfile(email: String, password: String) async throws -> UserRow {
        return try await SupabaseManager.shared.signInAndFetchProfile(email: email, password: password)
    }
}
