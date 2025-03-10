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
                                        initials: "\((contact.firstName ?? "").prefix(1))\((contact.lastName ?? "").prefix(1))",
                                        size: 60,
                                        backgroundColor: contact.category == AppConstants.Category.business.rawValue ?
                                            AppColors.businessCategory : AppColors.privateCategory
                                    )
                                    
                                    Text(contact.fullName)
                                        .font(AppFonts.subheadline)
                                        .foregroundColor(AppColors.textPrimary)
                                        .lineLimit(1)
                                        .frame(width: 100)
                                    
                                    CategoryBadgeView(category: contact.category ?? "")
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
