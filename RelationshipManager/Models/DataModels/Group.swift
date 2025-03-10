import Foundation
import SwiftUI

extension GroupEntity {
    var contactsArray: [ContactEntity] {
        let set = contacts as? Set<ContactEntity> ?? []
        return set.sorted { ($0.sortableName) < ($1.sortableName) }
    }
    
    var eventsArray: [EventEntity] {
        let set = events as? Set<EventEntity> ?? []
        return set.sorted { ($0.startDate ?? Date()) < ($1.startDate ?? Date()) }
    }
    
    var upcomingEvents: [EventEntity] {
        let now = Date()
        return eventsArray.filter { ($0.startDate ?? Date()) > now }
    }
    
    var memberCount: Int {
        return contactsArray.count
    }
    
    var eventCount: Int {
        return eventsArray.count
    }
    
    var categoryColor: Color {
        return category == Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
    }
    
    var categoryDisplayName: String {
        if category == Category.business.rawValue {
            return Category.business.displayName
        } else {
            return Category.private.displayName
        }
    }
    
    // この部分を修正 - 名前を'description'から'groupDescription'に変更し、競合を避ける
    var groupDescription: String? {
        return descriptionText
    }
    
    var memberAvatars: [ContactEntity] {
        // 最大5人まで返す
        return Array(contactsArray.prefix(5))
    }
    
    func addMember(_ contact: ContactEntity) {
        addToContacts(contact)
    }
    
    func removeMember(_ contact: ContactEntity) {
        removeFromContacts(contact)
    }
    
    func addEvent(_ event: EventEntity) {
        addToEvents(event)
    }
    
    func removeEvent(_ event: EventEntity) {
        removeFromEvents(event)
    }
}
