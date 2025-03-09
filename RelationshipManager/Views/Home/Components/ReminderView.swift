
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
                ForEach(events.prefix(3)) { event in
                    NavigationLink(destination: EventDetailView(event: event)) {
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
                            
                            Text(event.formattedStartTime)
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primary)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                    
                    if event.id != events.prefix(3).last?.id {
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

struct ReminderView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let event = EventEntity(context: previewContext)
        event.id = UUID()
        event.title = "プロジェクトミーティング"
        event.details = "第3四半期のレビュー"
        event.startDate = Date()
        event.isAllDay = false
        
        return ReminderView(count: 1, events: [event])
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
