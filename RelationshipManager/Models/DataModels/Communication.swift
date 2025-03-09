
import Foundation
import SwiftUI

extension CommunicationEntity {
    var typeEnum: AppConstants.CommunicationType? {
        return AppConstants.CommunicationType(rawValue: type)
    }
    
    var typeDisplayName: String {
        return typeEnum?.displayName ?? type
    }
    
    var typeColor: Color {
        switch type {
        case AppConstants.CommunicationType.call.rawValue:
            return AppColors.callType
        case AppConstants.CommunicationType.email.rawValue:
            return AppColors.emailType
        case AppConstants.CommunicationType.meeting.rawValue:
            return AppColors.meetingType
        case AppConstants.CommunicationType.message.rawValue:
            return AppColors.messageType
        default:
            return AppColors.primary
        }
    }
    
    var typeIconName: String {
        switch type {
        case AppConstants.CommunicationType.call.rawValue:
            return "phone"
        case AppConstants.CommunicationType.email.rawValue:
            return "envelope"
        case AppConstants.CommunicationType.meeting.rawValue:
            return "person.2"
        case AppConstants.CommunicationType.message.rawValue:
            return "message"
        default:
            return "circle"
        }
    }
    
    var formattedDate: String {
        return date.formatted(style: .medium)
    }
    
    var formattedTime: String {
        return date.formattedTime(style: .short)
    }
    
    var relativeTimeString: String {
        return date.relativeFormatted
    }
    
    var daysSinceNow: Int {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day], from: date, to: now)
        return components.day ?? 0
    }
}
