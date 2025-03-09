
import SwiftUI

struct RelationshipMapView: View {
    var group: GroupEntity
    @StateObject private var viewModel: GroupViewModel
    
    init(group: GroupEntity) {
        self.group = group
        _viewModel = StateObject(wrappedValue: GroupViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }
    
    var body: some View {
        VStack {
            Text("メンバー関係図")
                .font(AppFonts.title3)
                .padding(.top)
            
            // 簡易的な関係図表示
            ZStack {
                // 中央のグループ
                Circle()
                    .fill(group.categoryColor)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Text(group.name.prefix(2))
                            .font(AppFonts.title3)
                            .foregroundColor(.white)
                    )
                
                // メンバーをグループの周りに配置
                let members = group.contactsArray
                ForEach(Array(members.enumerated()), id: \.element.id) { index, contact in
                    if let id = contact.id {
                        let angle = 2 * .pi / Double(max(1, members.count)) * Double(index)
                        let radius: CGFloat = 120
                        let x = radius * cos(angle)
                        let y = radius * sin(angle)
                        
                        // 線を引く
                        Line(from: .zero, to: CGPoint(x: x, y: y))
                            .stroke(AppColors.textTertiary, lineWidth: 1)
                        
                        // メンバーアバター
                        AvatarView(
                            imageData: contact.profileImageData,
                            initials: contact.initials,
                            size: 50,
                            backgroundColor: contact.category == AppConstants.Category.business.rawValue ?
                                AppColors.businessCategory : AppColors.privateCategory
                        )
                        .position(x: x, y: y)
                        .overlay(
                            Text(contact.fullName)
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textPrimary)
                                .background(AppColors.cardBackground.opacity(0.8))
                                .padding(2)
                                .offset(y: 30)
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding()
        }
        .onAppear {
            viewModel.fetchGroups()
        }
    }
}

// 線を描画するためのビュー
struct Line: Shape {
    var from: CGPoint
    var to: CGPoint
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX + from.x, y: rect.midY + from.y))
        path.addLine(to: CGPoint(x: rect.midX + to.x, y: rect.midY + to.y))
        return path
    }
}

struct RelationshipMapView_Previews: PreviewProvider {
    static var previews: some View {
        let previewContext = PersistenceController.preview.container.viewContext
        let group = previewContext.registeredObjects.first { $0 is GroupEntity } as! GroupEntity
        
        return RelationshipMapView(group: group)
            .previewLayout(.sizeThatFits)
            .frame(height: 400)
    }
}
