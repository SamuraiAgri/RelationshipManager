import Foundation
import SwiftUI

extension EventEntity {
    var contactsArray: [ContactEntity] {
        let set = contacts as? Set<ContactEntity> ?? []
        return set.sorted { ($0.sortableName) < ($1.sortableName) }
    }
    
    var contactNames: String {
        let names = contactsArray.map { $0.fullName }
        if names.isEmpty {
            return "参加者なし"
        } else if names.count == 1 {
            return names[0]
        } else {
            return "\(names[0])他 \(names.count - 1)名"
        }
    }
    
    var durationInMinutes: Int {
        guard let startDate = startDate, let endDate = endDate else { return 60 }  // デフォルト1時間
        return Calendar.current.dateComponents([.minute], from: startDate, to: endDate).minute ?? 60
    }
    
    var durationString: String {
        if isAllDay {
            return "終日"
        }
        
        let minutes = durationInMinutes
        if minutes < 60 {
            return "\(minutes)分"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            
            if remainingMinutes == 0 {
                return "\(hours)時間"
            } else {
                return "\(hours)時間\(remainingMinutes)分"
            }
        }
    }
    
    var formattedStartDate: String {
        return startDate?.formatted(date: .medium, time: .none) ?? ""
    }
    
    var formattedStartTime: String {
        if isAllDay {
            return "終日"
        }
        return startDate?.formattedTime(style: .short) ?? ""
    }
    
    var isUpcoming: Bool {
        guard let startDate = startDate else { return false }
        return startDate > Date()
    }
    
    var isPast: Bool {
        guard let startDate = startDate else { return false }
        return startDate < Date()
    }
    
    var isToday: Bool {
        guard let startDate = startDate else { return false }
        return Calendar.current.isDateInToday(startDate)
    }
    
    var dayOfMonth: Int {
        guard let startDate = startDate else { return 1 }
        return Calendar.current.component(.day, from: startDate)
    }
    
    var monthString: String {
        guard let startDate = startDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: startDate)
    }
    
    var weekdayString: String {
        guard let startDate = startDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: startDate)
    }
    
    func scheduleReminder() {
        if reminder, let reminderDate = reminderDate {
            NotificationManager.shared.scheduleEventNotification(for: self)
        }
    }
    
    func cancelReminder() {
        NotificationManager.shared.removeEventNotification(for: self)
    }
}
