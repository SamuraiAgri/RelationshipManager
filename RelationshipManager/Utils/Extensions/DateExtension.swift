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
    
    // 日付のフォーマット(style指定)
    func formatted(style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        
        return formatter.string(from: self)
    }
    
    // 日付と時刻のフォーマット(両方のスタイル指定)
    func formatted(date: DateFormatter.Style, time: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = date
        formatter.timeStyle = time
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
    
    // 日付をMM-DD形式の文字列に変換するメソッド
    func toMMDD() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: self)
    }
    
    // 誕生日から年齢を計算
    func age() -> Int? {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year
    }
}
