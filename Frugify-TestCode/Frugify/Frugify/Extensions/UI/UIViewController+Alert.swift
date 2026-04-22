//
//  UIViewController+Alert.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

// MARK: - ViewController 공동 특성
extension UIViewController {
    
    // MARK: - 경고 문구
    func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - 회원가입 후 로그인 화면 전환 alert
    func signUpAfterAlert(title: String, message: String, onOK: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            onOK?()
        })
        present(alert, animated: true)
    }
    
}
