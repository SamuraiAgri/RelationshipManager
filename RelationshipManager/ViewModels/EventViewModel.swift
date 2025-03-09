
import Foundation
import CoreData
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [EventEntity] = []
    @Published var filteredEvents: [EventEntity] = []
    @Published var upcomingEvents: [EventEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var searchText: String = ""
    
    private var viewContext: NSManagedObjectContext
    private var contact: ContactEntity?
    private var group: GroupEntity?
    
    init(context: NSManagedObjectContext, contact: ContactEntity? = nil, group: GroupEntity? = nil) {
        self.viewContext = context
        self.contact = contact
        self.group = group
        fetchEvents()
    }
    
    // すべてのイベントを取得
    func fetchEvents() {
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        
        // 特定の連絡先または特定のグループに関連するイベントのみを取得
        if let contact = contact {
            request.predicate = NSPredicate(format: "ANY contacts == %@", contact)
        } else if let group = group {
            request.predicate = NSPredicate(format: "group == %@", group)
        }
        
        // 開始日の昇順でソート
        request.sortDescriptors = [NSSortDescriptor(keyPath: \EventEntity.startDate, ascending: true)]
        
        do {
            events = try viewContext.fetch(request)
            filterEvents()
            updateUpcomingEvents()
        } catch {
            print("イベントの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // イベントのフィルタリング
    func filterEvents() {
        // 選択された日付と検索テキストに基づいてフィルタリング
        filteredEvents = events.filter { event in
            // 選択された日付でフィルタリング
            let calendar = Calendar.current
            if !calendar.isDate(event.startDate, inSameDayAs: selectedDate) {
                return false
            }
            
            // 検索テキストでフィルタリング
            if !searchText.isEmpty {
                let searchableText = "\(event.title) \(event.details ?? "")"
                return searchableText.lowercased().contains(searchText.lowercased())
            }
            
            return true
        }
    }
    
    // 今後のイベントを更新
    func updateUpcomingEvents() {
        let today = Calendar.current.startOfDay(for: Date())
        let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        
        upcomingEvents = events.filter { event in
            return event.startDate >= today && event.startDate <= oneMonthLater
        }
    }
    
    // 選択日を設定
    func setSelectedDate(_ date: Date) {
        selectedDate = date
        filterEvents()
    }
    
    // 検索テキストを設定
    func setSearchText(_ text: String) {
        searchText = text
        filterEvents()
    }
    
    // EventViewModelに追加するメソッド
    func getEventsForDay(date: Date) -> [EventEntity] {
        let calendar = Calendar.current
        return events.filter { event in
            guard let eventDate = event.startDate else { return false }
            return calendar.isDate(eventDate, inSameDayAs: date)
        }
    }
    
    // 新しいイベントを追加
    func addEvent(title: String, details: String?, startDate: Date, endDate: Date?, isAllDay: Bool,
                 location: String?, reminder: Bool, reminderDate: Date?, contacts: [ContactEntity], group: GroupEntity? = nil) -> EventEntity {
        let newEvent = EventEntity(context: viewContext)
        newEvent.id = UUID()
        newEvent.title = title
        newEvent.details = details
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.isAllDay = isAllDay
        newEvent.location = location
        newEvent.reminder = reminder
        newEvent.reminderDate = reminderDate
        newEvent.group = group
        newEvent.createdAt = Date()
        newEvent.updatedAt = Date()
        
        // 関連する連絡先を追加
        for contact in contacts {
            newEvent.addToContacts(contact)
        }
        
        saveContext()
        fetchEvents()
        
        // 通知をスケジュール
        if reminder, let reminderDate = reminderDate {
            NotificationManager.shared.scheduleEventNotification(for: newEvent)
        }
        
        return newEvent
    }
    
    // イベントを更新
    func updateEvent(_ event: EventEntity, title: String, details: String?, startDate: Date, endDate: Date?,
                    isAllDay: Bool, location: String?, reminder: Bool, reminderDate: Date?, contacts: [ContactEntity], group: GroupEntity? = nil) {
        event.title = title
        event.details = details
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        event.location = location
        event.reminder = reminder
        event.reminderDate = reminderDate
        event.group = group
        event.updatedAt = Date()
        
        // 既存の連絡先を削除
        let existingContacts = event.contacts?.allObjects as? [ContactEntity] ?? []
        for contact in existingContacts {
            event.removeFromContacts(contact)
        }
        
        // 新しい連絡先を追加
        for contact in contacts {
            event.addToContacts(contact)
        }
        
        saveContext()
        fetchEvents()
        
        // 通知を更新
        if reminder, let reminderDate = reminderDate {
            NotificationManager.shared.scheduleEventNotification(for: event)
        } else {
            NotificationManager.shared.removeEventNotification(for: event)
        }
    }
    
    // イベントを削除
    func deleteEvent(_ event: EventEntity) {
        // 通知を削除
        NotificationManager.shared.removeEventNotification(for: event)
        
        viewContext.delete(event)
        saveContext()
        fetchEvents()
    }
    
    // 複数のイベントを削除
    func deleteEvents(_ events: [EventEntity]) {
        for event in events {
            // 通知を削除
            NotificationManager.shared.removeEventNotification(for: event)
            
            viewContext.delete(event)
        }
        saveContext()
        fetchEvents()
    }
    
    // 連絡先に関連するすべてのイベントを削除
    func deleteAllEventsForContact(_ contact: ContactEntity) {
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        request.predicate = NSPredicate(format: "ANY contacts == %@", contact)
        
        do {
            let events = try viewContext.fetch(request)
            for event in events {
                // 通知を削除
                NotificationManager.shared.removeEventNotification(for: event)
                
                viewContext.delete(event)
            }
            saveContext()
            fetchEvents()
        } catch {
            print("イベントの削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 変更を保存
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("データの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 今日のイベントを取得
    func getTodayEvents() -> [EventEntity] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return events.filter { event in
            return event.startDate >= today && event.startDate < tomorrow
        }
    }
    
    // 今週のイベントを取得
    func getThisWeekEvents() -> [EventEntity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (weekday + 6) % 7 // 週の始まりを月曜日としたオフセット
        
        let startOfWeek = calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!
        
        return events.filter { event in
            return event.startDate >= startOfWeek && event.startDate < endOfWeek
        }
    }
    
    // 指定した月のイベントを取得
    func getEventsForMonth(month: Date) -> [EventEntity] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        let startOfMonth = calendar.date(from: components)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return events.filter { event in
            return event.startDate >= startOfMonth && event.startDate <= endOfMonth
        }
    }
    
    // 日付に基づいてグループ化されたイベントを取得
    func getGroupedEvents() -> [Date: [EventEntity]] {
        let groupedEvents = Dictionary(grouping: events) { event in
            return Calendar.current.startOfDay(for: event.startDate)
        }
        return groupedEvents
    }
}
