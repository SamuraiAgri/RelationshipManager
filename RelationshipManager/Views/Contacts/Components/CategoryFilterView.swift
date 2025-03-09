
// CategoryFilterView.swift
import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: AppConstants.Category?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                CategoryFilterButton(
                    title: "すべて",
                    isSelected: selectedCategory == nil,
                    color: AppColors.primary
                ) {
                    selectedCategory = nil
                }
                
                ForEach(AppConstants.Category.allCases) { category in
                    CategoryFilterButton(
                        title: category.displayName,
                        isSelected: selectedCategory == category,
                        color: category == .business ? AppColors.businessCategory : AppColors.privateCategory
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryFilterButton: View {
    var title: String
    var isSelected: Bool
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(20)
        }
    }
}

#Preview {
    CategoryFilterView(selectedCategory: .constant(nil))
}
