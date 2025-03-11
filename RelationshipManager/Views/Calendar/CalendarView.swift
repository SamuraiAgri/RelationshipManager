import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: EventViewModel
    
    @State private var selectedDate = Date()
    @State private var showingAddSheet = false
    @State private var selectedDateForAddEvent: Date?
    
    // 現在の表示月
    @State private var currentMonth = Date()
    
    // スワイプジェスチャーの状態を追跡
    @GestureState private var dragOffset: CGFloat = 0
    
    init() {
        _viewModel = StateObject(wrappedValue: EventViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カレンダーヘッダー
                HStack {
                    Button(action: {
                        navigateToPreviousMonth()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Spacer()
                    
                    Text(formatHeaderDate())
                        .font(AppFonts.title3)
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToNextMonth()
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // 曜日のヘッダー
                HStack(spacing: 0) {
                    ForEach(getDaysOfWeek(), id: \.self) { day in
                        Text(day)
                            .font(AppFonts.caption1)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.bottom, 8)
                
                // カレンダーグリッド - スワイプジェスチャーを追加
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                    ForEach(extractDates()) { dateItem in
                        VStack {
                            if dateItem.date != nil {
                                DayView(
                                    date: dateItem.date!,
                                    isSelected: Calendar.current.isDate(dateItem.date!, inSameDayAs: selectedDate),
                                    isToday: Calendar.current.isDateInToday(dateItem.date!),
                                    isCurrentMonth: dateItem.isCurrentMonth,
                                    events: viewModel.getEventsForDay(date: dateItem.date!),
                                    birthdays: viewModel.getBirthdaysForDay(date: dateItem.date!)
                                )
                                .onTapGesture {
                                    selectedDate = dateItem.date!
                                    viewModel.setSelectedDate(dateItem.date!)
                                }
                                .contextMenu {
                                    Button(action: {
                                        selectedDateForAddEvent = dateItem.date!
                                        showingAddSheet = true
                                    }) {
                                        Label("予定を追加", systemImage: "calendar.badge.plus")
                                    }
                                }
                            } else {
                                // 空のセル（月の前後の余白）
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 40)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation.width
                        }
                        .onEnded { value in
                            // ドラッグ量が十分な場合のみ月を切り替え
                            let threshold: CGFloat = 50
                            if value.translation.width > threshold {
                                navigateToPreviousMonth()
                            } else if value.translation.width < -threshold {
                                navigateToNextMonth()
                            }
                        }
                )
                
                Divider()
                    .padding(.vertical, 10)
                
                // 選択日のイベント一覧
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(formatSelectedDate())
                            .font(AppFonts.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            // 選択されている日付で予定追加
                            selectedDateForAddEvent = selectedDate
                            showingAddSheet = true
                        }) {
                            Label("予定追加", systemImage: "plus.circle")
                                .font(AppFonts.subheadline)
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 誕生日を表示
                    let birthdays = viewModel.getBirthdaysForDay(date: selectedDate)
                    if !birthdays.isEmpty {
                        ForEach(birthdays) { birthday in
                            BirthdayRowView(birthday: birthday)
                        }
                        .padding(.horizontal)
                    }
                    
                    // イベントを表示
                    if viewModel.filteredEvents.isEmpty && birthdays.isEmpty {
                        VStack {
                            Spacer()
                            Text("予定はありません")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .padding()
                            Spacer()
                        }
                        .frame(height: 200)
                    } else if !viewModel.filteredEvents.isEmpty {
                        List {
                            ForEach(viewModel.filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRowView(event: event)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 300)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("カレンダー")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddSheet = true
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(AppColors.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        selectedDate = Date()
                        currentMonth = Date()
                        viewModel.setSelectedDate(Date())
                    }) {
                        Text("今日")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEventView(initialDate: selectedDateForAddEvent ?? selectedDate)
                    .environment(\.managedObjectContext, viewContext)
                    .onDisappear {
                        // リセットして次回は現在選択されている日付を使用
                        selectedDateForAddEvent = nil
                    }
            }
            .onAppear {
                viewModel.fetchEvents()
                viewModel.fetchBirthdayEvents()
                viewModel.setSelectedDate(selectedDate)
            }
        }
    }
    
    // メソッド部分（既存のメソッドはそのまま）
    
    // ヘッダー日付のフォーマット
    private func formatHeaderDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: currentMonth)
    }
    
    // 選択日のフォーマット
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // 曜日の配列を取得
    private func getDaysOfWeek() -> [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.shortWeekdaySymbols // ["日", "月", "火", "水", "木", "金", "土"]
    }
    
    // 前の月に移動
    private func navigateToPreviousMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    // 次の月に移動
    private func navigateToNextMonth() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newDate
        }
    }
    
    // カレンダーに表示する日付を抽出
    private func extractDates() -> [DateItem] {
        let calendar = Calendar.current
        
        // 現在の月の最初の日を取得
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        
        // 前月の日数を取得（現在の月の最初の日の曜日に基づく）
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let daysInPreviousMonth = (firstWeekday + 6) % 7 // 日本の週は日曜始まり（1）なので調整
        
        // 現在の月の日数を取得
        let daysInMonth = calendar.range(of: .day, in: .month, for: currentMonth)!.count
        
        // 次月の日数を取得（6週間表示するために必要な日数）
        let remainingDays = 42 - (daysInPreviousMonth + daysInMonth) // 6週 × 7日 = 42
        
        var dateItems: [DateItem] = []
        
        // 前月の日付を追加
        if daysInPreviousMonth > 0 {
            let previousMonth = calendar.date(byAdding: .month, value: -1, to: firstDay)!
            let daysInPrevious = calendar.range(of: .day, in: .month, for: previousMonth)!.count
            
            for day in (daysInPrevious - daysInPreviousMonth + 1)...daysInPrevious {
                let date = calendar.date(byAdding: .day, value: day - daysInPrevious, to: firstDay)!
                dateItems.append(DateItem(id: UUID(), date: date, isCurrentMonth: false))
            }
        }
        
        // 現在の月の日付を追加
        for day in 1...daysInMonth {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            dateItems.append(DateItem(id: UUID(), date: date, isCurrentMonth: true))
        }
        
        // 次月の日付を追加
        if remainingDays > 0 {
            let nextMonth = calendar.date(byAdding: .month, value: 1, to: firstDay)!
            
            for day in 1...remainingDays {
                let date = calendar.date(byAdding: .day, value: day - 1, to: nextMonth)!
                dateItems.append(DateItem(id: UUID(), date: date, isCurrentMonth: false))
            }
        }
        
        return dateItems
    }
}

