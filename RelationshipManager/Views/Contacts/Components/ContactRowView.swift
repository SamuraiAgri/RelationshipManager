import SwiftUI

struct ContactRowView: View {
    var contact: ContactEntity
    var isSelected: Bool = false
    var isMultiSelectionMode: Bool = false
    
    var body: some View {
        HStack(spacing: 15) {
            if isMultiSelectionMode {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textTertiary)
                    .font(.system(size: 22))
            }
            
            // イニシャルを安全に取得する
            let firstName = contact.firstName ?? ""
            let lastName = contact.lastName ?? ""
            let firstInitial = firstName.isEmpty ? "" : String(firstName.prefix(1))
            let lastInitial = lastName.isEmpty ? "" : String(lastName.prefix(1))
            let initials = "\(firstInitial)\(lastInitial)"
            
            AvatarView(
                imageData: contact.profileImageData,
                initials: initials,
                size: 50,
                backgroundColor: contact.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(firstName) \(lastName)")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                    Text(phoneNumber)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                } else if let email = contact.email, !email.isEmpty {
                    Text(email)
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            CategoryBadgeView(category: contact.category ?? "")
        }
        .padding(.vertical, 8)
    }
}
