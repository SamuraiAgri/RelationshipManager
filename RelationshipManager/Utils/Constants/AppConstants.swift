
import Foundation

struct AppConstants {
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
