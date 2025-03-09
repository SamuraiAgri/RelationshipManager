
// UpcomingEventsView.swift
import SwiftUI

struct UpcomingEventsView: View {
    var events: [EventEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("今後の予定")
                .font(AppFonts.title3)
                .padding(.horizontal)
            
            if events.isEmpty {
                HStack {
                    Spacer()
                    Text("予定はありません")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                    Spacer()
                }
            } else {
                ForEach(events) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        EventRowView(event: event)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if event.id != events.last?.id {
                        Divider()
                            .padding(.horizontal)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// RecentContactsView.swift
import SwiftUI

struct RecentContactsView: View {
    var contacts: [ContactEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("最近の連絡先")
                .font(AppFonts.title3)
                .padding(.horizontal)
            
            if contacts.isEmpty {
                HStack {
                    Spacer()
                    Text("最近の連絡先はありません")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                    Spacer()
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(contacts) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
                                VStack {
                                    AvatarView(
                                        imageData: contact.profileImageData,
                                        initials: "\(contact.firstName.prefix(1))\(contact.lastName.prefix(1))",
                                        size: 60,
                                        backgroundColor: contact.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
                                    )
                                    
                                    Text("\(contact.firstName) \(contact.lastName)")
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(1)
                                    
                                    CategoryBadgeView(category: contact.category)
                                }
                                .frame(width: 100)
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// ReminderView.swift
import SwiftUI

struct ReminderView: View {
    var count: Int
    var events: [EventEntity]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundColor(AppColors.accent)
                
                Text("今日の予定: \(count)件")
                    .font(AppFonts.headline)
                
                Spacer()
                
                NavigationLink(destination: CalendarView()) {
                    Text("すべて見る")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            ForEach(events.prefix(3)) { event in
                HStack {
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(AppFonts.headline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if let details = event.details, !details.isEmpty {
                            Text(details)
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Text(event.startDate.formattedTime())
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
            }
        }
        .padding(.vertical, 10)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// EventRowView.swift
import SwiftUI

struct EventRowView: View {
    var event: EventEntity
    
    var body: some View {
        HStack(spacing: 15) {
            // 日付表示
            VStack(spacing: 5) {
                Text(formatDay(date: event.startDate))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
                
                Text(formatDayNumber(date: event.startDate))
                    .font(AppFonts.title2)
                    .foregroundColor(event.startDate.isToday ? AppColors.primary : AppColors.textPrimary)
                
                Text(formatMonth(date: event.startDate))
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 50)
            
            // 縦線
            Rectangle()
                .fill(event.startDate.isToday ? AppColors.primary : AppColors.textTertiary)
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
                    
                    Text(formatTime(date: event.startDate))
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
