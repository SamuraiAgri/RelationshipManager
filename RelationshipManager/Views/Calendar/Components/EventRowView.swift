import SwiftUI

struct EventRowView: View {
    var event: EventEntity
    
    var body: some View {
        HStack(spacing: 15) {
            // 日付表示
            VStack(spacing: 5) {
                Text(formatDay(date: event.startDate ?? Date()))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(formatDayNumber(date: event.startDate ?? Date()))
                    .font(AppFonts.title2)
                    .foregroundColor((event.startDate?.isToday ?? false) ? AppColors.primary : AppColors.textPrimary)
                
                Text(formatMonth(date: event.startDate ?? Date()))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 50)
            
            // 縦線
            Rectangle()
                .fill((event.startDate?.isToday ?? false) ? AppColors.primary : AppColors.textTertiary)
                .frame(width: 2)
                .padding(.vertical, 5)
            
            // イベント情報
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title ?? "無題")
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
                    
                    Text(formatTime(date: event.startDate ?? Date()))
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let location = event.location, !location.isEmpty {
                        Spacer()
                        
                        Image(systemName: "mappin.and.ellipse")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(location)
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
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
    
    // 曜日のフォーマット
    private func formatDay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 日付の数字部分のフォーマット
    private func formatDayNumber(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // 月のフォーマット
    private func formatMonth(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 時刻のフォーマット
    private func formatTime(date: Date) -> String {
        if event.isAllDay {
            return "終日"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}
