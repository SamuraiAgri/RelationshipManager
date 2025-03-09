import SwiftUI

struct AppColors {
    // メインカラー
    static let primary = Color.blue // 青系の色
    static let secondary = Color.mint // ミント系の色
    
    // アクセントカラー
    static let accent = Color.orange // オレンジ系の色
    
    // 背景色
    static let background = Color(UIColor.systemBackground)
    static let cardBackground = Color(UIColor.secondarySystemBackground)
    
    // テキスト色
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)
    
    // カテゴリ色
    static let businessCategory = Color.blue
    static let privateCategory = Color.orange
    
    // 状態色
    static let success = Color.green
    static let warning = Color.yellow
    static let error = Color.red
    
    // 通信タイプ色
    static let callType = Color.green
    static let emailType = Color.cyan
    static let meetingType = Color.blue
    static let messageType = Color.teal
}

struct AppFonts {
    // 見出し
    static let largeTitle = Font.largeTitle
    static let title1 = Font.title
    static let title2 = Font.title2
    static let title3 = Font.title3
    
    // 本文
    static let bodyLarge = Font.body
    static let body = Font.body
    static let bodySmall = Font.callout
    
    // 強調
    static let headline = Font.headline
    static let subheadline = Font.subheadline
    
    // キャプション
    static let caption1 = Font.caption
    static let caption2 = Font.caption2
    
    // ボタン
    static let button = Font.headline
}
