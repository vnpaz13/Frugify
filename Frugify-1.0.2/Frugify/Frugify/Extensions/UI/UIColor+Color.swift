//
//  UIViewController+Color.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

// MARK: - 색상
extension UIColor {
   
    // SplashVC 배경 화면이자 앞으로 이 앱의 기본 초록색 컬러
    static var basicGreen: UIColor {
        return UIColor(named: "09A840") ?? UIColor(red: 9/255, green: 168/255, blue: 64/255, alpha: 1.0)
    }
    
    // 설명 글씨 색상
    static var textSecondary: UIColor {
        return UIColor.secondaryLabel
    }
    
    // 입력창 백그라운드 색상
    static var backgroundSecondary: UIColor {
        return UIColor.secondarySystemBackground
    }
    
    // 테두리 색상
    static var cardBorder: UIColor {
        return UIColor.opaqueSeparator
    }
}
