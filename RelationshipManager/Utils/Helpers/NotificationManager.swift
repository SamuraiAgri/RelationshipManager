

// NotificationManager.swift
import Foundation
import UserNotifications
import CoreData

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
        content.title = event.title ?? "イベント"
        
        if let details = event.details, !details.isEmpty {
            content.body = details
        } else {
            content.body = "リマインダー: \(event.title ?? "イベント")"
        }
        
        content.sound = .default
        if let id = event.id?.uuidString {
            content.userInfo = ["eventID": id]
        }
        
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
