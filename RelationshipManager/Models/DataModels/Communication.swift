import Foundation
import SwiftUI

extension CommunicationEntity {
    var typeEnum: CommunicationType? {
        return CommunicationType(rawValue: type ?? "")
    }
    
    var typeDisplayName: String {
        return typeEnum?.displayName ?? type ?? ""
    }
    
    var typeColor: Color {
        switch type {
        case CommunicationType.call.rawValue:
            return AppColors.callType
        case CommunicationType.email.rawValue:
            return AppColors.emailType
        case CommunicationType.meeting.rawValue:
            return AppColors.meetingType
        case CommunicationType.message.rawValue:
            return AppColors.messageType
        default:
            return AppColors.primary
        }
    }
    
    var typeIconName: String {
        switch type {
        case CommunicationType.call.rawValue:
            return "phone"
        case CommunicationType.email.rawValue:
            return "envelope"
        case CommunicationType.meeting.rawValue:
            return "person.2"
        case CommunicationType.message.rawValue:
            return "message"
        default:
            return "circle"
        }
    }
    
    var formattedDate: String {
        return date?.formatted(date: .medium, time: .none) ?? ""
    }
    
    var formattedTime: String {
        return date?.formattedTime(style: .short) ?? ""
    }
    
    var relativeTimeString: String {
        return date?.relativeFormatted ?? ""
    }
    
    var daysSinceNow: Int {
        guard let date = date else { return 0 }
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        return components.day ?? 0
    }
}

// コミュニケーションタイプの定義
enum CommunicationType: String, CaseIterable, Identifiable {
    case call = "Call"
    case email = "Email"
    case meeting = "Meeting"
    case message = "Message"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .call:
            return "通話"
        case .email:
            return "メール"
        case .meeting:
            return "会議"
        case .message:
            return "メッセージ"
        }
    }
}
