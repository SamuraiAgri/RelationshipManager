import Foundation
import CoreData
import SwiftUI

class EventViewModel: ObservableObject {
    @Published var events: [EventEntity] = []
    @Published var filteredEvents: [EventEntity] = []
    @Published var upcomingEvents: [EventEntity] = []
    @Published var selectedDate: Date = Date()
    @Published var searchText: String = ""
    
    // 誕生日イベントを保存する配列
    @Published var birthdayEvents: [BirthdayEvent] = []
    
    private var viewContext: NSManagedObjectContext
    private var contact: ContactEntity?
    private var group: GroupEntity?
    
    init(context: NSManagedObjectContext, contact: ContactEntity? = nil, group: GroupEntity? = nil) {
        self.viewContext = context
        self.contact = contact
        self.group = group
        fetchEvents()
        fetchBirthdayEvents() // 誕生日イベントも取得
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
    
    // 今後のイベントを更新
    func updateUpcomingEvents() {
        let today = Calendar.current.startOfDay(for: Date())
        let oneMonthLater = Calendar.current.date(byAdding: .month, value: 1, to: today)!
        
        upcomingEvents = events.filter { event in
            guard let startDate = event.startDate else { return false }
            return startDate >= today && startDate <= oneMonthLater
        }
    }
    
    // 全連絡先から誕生日情報を取得しイベントとして扱う
    func fetchBirthdayEvents() {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "birthday != nil")
        
        do {
            let contacts = try viewContext.fetch(request)
            birthdayEvents = []
            
            for contact in contacts {
                if let birthday = contact.birthday {
                    // 今年の誕生日を計算
                    let birthdayThisYear = calculateBirthdayForCurrentYear(originalDate: birthday)
                    
                    // 誕生日イベントを作成
                    let birthdayEvent = BirthdayEvent(
                        id: contact.id ?? UUID(),
                        contact: contact,
                        date: birthdayThisYear,
                        originalBirthDate: birthday
                    )
                    birthdayEvents.append(birthdayEvent)
                }
            }
        } catch {
            print("誕生日イベントの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 特定の日付の全イベント（通常イベント + 誕生日）を取得
    func getEventsForDay(date: Date) -> [EventEntity] {
        let regularEvents = events.filter { event in
            guard let eventDate = event.startDate else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: date)
        }
        
        // 誕生日イベントは変換しない（表示用のみの使用）
        return regularEvents
    }
    
    // 特定の日付の誕生日イベントを取得
    func getBirthdaysForDay(date: Date) -> [BirthdayEvent] {
        return birthdayEvents.filter { birthdayEvent in
            Calendar.current.isDate(birthdayEvent.date, inSameDayAs: date)
        }
    }
    
    // 特定の日付の全てのイベント情報（カレンダー表示用）
    func getAllEventsForDay(date: Date) -> (regularEvents: [EventEntity], birthdayEvents: [BirthdayEvent]) {
        let regular = getEventsForDay(date: date)
        let birthdays = getBirthdaysForDay(date: date)
        return (regular, birthdays)
    }
    
    // 今年の誕生日日付を計算
    private func calculateBirthdayForCurrentYear(originalDate: Date) -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // 元の誕生日から月と日を取得
        let month = calendar.component(.month, from: originalDate)
        let day = calendar.component(.day, from: originalDate)
        
        // 今年の日付を作成
        var dateComponents = DateComponents()
        dateComponents.year = currentYear
        dateComponents.month = month
        dateComponents.day = day
        
        // 今年の誕生日
        if let thisYearBirthday = calendar.date(from: dateComponents) {
            // 今日より前なら来年の誕生日を返す
            if thisYearBirthday < Date() {
                dateComponents.year = currentYear + 1
                return calendar.date(from: dateComponents) ?? thisYearBirthday
            }
            return thisYearBirthday
        }
        
        // 日付の変換に失敗した場合は元の日付を返す（通常発生しない）
        return originalDate
    }
    
    // イベントのフィルタリング
    func filterEvents() {
        // 選択された日付と検索テキストに基づいてフィルタリング
        filteredEvents = events.filter { event in
            // 選択された日付でフィルタリング
            let calendar = Calendar.current
            guard let eventStartDate = event.startDate else { return false }
            
            if !calendar.isDate(eventStartDate, inSameDayAs: selectedDate) {
                return false
            }
            
            // 検索テキストでフィルタリング
            if !searchText.isEmpty {
                let title = event.title ?? ""
                let details = event.details ?? ""
                let searchableText = "\(title) \(details)"
                return searchableText.lowercased().contains(searchText.lowercased())
            }
            
            return true
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
    
    // 指定した日付のイベントを取得
    func getEventsForDayOriginal(date: Date) -> [EventEntity] {
        return events.filter { event in
            guard let eventDate = event.startDate else { return false }
            return Calendar.current.isDate(eventDate, inSameDayAs: date)
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
            guard let startDate = event.startDate else { return false }
            return startDate >= today && startDate < tomorrow
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
            guard let startDate = event.startDate else { return false }
            return startDate >= startOfWeek && startDate < endOfWeek
        }
    }
    
    // 指定した月のイベントを取得
    func getEventsForMonth(month: Date) -> [EventEntity] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: month)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        guard let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else { return [] }
        
        return events.filter { event in
            guard let startDate = event.startDate else { return false }
            return startDate >= startOfMonth && startDate <= endOfMonth
        }
    }
    
    // 日付に基づいてグループ化されたイベントを取得
    func getGroupedEvents() -> [Date: [EventEntity]] {
        let groupedEvents = Dictionary(grouping: events) { event in
            guard let startDate = event.startDate else { return Date() }
            return Calendar.current.startOfDay(for: startDate)
        }
        return groupedEvents
    }
}

// 誕生日イベントを表すモデル
struct BirthdayEvent: Identifiable {
    let id: UUID
    let contact: ContactEntity
    let date: Date
    let originalBirthDate: Date
    
    var age: Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: originalBirthDate, to: Date())
        return ageComponents.year ?? 0
    }
    
    var title: String {
        return "\(contact.fullName)の誕生日"
    }
    
    var details: String {
        return "\(age)歳になります"
    }
}
