//
//  UIViewController+KeyBoard.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

extension UIViewController {

    // MARK: - 이외 화면 터치 시 키보드 내리기
    func keyboardDismissGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

}
