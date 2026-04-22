//
//  SplashViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import Foundation

final class SplashViewModel {
    
    func checkSession() async -> AppRoot {
        let loggedIn = await SupabaseManager.shared.hasValidSession()
        return loggedIn ? .main : .signIn
    }
}
