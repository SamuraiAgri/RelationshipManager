
import SwiftUI

struct CommunicationRowView: View {
    var communication: CommunicationEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: getTypeIconName())
                    .foregroundColor(getTypeColor())
                
                Text(getTypeDisplayName())
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(getRelativeTimeString())
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(communication.content ?? "")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }
    
    // コミュニケーションタイプアイコンを取得
    private func getTypeIconName() -> String {
        switch communication.type {
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
    
    // コミュニケーションタイプの色を取得
    private func getTypeColor() -> Color {
        switch communication.type {
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
    
    // コミュニケーションタイプの表示名を取得
    private func getTypeDisplayName() -> String {
        switch communication.type {
        case AppConstants.CommunicationType.call.rawValue:
            return AppConstants.CommunicationType.call.displayName
        case AppConstants.CommunicationType.email.rawValue:
            return AppConstants.CommunicationType.email.displayName
        case AppConstants.CommunicationType.meeting.rawValue:
            return AppConstants.CommunicationType.meeting.displayName
        case AppConstants.CommunicationType.message.rawValue:
            return AppConstants.CommunicationType.message.displayName
        default:
            return communication.type ?? ""
        }
    }
    
    // 相対的な時間表現を取得
    private func getRelativeTimeString() -> String {
        guard let date = communication.date else { return "" }
        return date.relativeFormatted
    }
}

#Preview {
    let previewContext = PersistenceController.preview.container.viewContext
    let communication = previewContext.registeredObjects.first { $0 is CommunicationEntity } as! CommunicationEntity
    
    return CommunicationRowView(communication: communication)
        .previewLayout(.sizeThatFits)
        .padding()
}
