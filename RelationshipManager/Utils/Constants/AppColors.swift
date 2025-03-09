
// AppColors.swift
import SwiftUI

struct AppColors {
    // メインカラー
    static let primary = Color("PrimaryColor") // #4A90E2 - 青系の色
    static let secondary = Color("SecondaryColor") // #50E3C2 - ミント系の色
    
    // アクセントカラー
    static let accent = Color("AccentColor") // #FF9500 - オレンジ系の色
    
    // 背景色
    static let background = Color("BackgroundColor") // #F8F8F8 - 薄いグレー
    static let cardBackground = Color("CardBackgroundColor") // #FFFFFF - 白
    
    // テキスト色
    static let textPrimary = Color("TextPrimaryColor") // #333333 - 濃いグレー
    static let textSecondary = Color("TextSecondaryColor") // #666666 - 中程度のグレー
    static let textTertiary = Color("TextTertiaryColor") // #999999 - 薄いグレー
    
    // カテゴリ色
    static let businessCategory = Color("BusinessCategoryColor") // #4A90E2 - 青系の色
    static let privateCategory = Color("PrivateCategoryColor") // #FF9500 - オレンジ系の色
    
    // 状態色
    static let success = Color("SuccessColor") // #4CD964 - 緑
    static let warning = Color("WarningColor") // #FFCC00 - 黄色
    static let error = Color("ErrorColor") // #FF3B30 - 赤
    
    // 通信タイプ色
    static let callType = Color("CallTypeColor") // #4CD964 - 緑
    static let emailType = Color("EmailTypeColor") // #5AC8FA - 薄い青
    static let meetingType = Color("MeetingTypeColor") // #007AFF - 濃い青
    static let messageType = Color("MessageTypeColor") // #34C759 - ターコイズ
}

// AppFonts.swift
import SwiftUI

struct AppFonts {
    // 見出し
    static let largeTitle = Font.system(size: 34, weight: .bold)
    static let title1 = Font.system(size: 28, weight: .bold)
    static let title2 = Font.system(size: 22, weight: .bold)
    static let title3 = Font.system(size: 20, weight: .semibold)
    
    // 本文
    static let bodyLarge = Font.system(size: 17)
    static let body = Font.system(size: 15)
    static let bodySmall = Font.system(size: 13)
    
    // 強調
    static let headline = Font.system(size: 17, weight: .semibold)
    static let subheadline = Font.system(size: 15, weight: .semibold)
    
    // キャプション
    static let caption1 = Font.system(size: 12)
    static let caption2 = Font.system(size: 11)
    
    // ボタン
    static let button = Font.system(size: 17, weight: .semibold)
}

// AppConstants.swift
import Foundation

struct AppConstants {
    // カテゴリ
    enum Category: String, CaseIterable, Identifiable {
        case business = "Business"
        case `private` = "Private"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .business:
                return "仕事"
            case .private:
                return "プライベート"
            }
        }
    }
    
    // コミュニケーションタイプ
    enum CommunicationType: String, CaseIterable, Identifiable {
        case call = "Call"
        case email = "Email"
        case meeting = "Meeting"
        case message = "Message"
        
        var id: String { self.rawValue }
        
        var displayName: String {
            switch self {
            case .call:
                return "通話"
            case .email:
                return "メール"
            case .meeting:
                return "会議"
            case .message:
                return "メッセージ"
            }
        }
    }
    
    // 通知時間
    enum ReminderTime: Int, CaseIterable, Identifiable {
        case none = 0
        case fifteenMinutes = 15
        case thirtyMinutes = 30
        case oneHour = 60
        case twoHours = 120
        case oneDay = 1440
        case twoDays = 2880
        case oneWeek = 10080
        
        var id: Int { self.rawValue }
        
        var displayName: String {
            switch self {
            case .none:
                return "なし"
            case .fifteenMinutes:
                return "15分前"
            case .thirtyMinutes:
                return "30分前"
            case .oneHour:
                return "1時間前"
            case .twoHours:
                return "2時間前"
            case .oneDay:
                return "1日前"
            case .twoDays:
                return "2日前"
            case .oneWeek:
                return "1週間前"
            }
        }
    }
}
