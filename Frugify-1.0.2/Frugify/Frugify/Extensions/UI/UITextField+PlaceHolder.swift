//
//  UITextField+PlaceHolder.swift
//  Frugify
//
//  Created by VnPaz on 1/14/26.
//

import UIKit

extension UITextField {
    // 포커스 들어오면 placeholder 숨기고, 비어있게 끝나면 원래 placeholder 복구
    func setupFocusPlaceholderBehavior() {
        addTarget(self, action: #selector(_hidePlaceholderOnFocus), for: .editingDidBegin)
        addTarget(self, action: #selector(_restorePlaceholderIfNeeded), for: .editingDidEnd)
    }

    @objc private func _hidePlaceholderOnFocus() {
        // 원래 placeholder 저장
        if objc_getAssociatedObject(self, &AssociatedKeys.placeholderKey) == nil {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.placeholderKey,
                self.placeholder,
                .OBJC_ASSOCIATION_COPY_NONATOMIC
            )
        }
        self.placeholder = nil
    }

    @objc private func _restorePlaceholderIfNeeded() {
        let text = (self.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty else { return }

        if let original = objc_getAssociatedObject(self, &AssociatedKeys.placeholderKey) as? String {
            self.placeholder = original
        }
    }
}

private enum AssociatedKeys {
    static var placeholderKey: UInt8 = 0
}
