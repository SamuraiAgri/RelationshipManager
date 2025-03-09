
// NotificationManager.swift
import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestAuthorization()
    }
    
    // 通知の許可を要求
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("通知の許可が得られました")
            } else if let error = error {
                print("通知の許可エラー: \(error.localizedDescription)")
            }
        }
    }
    
    // イベント通知のスケジュール
    func scheduleEventNotification(for event: EventEntity) {
        // リマインダーが設定されていない場合は通知をスケジュールしない
        guard event.reminder, let reminderDate = event.reminderDate else { return }
        
        // 過去の日時の場合は通知をスケジュールしない
        if reminderDate < Date() {
            return
        }
        
        // イベントの既存の通知を削除
        removeEventNotification(for: event)
        
        // 通知コンテンツの作成
        let content = UNMutableNotificationContent()
        content.title = event.title
        
        if let details = event.details, !details.isEmpty {
            content.body = details
        } else {
            content.body = "リマインダー: \(event.title)"
        }
        
        content.sound = .default
        content.userInfo = ["eventID": event.id?.uuidString ?? ""]
        
        // 通知トリガーの作成
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // 通知リクエストの作成
        let request = UNNotificationRequest(
            identifier: "event_\(event.id?.uuidString ?? UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        // 通知のスケジュール
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知のスケジュールエラー: \(error.localizedDescription)")
            }
        }
    }
    
    // 既存のイベント通知を削除
    func removeEventNotification(for event: EventEntity) {
        guard let eventID = event.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["event_\(eventID)"])
    }
    
    // すべての保留中の通知を取得
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
    
    // すべての保留中の通知を削除
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}

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
        ekEvent.title = event.title
        ekEvent.notes = event.details
        ekEvent.startDate = event.startDate
        ekEvent.endDate = event.endDate ?? event.startDate.addingTimeInterval(3600) // デフォルトで1時間
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
