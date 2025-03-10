import SwiftUI

struct GroupRowView: View {
    var group: GroupEntity
    @StateObject private var viewModel = GroupViewModel(context: PersistenceController.shared.container.viewContext)
    
    var body: some View {
        HStack(spacing: 15) {
            // グループアイコン
            ZStack {
                Circle()
                    .fill(group.categoryColor)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            
            // グループ情報
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name ?? "")
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Image(systemName: "person.fill")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text("\(group.memberCount)人")
                        .font(AppFonts.bodySmall)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let description = group.groupDescription, !description.isEmpty {
                        Text("・")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(description)
                            .font(AppFonts.bodySmall)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            CategoryBadgeView(category: group.category ?? "")
        }
        .padding(.vertical, 8)
        .onAppear {
            viewModel.fetchGroups()
        }
    }
}
