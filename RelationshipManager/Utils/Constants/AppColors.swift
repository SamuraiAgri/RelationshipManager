import SwiftUI

struct AppColors {
    // メインカラー
    static let primary = Color(hex: "6A5AE0") // 深みのある紫
    static let secondary = Color(hex: "A89AF9") // ライトパープル
    
    // アクセントカラー
    static let accent = Color(hex: "FF8A65") // コーラル
    
    // 背景色
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground).opacity(0.95)
    
    // テキスト色
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // カテゴリ色
    static let businessCategory = Color(hex: "5C6BC0") // インディゴブルー
    static let privateCategory = Color(hex: "FF8A65") // コーラル
    
    // 状態色
    static let success = Color(hex: "66BB6A") // 明るい緑
    static let warning = Color(hex: "FFCA28") // アンバー
    static let error = Color(hex: "EF5350") // 明るい赤
    
    // 通信タイプ色
    static let callType = Color(hex: "66BB6A") // 緑
    static let emailType = Color(hex: "42A5F5") // ブルー
    static let meetingType = Color(hex: "5C6BC0") // インディゴ
    static let messageType = Color(hex: "26A69A") // ティール
    
    // グラデーション
    static let gradientPrimary = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "6A5AE0"), Color(hex: "A89AF9")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let gradientAccent = LinearGradient(
        gradient: Gradient(colors: [Color(hex: "FF8A65"), Color(hex: "FFAB91")]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct AppFonts {
    // 見出し
    static let largeTitle = Font.largeTitle.weight(.bold)
    static let title1 = Font.title.weight(.bold)
    static let title2 = Font.title2.weight(.semibold)
    static let title3 = Font.title3.weight(.semibold)
    
    // 本文
    static let bodyLarge = Font.body.weight(.medium)
    static let body = Font.body
    static let bodySmall = Font.callout
    
    // 強調
    static let headline = Font.headline.weight(.semibold)
    static let subheadline = Font.subheadline
    
    // キャプション
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
    
    // ボタン
    static let button = Font.headline.weight(.semibold)
}

// HEXカラーコードを使用できるようにColor拡張
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
