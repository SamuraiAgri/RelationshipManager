
import Foundation
import CoreData
import UIKit

extension ContactEntity {
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    var initials: String {
        let firstInitial = firstName.prefix(1).uppercased()
        let lastInitial = lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
    
    var profileImage: UIImage? {
        if let imageData = profileImageData {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    var age: Int? {
        guard let birthday = birthday else { return nil }
        return Calendar.current.dateComponents([.year], from: birthday, to: Date()).year
    }
    
    var sortableName: String {
        return "\(lastName)\(firstName)"
    }
    
    var communicationsArray: [CommunicationEntity] {
        let set = communications as? Set<CommunicationEntity> ?? []
        return set.sorted { $0.date > $1.date }
    }
    
    var eventsArray: [EventEntity] {
        let set = events as? Set<EventEntity> ?? []
        return set.sorted { $0.startDate < $1.startDate }
    }
    
    var groupsArray: [GroupEntity] {
        let set = groups as? Set<GroupEntity> ?? []
        return set.sorted { $0.name < $1.name }
    }
    
    var upcomingEvents: [EventEntity] {
        let now = Date()
        return eventsArray.filter { $0.startDate > now }
    }
    
    var isPrimaryBusiness: Bool {
        return category == AppConstants.Category.business.rawValue
    }
    
    func addProfileImage(_ image: UIImage, compression: CGFloat = 0.7) {
        profileImageData = image.jpegData(compressionQuality: compression)
    }
}
