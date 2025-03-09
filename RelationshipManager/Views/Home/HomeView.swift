
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: HomeViewModel
    
    // 初期化
    init() {
        // StateObjectの初期化はinitで行う必要があります
        _viewModel = StateObject(wrappedValue: HomeViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // リマインダーセクション
                    if viewModel.reminderCount > 0 {
                        ReminderView(count: viewModel.reminderCount, events: viewModel.getTodayEvents())
                    }
                    
                    // 今日の誕生日セクション
                    if !viewModel.todaysBirthdays.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("今日の誕生日")
                                .font(AppFonts.title3)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 15) {
                                    ForEach(viewModel.todaysBirthdays) { contact in
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
                                                
                                                if let age = viewModel.getAge(for: contact) {
                                                    Text("\(age)歳")
                                                        .font(AppFonts.caption1)
                                                        .foregroundColor(AppColors.textSecondary)
                                                }
                                            }
                                            .padding(.vertical, 5)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 10)
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                        .padding(.horizontal)
                    }
                    
                    // 今後のイベントセクション
                    UpcomingEventsView(events: viewModel.upcomingEvents)
                    
                    // 最近の連絡先セクション
                    RecentContactsView(contacts: viewModel.recentContacts)
                }
                .padding(.vertical)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.fetchData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchData()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
