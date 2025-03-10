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
