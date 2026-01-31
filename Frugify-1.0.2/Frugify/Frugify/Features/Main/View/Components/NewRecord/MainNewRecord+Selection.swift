//
//  MainNewRecord+Selection.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//

import UIKit

extension MainNewRecord {
    
    // MARK: - 사용자가 선택한 감정을 유일한 항목으로 만들고, 그 감정을 저장한다
    func selectEmotionCard(_ tapped: EmotionCard) {
        // 두번 누르면 해제
        if tapped.isSelected {
            getEmotionCards().forEach { $0.isSelected = false }
            setSelectedEmotion(nil)
            print("selected emotion: \(tapped.emotion.title) 해제")
            updateSaveButtonState()
            return
        }
        
        let selectedID = tapped.emotion.id
        getEmotionCards().forEach { card in
            card.isSelected = (card.emotion.id == selectedID)
        }
        setSelectedEmotion(tapped.emotion)
        print("selected emotion:", tapped.emotion.title)
        updateSaveButtonState()
    }
    
    // MARK: - 사용자가 선택한 카테고리를 유일한 항목으로 만들고, 그 카드를 저장한다
    func selectCategoryCard(_ tapped: CategoryCard) {
        // 두번 누르면 해제
        if tapped.isSelected {
            getCategoryCards().forEach { $0.isSelected = false }
            setSelectedCategory(nil)
            print("selected category: \(tapped.category.title) 해제")
            updateSaveButtonState()
            return
        }
        
        let selectedID = tapped.category.id
        getCategoryCards().forEach { card in
            card.isSelected = (card.category.id == selectedID)
        }
        setSelectedCategory(tapped.category)
        print("selected category:", tapped.category.title)
        updateSaveButtonState()
    }
    
    // MARK: - 감정 선택 초기화
    func resetEmotionSelection() {
        getEmotionCards().forEach { $0.isSelected = false }
        setSelectedEmotion(nil)
    }
    
    // MARK: - 카테고리 선택 초기화
    func resetCategorySelection() {
        getCategoryCards().forEach { $0.isSelected = false }
        setSelectedCategory(nil)
    }
}
