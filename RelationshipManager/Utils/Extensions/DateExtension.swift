
// DateExtension.swift
import Foundation

extension Date {
    // 今日かどうかを判定
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    // 明日かどうかを判定
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    // 昨日かどうかを判定
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    
    // 今週かどうかを判定
    var isThisWeek: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekStartDate = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weekEndDate = calendar.date(byAdding: .day, value: 7, to: weekStartDate)!
        
        return self >= weekStartDate && self < weekEndDate
    }
    
    // 日付のフォーマット
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: self)
    }
    
    // 時刻のフォーマット
    func formattedTime(style: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = style
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: self)
    }
    
    // 日付と時刻のフォーマット
    func formattedDateTime(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: self)
    }
    
    // 相対的な表現（例：「2時間前」「昨日」など）
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    // 誕生日から年齢を計算
    func age() -> Int? {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year
    }
}

// StringExtension.swift
import Foundation
import UIKit

extension String {
    // 文字列が有効なメールアドレスかどうかをチェック
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    // 文字列が有効な電話番号かどうかをチェック（日本の形式）
    var isValidPhoneNumber: Bool {
        let phoneRegEx = "^(0[5-9]0[0-9]{8}|0[1-9][1-9][0-9]{7})$"
        let phonePred = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phonePred.evaluate(with: self.replacingOccurrences(of: "-", with: ""))
    }
    
    // 名前の頭文字を取得
    var initials: String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.map { String($0.first!) }.joined()
    }
    
    // 文字列の最初の文字を大文字にする
    var capitalized: String {
        return self.prefix(1).uppercased() + self.dropFirst()
    }
    
    // 指定された長さの文字列に切り詰め、必要に応じて末尾に「...」を追加
    func truncated(toLength length: Int, trailing: String = "...") -> String {
        if self.count > length {
            return String(self.prefix(length)) + trailing
        } else {
            return self
        }
    }
}

// ColorExtension.swift
import SwiftUI

extension Color {
    // 16進数形式からカラーを作成
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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // カラーをUIColorに変換
    func toUIColor() -> UIColor {
        return UIColor(self)
    }
}
