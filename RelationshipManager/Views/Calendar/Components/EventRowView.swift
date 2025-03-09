
import SwiftUI

struct EventRowView: View {
    var event: EventEntity
    
    var body: some View {
        HStack(spacing: 15) {
            // 日付表示
            VStack(spacing: 5) {
                Text(event.weekdayString)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                
                Text("\(event.dayOfMonth)")
                    .font(AppFonts.title2)
                    .foregroundColor(event.isToday ? AppColors.primary : AppColors.textPrimary)
                
                Text(event.monthString)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 50)
            
            // 縦線
            Rectangle()
                .fill(event.isToday ? AppColors.primary : AppColors.textTertiary)
                .frame(width: 2)
                .padding(.vertical, 5)
            
            // イベント情報
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                if let details = event.details, !details.isEmpty {
                    Text(details)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text(event.formattedStartTime)
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let location = event.location, !location.isEmpty {
                        Spacer()
                            .frame(width: 10)
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(location)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                if event.contactsArray.count > 0 {
                    HStack {
                        Image(systemName: "person.2")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(event.contactNames)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(AppFonts.subheadline)
                .foregroundColor(AppColors.textTertiary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let event = EventEntity(context: context)
    event.id = UUID()
    event.title = "プロジェクトミーティング"
    event.details = "第3四半期のレビュー"
    event.startDate = Date()
    event.isAllDay = false
    event.location = "会議室A"
    
    return EventRowView(event: event)
        .previewLayout(.sizeThatFits)
        .padding()
}
