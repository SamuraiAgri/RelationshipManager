
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

struct ActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            ActionButtonView(icon: "plus", action: {})
            ActionButtonView(icon: "pencil", action: {}, color: AppColors.accent)
            ActionButtonView(icon: "trash", action: {}, color: AppColors.error, size: 40)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
