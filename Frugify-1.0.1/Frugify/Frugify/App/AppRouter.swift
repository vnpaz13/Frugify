//
//  AppRouter.swift
//  Frugify
//
//  Created by VnPaz on 12/24/25.
//

import UIKit

enum AppRoot {
    case signIn
    case main
}

final class AppRouter {
    static func setRoot(_ root: AppRoot, animated: Bool) {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = scene.delegate as? SceneDelegate,
            let window = sceneDelegate.window
        else { return }

        let vc: UIViewController
        switch root {
        case .signIn:
            vc = UINavigationController(rootViewController: SignInVC())
        case .main:
            vc = TabBarController()
        }

        if animated {
            UIView.transition(with: window, duration: 0.25, options: .transitionCrossDissolve, animations: {
                window.rootViewController = vc
            })
        } else {
            window.rootViewController = vc
        }
        window.makeKeyAndVisible()
    }
}
