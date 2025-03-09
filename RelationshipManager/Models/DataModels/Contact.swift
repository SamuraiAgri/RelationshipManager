import Foundation
import CoreData
import UIKit

extension ContactEntity {
    var fullName: String {
        return "\(firstName ?? "") \(lastName ?? "")"
    }
    
    var initials: String {
        let firstInitial = (firstName ?? "").prefix(1).uppercased()
        let lastInitial = (lastName ?? "").prefix(1).uppercased()
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
        return "\(lastName ?? "")\(firstName ?? "")"
    }
    
    var communicationsArray: [CommunicationEntity] {
        let set = communications as? Set<CommunicationEntity> ?? []
        return set.sorted { ($0.date ?? Date()) > ($1.date ?? Date()) }
    }
    
    var eventsArray: [EventEntity] {
        let set = events as? Set<EventEntity> ?? []
        return set.sorted { ($0.startDate ?? Date()) < ($1.startDate ?? Date()) }
    }
    
    var groupsArray: [GroupEntity] {
        let set = groups as? Set<GroupEntity> ?? []
        return set.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    var upcomingEvents: [EventEntity] {
        let now = Date()
        return eventsArray.filter { ($0.startDate ?? Date()) > now }
    }
    
    var isPrimaryBusiness: Bool {
        return category == Category.business.rawValue
    }
    
    func addProfileImage(_ image: UIImage, compression: CGFloat = 0.7) {
        profileImageData = image.jpegData(compressionQuality: compression)
    }
}

// カテゴリの定義
enum Category: String, CaseIterable, Identifiable {
    case business = "Business"
    case `private` = "Private"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .business:
            return "仕事"
        case .private:
            return "プライベート"
        }
    }
}
