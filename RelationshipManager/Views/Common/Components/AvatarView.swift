
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

struct AvatarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AvatarView(imageData: nil, initials: "AB", size: 60, backgroundColor: AppColors.primary)
            AvatarView(imageData: nil, initials: "CD", size: 60, backgroundColor: AppColors.businessCategory)
            AvatarView(imageData: nil, initials: "EF", size: 60, backgroundColor: AppColors.privateCategory)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
