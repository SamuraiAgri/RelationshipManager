import SwiftUI

// 月表示のカレンダービュー
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 8) {
            // 曜日ヘッダー
            ForEach(getDaysOfWeek(), id: \.self) { day in
                Text(day)
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            // 日付グリッド
            ForEach(getDaysInMonth(), id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month),
                        hasEvents: hasEvents(on: date),
                        onTap: {
                            selectedDate = date
                            onDateSelected(date)
                        }
                    )
                } else {
                    // 空白セル
                    Rectangle()
                        .fill(Color.clear)
                        .frame(height: 40)
                }
            }
        }
        .padding(.horizontal)
    }
    
    // 曜日の取得
    private func getDaysOfWeek() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.shortWeekdaySymbols
    }
    
    // 月の日付を取得
    private func getDaysInMonth() -> [Date?] {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let offsetDays = (firstWeekday - calendar.firstWeekday + 7) % 7
        
        var days = [Date?](repeating: nil, count: offsetDays)
        
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // 6週間分のセルを用意する (最大42マス)
        let remainingCells = 42 - days.count
        if remainingCells > 0 {
            days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        }
        
        return days
    }
    
    // 日付にイベントがあるかをチェック
    private func hasEvents(on date: Date) -> Bool {
        return events.contains { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }
}

// 週表示のカレンダービュー
struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let gridColumns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // 曜日と日付ヘッダー
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(getDaysOfWeek(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(formatWeekday(date: date))
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text(formatDay(date: date))
                            .font(AppFonts.headline)
                            .foregroundColor(calendar.isDateInToday(date) ? AppColors.primary : AppColors.textPrimary)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(calendar.isDate(date, inSameDayAs: selectedDate) ?
                                          (calendar.isDateInToday(date) ? AppColors.primary.opacity(0.2) : Color.gray.opacity(0.2)) :
                                          Color.clear)
                            )
                    }
                    .onTapGesture {
                        selectedDate = date
                        onDateSelected(date)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            // イベントリスト
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(getEventsForWeek(), id: \.id) { event in
                        EventListItem(event: event)
                            .padding(.vertical, 4)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    // 週の日付を取得
    private func getDaysOfWeek() -> [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        
        var days: [Date] = []
        for day in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: day, to: startOfWeek) {
                days.append(date)
            }
        }
        
        return days
    }
    
    // 曜日のフォーマット
    private func formatWeekday(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 日付のフォーマット
    private func formatDay(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // 週のイベントを取得
    private func getEventsForWeek() -> [EventEntity] {
        let weekDays = getDaysOfWeek()
        guard let firstDay = weekDays.first, let lastDay = weekDays.last else {
            return []
        }
        
        let startOfFirstDay = calendar.startOfDay(for: firstDay)
        let endOfLastDay = calendar.date(byAdding: .day, value: 1, to: lastDay)!
        
        return events.filter { event in
            let eventDate = event.startDate
            return eventDate >= startOfFirstDay && eventDate < endOfLastDay
        }
        .sorted { $0.startDate < $1.startDate }
    }
}

// 日表示のカレンダービュー
struct DayCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    private let timeSlots = 24 // 24時間表示
    
    var body: some View {
        VStack(spacing: 0) {
            // 日付ヘッダー
            HStack {
                Button(action: {
                    if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
                        selectedDate = newDate
                        onDateSelected(newDate)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.primary)
                }
                
                Spacer()
                
                VStack {
                    Text(formatDate(date: selectedDate))
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(formatWeekday(date: selectedDate))
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
                        selectedDate = newDate
                        onDateSelected(newDate)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding()
            
            Divider()
            
            // 時間スロットとイベント
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<timeSlots, id: \.self) { hour in
                        HStack(alignment: .top) {
                            // 時間表示
                            Text("\(hour):00")
                                .font(AppFonts.caption1)
                                .foregroundColor(AppColors.textSecondary)
                                .frame(width: 50, alignment: .center)
                            
                            // 時間区切り線
                            Divider()
                            
                            // その時間帯のイベント
                            VStack(alignment: .leading, spacing: 2) {
                                ForEach(getEventsForHour(hour), id: \.id) { event in
                                    EventTimeSlot(event: event)
                                        .padding(.vertical, 2)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                            .padding(.leading, 50)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    // 日付のフォーマット
    private func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 曜日のフォーマット
    private func formatWeekday(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    // 指定時間のイベントを取得
    private func getEventsForHour(_ hour: Int) -> [EventEntity] {
        return events.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            return eventHour == hour
        }
    }
    
    // イベントのリスト表示に使用する値を取得
    func getEventsForDay(date: Date) -> [EventEntity] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return events.filter { event in
            let eventDate = event.startDate
            return eventDate >= startOfDay && eventDate < endOfDay
        }
        .sorted { $0.startDate < $1.startDate }
    }
}

// 日付セル
struct DayCell: View {
    var date: Date
    var isSelected: Bool
    var isCurrentMonth: Bool
    var hasEvents: Bool
    var onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack {
            Text("\(calendar.component(.day, from: date))")
                .font(isSelected ? AppFonts.headline : AppFonts.body)
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isSelected ?
                              (calendar.isDateInToday(date) ? AppColors.primary.opacity(0.2) : Color.gray.opacity(0.2)) :
                              Color.clear)
                )
                .overlay(
                    Circle()
                        .stroke(calendar.isDateInToday(date) ? AppColors.primary : Color.clear, lineWidth: 1)
                )
            
            if hasEvents {
                Circle()
                    .fill(isCurrentMonth ? AppColors.primary : AppColors.textTertiary)
                    .frame(width: 6, height: 6)
            } else {
                Spacer()
                    .frame(height: 6)
            }
        }
        .frame(height: 50)
        .onTapGesture(perform: onTap)
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return AppColors.textTertiary
        } else if calendar.isDateInToday(date) {
            return AppColors.primary
        } else {
            return AppColors.textPrimary
        }
    }
}

// イベントのリスト表示用コンポーネント
struct EventListItem: View {
    var event: EventEntity
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(event.isToday ? AppColors.primary : AppColors.textTertiary)
                .frame(width: 4)
                .cornerRadius(2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Image(systemName: "clock")
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textTertiary)
                    
                    Text(formatTime(date: event.startDate, isAllDay: event.isAllDay))
                        .font(AppFonts.caption1)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    // 時刻のフォーマット
    private func formatTime(date: Date, isAllDay: Bool) -> String {
        if isAllDay {
            return "終日"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
    }
}

// 時間スロットの表示用コンポーネント
struct EventTimeSlot: View {
    var event: EventEntity
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(AppFonts.subheadline)
                    .foregroundColor(.white)
                
                if let details = event.details, !details.isEmpty {
                    Text(details)
                        .font(AppFonts.caption1)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(formatTime(date: event.startDate))
                .font(AppFonts.caption1)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding(8)
        .background(AppColors.primary)
        .cornerRadius(8)
    }
    
    // 時刻のフォーマット
    private func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
