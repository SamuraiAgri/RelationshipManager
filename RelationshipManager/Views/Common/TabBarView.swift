
// TabBarView.swift
import SwiftUI

struct TabBarView: View {
    @State private var selectedTab = 0
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }
                .tag(0)
            
            ContactsListView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("連絡先", systemImage: "person.crop.circle")
                }
                .tag(1)
            
            CalendarView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(2)
            
            GroupsView()
                .environment(\.managedObjectContext, viewContext)
                .tabItem {
                    Label("グループ", systemImage: "person.3")
                }
                .tag(3)
        }
        .accentColor(AppColors.primary)
    }
}

// AvatarView.swift
import SwiftUI

struct AvatarView: View {
    var imageData: Data?
    var initials: String
    var size: CGFloat
    var backgroundColor: Color
    
    init(imageData: Data?, initials: String, size: CGFloat = 40, backgroundColor: Color = AppColors.primary) {
        self.imageData = imageData
        self.initials = initials
        self.size = size
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                )
                .shadow(radius: 2)
        } else {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: size, height: size)
                    .shadow(radius: 2)
                
                Text(initials)
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// CategoryBadgeView.swift
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

// ActionButtonView.swift
import SwiftUI

struct ActionButtonView: View {
    var icon: String
    var action: () -> Void
    var color: Color = AppColors.primary
    var size: CGFloat = 50
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundColor(.white)
                .frame(width: size, height: size)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 3)
        }
    }
}
