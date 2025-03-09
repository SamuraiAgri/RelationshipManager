
import Foundation
import CoreData
import SwiftUI

class HomeViewModel: ObservableObject {
    @Published var upcomingEvents: [EventEntity] = []
    @Published var recentContacts: [ContactEntity] = []
    @Published var todaysBirthdays: [ContactEntity] = []
    @Published var reminderCount: Int = 0
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchData()
    }
    
    // すべてのデータを取得
    func fetchData() {
        fetchUpcomingEvents()
        fetchRecentContacts()
        fetchTodaysBirthdays()
        updateReminderCount()
    }
    
    // 今後のイベントを取得
    private func fetchUpcomingEvents() {
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        
        // 現在より後のイベントのみを取得
        let now = Date()
        let predicate = NSPredicate(format: "startDate >= %@", now as NSDate)
        request.predicate = predicate
        
        // 開始日の昇順でソート
        request.sortDescriptors = [NSSortDescriptor(keyPath: \EventEntity.startDate, ascending: true)]
        
        // 表示数を制限
        request.fetchLimit = 5
        
        do {
            upcomingEvents = try viewContext.fetch(request)
        } catch {
            print("イベントの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 最近の連絡先を取得
    private func fetchRecentContacts() {
        // 最近のコミュニケーションに基づいて連絡先を取得
        let communicationRequest = NSFetchRequest<CommunicationEntity>(entityName: "CommunicationEntity")
        
        // 日付の降順でソート
        communicationRequest.sortDescriptors = [NSSortDescriptor(keyPath: \CommunicationEntity.date, ascending: false)]
        
        // 表示数を制限
        communicationRequest.fetchLimit = 10
        
        do {
            let recentCommunications = try viewContext.fetch(communicationRequest)
            
            // 重複を排除して連絡先を抽出
            var uniqueContacts: [ContactEntity] = []
            for communication in recentCommunications {
                if let contact = communication.contact, !uniqueContacts.contains(where: { $0.id == contact.id }) {
                    uniqueContacts.append(contact)
                    
                    // 最大5件まで
                    if uniqueContacts.count >= 5 {
                        break
                    }
                }
            }
            
            recentContacts = uniqueContacts
        } catch {
            print("コミュニケーションの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 今日の誕生日がある連絡先を取得
    private func fetchTodaysBirthdays() {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        
        // 今日の日付に一致する誕生日を持つ連絡先を取得
        let calendar = Calendar.current
        let today = Date()
        
        let monthPredicate = NSPredicate(format: "MONTH(birthday) == %d", calendar.component(.month, from: today))
        let dayPredicate = NSPredicate(format: "DAY(birthday) == %d", calendar.component(.day, from: today))
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [monthPredicate, dayPredicate])
        request.predicate = predicate
        
        // 名前順でソート
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ContactEntity.firstName, ascending: true)]
        
        do {
            todaysBirthdays = try viewContext.fetch(request)
        } catch {
            print("誕生日の取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // リマインダーの数を更新
    private func updateReminderCount() {
        let request = NSFetchRequest<EventEntity>(entityName: "EventEntity")
        
        // 今日のイベントを取得
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let predicate = NSPredicate(format: "startDate >= %@ AND startDate < %@", today as NSDate, tomorrow as NSDate)
        request.predicate = predicate
        
        do {
            let todayEvents = try viewContext.fetch(request)
            reminderCount = todayEvents.count
        } catch {
            print("リマインダーの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 今日のイベントを取得
    func getTodayEvents() -> [EventEntity] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return upcomingEvents.filter { event in
            return event.startDate >= today && event.startDate < tomorrow
        }
    }
    
    // 今週のイベントを取得
    func getThisWeekEvents() -> [EventEntity] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: today)!
        
        return upcomingEvents.filter { event in
            return event.startDate >= today && event.startDate < nextWeek
        }
    }
    
    // 連絡先の誕生日までの日数を取得
    func getDaysUntilBirthday(for contact: ContactEntity) -> Int? {
        guard let birthday = contact.birthday else {
            return nil
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 今年の誕生日
        let birthdayMonth = calendar.component(.month, from: birthday)
        let birthdayDay = calendar.component(.day, from: birthday)
        let todayYear = calendar.component(.year, from: today)
        
        var birthdayThisYear = calendar.date(from: DateComponents(year: todayYear, month: birthdayMonth, day: birthdayDay))!
        
        // 今年の誕生日がすでに過ぎている場合は来年の誕生日を計算
        if birthdayThisYear < today {
            birthdayThisYear = calendar.date(from: DateComponents(year: todayYear + 1, month: birthdayMonth, day: birthdayDay))!
        }
        
        let daysUntilBirthday = calendar.dateComponents([.day], from: today, to: birthdayThisYear).day
        return daysUntilBirthday
    }
    
    // 連絡先の年齢を取得
    func getAge(for contact: ContactEntity) -> Int? {
        guard let birthday = contact.birthday else {
            return nil
        }
        
        return birthday.age()
    }
}
