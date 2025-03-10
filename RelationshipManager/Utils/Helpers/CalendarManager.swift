// CalendarManager.swift
import Foundation
import EventKit

class CalendarManager {
    static let shared = CalendarManager()
    
    private let eventStore = EKEventStore()
    private var accessGranted = false
    
    private init() {
        requestAccess()
    }
    
    // カレンダーへのアクセスを要求
    func requestAccess() {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if granted {
                self.accessGranted = true
                print("カレンダーへのアクセスが許可されました")
            } else if let error = error {
                print("カレンダーのアクセスエラー: \(error.localizedDescription)")
            }
        }
    }
    
    // イベントをカレンダーに追加
    func addEventToCalendar(event: EventEntity, completion: @escaping (Bool, String?) -> Void) {
        // アクセスが許可されていない場合
        if !accessGranted {
            completion(false, "カレンダーへのアクセスが許可されていません")
            return
        }
        
        let ekEvent = EKEvent(eventStore: eventStore)
        ekEvent.title = event.title ?? "無題のイベント"
        ekEvent.notes = event.details
        
        // startDateがnilの場合は現在時刻を使用
        guard let startDate = event.startDate else {
            completion(false, "イベントの開始時間が設定されていません")
            return
        }
        
        ekEvent.startDate = startDate
        
        // endDateがnilの場合は、startDateから1時間後を使用
        if let endDate = event.endDate {
            ekEvent.endDate = endDate
        } else {
            ekEvent.endDate = startDate.addingTimeInterval(3600) // デフォルトで1時間
        }
        
        ekEvent.isAllDay = event.isAllDay
        
        if let locationString = event.location, !locationString.isEmpty {
            ekEvent.location = locationString
        }
        
        // リマインダーの設定
        if event.reminder, let reminderDate = event.reminderDate {
            let alarm = EKAlarm(absoluteDate: reminderDate)
            ekEvent.addAlarm(alarm)
        }
        
        // デフォルトカレンダーの取得
        ekEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(ekEvent, span: .thisEvent)
            completion(true, nil)
        } catch {
            completion(false, error.localizedDescription)
        }
    }
    
    // カレンダーからイベントを削除
    func removeEventFromCalendar(withIdentifier identifier: String, completion: @escaping (Bool, String?) -> Void) {
        // アクセスが許可されていない場合
        if !accessGranted {
            completion(false, "カレンダーへのアクセスが許可されていません")
            return
        }
        
        // イベントの検索と削除
        if let ekEvent = eventStore.event(withIdentifier: identifier) {
            do {
                try eventStore.remove(ekEvent, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error.localizedDescription)
            }
        } else {
            completion(false, "指定されたイベントが見つかりませんでした")
        }
    }
    
    // 特定の日付範囲のイベントを取得
    func fetchEvents(from startDate: Date, to endDate: Date) -> [EKEvent] {
        // アクセスが許可されていない場合
        if !accessGranted {
            return []
        }
        
        // イベントを検索するカレンダーを指定
        let calendars = eventStore.calendars(for: .event)
        
        // イベントの検索条件
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: calendars)
        
        // イベントの取得
        let events = eventStore.events(matching: predicate)
        return events
    }
}
