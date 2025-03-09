
import Foundation
import SwiftUI

extension GroupEntity {
    var contactsArray: [ContactEntity] {
        let set = contacts as? Set<ContactEntity> ?? []
        return set.sorted { $0.sortableName < $1.sortableName }
    }
    
    var eventsArray: [EventEntity] {
        let set = events as? Set<EventEntity> ?? []
        return set.sorted { $0.startDate < $1.startDate }
    }
    
    var upcomingEvents: [EventEntity] {
        let now = Date()
        return eventsArray.filter { $0.startDate > now }
    }
    
    var memberCount: Int {
        return contactsArray.count
    }
    
    var eventCount: Int {
        return eventsArray.count
    }
    
    var categoryColor: Color {
        return category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
    }
    
    var categoryDisplayName: String {
        if category == AppConstants.Category.business.rawValue {
            return AppConstants.Category.business.displayName
        } else {
            return AppConstants.Category.private.displayName
        }
    }
    
    var description: String? {
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
