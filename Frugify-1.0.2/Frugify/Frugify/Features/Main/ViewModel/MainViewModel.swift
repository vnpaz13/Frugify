//
//  MainViewModel.swift
//  Frugify
//
//  Created by VnPaz on 1/7/26.
//


import Foundation

final class MainViewModel {
    
    // MARK: - 닉네임 가져오기
    func fetchNickname() async -> String? {
        do {
            let profile = try await SupabaseManager.shared.fetchMyProfile()
            let nickname = (profile.nickname?.trimmingCharacters(in: .whitespacesAndNewlines))
                .flatMap { $0.isEmpty ? nil : $0 }
            return nickname
        } catch {
            return nil
        }
    }
    
    // MARK: - Streak Badge 계산
    func fetchStreakDays() async -> Int {
        do {
            let calendar = Calendar.current
            let todayStart = calendar.startOfDay(for: Date())
            let yesterdayStart = calendar.date(byAdding: .day, value: -1, to: todayStart) ?? todayStart
            let start = calendar.date(byAdding: .day, value: -365, to: todayStart) ?? todayStart
            let end = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? Date()
            
            let records = try await SupabaseManager.shared.fetchRecords(from: start, to: end)
            
            // 기록이 있는 날짜들을 "일 단위"로 모아둠
            let recordedDays: Set<Date> = Set(records.map { calendar.startOfDay(for: $0.createdAt) })
            
            // 오늘 기록이 있으면 오늘부터 계산, 없으면 어제부터 계산
            let baseDay: Date
            if recordedDays.contains(todayStart) {
                baseDay = todayStart
            } else {
                // 어제도 기록이 없으면 streak는 0
                guard recordedDays.contains(yesterdayStart) else { return 0 }
                baseDay = yesterdayStart
            }
            
            // baseDay 연속 체크
            var streak = 0
            while true {
                guard let day = calendar.date(byAdding: .day, value: -streak, to: baseDay) else { break }
                if recordedDays.contains(day) {
                    streak += 1
                } else {
                    break
                }
            }
            return streak
        } catch {
            return 0
        }
    }
    
    // MARK: - 새 절약 기록 저장
    func createSavingRecord(_ record: NewSavingRecord) async throws -> SavingRecord {
        return try await SupabaseManager.shared.createSavingRecord(record)
    }
    
    // MARK: - 오늘 기록 조회
    private(set) var todayRecords: [SavingRecord] = []
    
    func refreshTodayRecords() async {
        do {
            var calendar = Calendar.current
            calendar.timeZone = TimeZone.autoupdatingCurrent
            
            let todayStart = calendar.startOfDay(for: Date())
            let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? Date()
            
            let records = try await SupabaseManager.shared.fetchRecords(from: todayStart, to: tomorrowStart)
            todayRecords = records
        } catch {
            todayRecords = []
        }
    }
    
    func hasTodayRecords() -> Bool {
        return !todayRecords.isEmpty
    }
    
    // MARK: - 절약 기록 스와이프로 삭제(수정)
    func deleteSavingRecord(id: Int) async throws {
        try await SupabaseManager.shared.deleteSavingRecord(id: id)
        todayRecords.removeAll { $0.id == id }
    }
    
}