// カレンダーの日付アイテム
struct DateItem: Identifiable {
    let id: UUID
    let date: Date?
    let isCurrentMonth: Bool
}

// 日付表示用ビュー
struct DayView: View {
    var date: Date
    var isSelected: Bool
    var isToday: Bool
    var isCurrentMonth: Bool
    var events: [EventEntity]
    var birthdays: [BirthdayEvent]
    
    private let dayWidth: CGFloat = 40
    
    var body: some View {
        VStack(spacing: 4) {
            // 日付
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 30, height: 30)
                
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(AppFonts.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(textColor)
            }
            
            // イベントインジケーター
            HStack(spacing: 2) {
                // 通常イベント
                ForEach(0..<min(events.count, 2), id: \.self) { index in
                    Circle()
                        .fill(eventIndicatorColor(for: index))
                        .frame(width: 4, height: 4)
                }
                
                // 誕生日イベント
                if !birthdays.isEmpty {
                    Circle()
                        .fill(Color.pink)
                        .frame(width: 4, height: 4)
                }
            }
        }
        .frame(width: dayWidth, height: 40)
        // 選択時にわかりやすく
        .background(
            isSelected ?
                RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.primary.opacity(0.1))
                .frame(width: 36, height: 36) : nil
        )
        // 誕生日がある日は特別な装飾
        .overlay(
            Group {
                if !birthdays.isEmpty && isCurrentMonth {
                    Circle()
                        .stroke(Color.pink, lineWidth: 1)
                        .frame(width: 32, height: 32)
                }
            }
        )
    }
    
    // イベントインジケーターの色を変える（複数ある場合に色分け）
    private func eventIndicatorColor(for index: Int) -> Color {
        if events.count > 1 {
            return [AppColors.primary, AppColors.accent, AppColors.meetingType][index % 3]
        }
        return AppColors.primary
    }
    
    // 背景色の計算
    private var backgroundColor: Color {
        if isSelected {
            return AppColors.primary
        } else if isToday {
            return AppColors.primary.opacity(0.2)
        }
        return Color.clear
    }
    
    // テキスト色の計算
    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return AppColors.textTertiary
        } else if isToday {
            return AppColors.primary
        }
        return AppColors.textPrimary
    }
}

// 誕生日表示用ビュー
struct BirthdayRowView: View {
    var birthday: BirthdayEvent
    
    var body: some View {
        HStack {
            // アバターまたはイニシャル
            AvatarView(
                imageData: birthday.contact.profileImageData,
                initials: birthday.contact.initials,
                size: 40,
                backgroundColor: birthday.contact.category == AppConstants.Category.business.rawValue ?
                    AppColors.businessCategory : AppColors.privateCategory
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(birthday.title)")
                    .font(AppFonts.headline)
                
                Text("\(birthday.details)")
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "gift.fill")
                .foregroundColor(.pink)
                .font(.system(size: 20))
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.pink.opacity(0.1))
        )
        .padding(.bottom, 5)
    }
}

#Preview {
    CalendarView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
