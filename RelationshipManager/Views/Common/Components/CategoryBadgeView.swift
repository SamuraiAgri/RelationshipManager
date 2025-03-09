
import SwiftUI

struct CategoryBadgeView: View {
    var category: String
    var fontSize: CGFloat = 12
    
    var body: some View {
        Text(getCategoryDisplayName())
            .font(.system(size: fontSize, weight: .medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(getCategoryColor())
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private func getCategoryDisplayName() -> String {
        if category == AppConstants.Category.business.rawValue {
            return AppConstants.Category.business.displayName
        } else {
            return AppConstants.Category.private.displayName
        }
    }
    
    private func getCategoryColor() -> Color {
        if category == AppConstants.Category.business.rawValue {
            return AppColors.businessCategory
        } else {
            return AppColors.privateCategory
        }
    }
}

struct CategoryBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CategoryBadgeView(category: AppConstants.Category.business.rawValue)
            CategoryBadgeView(category: AppConstants.Category.private.rawValue)
            CategoryBadgeView(category: AppConstants.Category.business.rawValue, fontSize: 16)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
