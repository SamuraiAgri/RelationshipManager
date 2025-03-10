import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: EventViewModel
    
    @State private var selectedDate = Date()
    @State private var calendarMode: CalendarMode = .month
    @State private var showingAddSheet = false
    
    // 表示モード
    enum CalendarMode {
        case month, week, day
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: EventViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // カレンダーモード切り替え
                Picker("表示モード", selection: $calendarMode) {
                    Text("月").tag(CalendarMode.month)
                    Text("週").tag(CalendarMode.week)
                    Text("日").tag(CalendarMode.day)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // カレンダーヘッダー
                HStack {
                    Button(action: {
                        navigateToPreviousPeriod()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Spacer()
                    
                    Text(formatHeaderDate())
                        .font(AppFonts.title3)
                    
                    Spacer()
                    
                    Button(action: {
                        navigateToNextPeriod()
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(AppColors.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                
                // カレンダー表示（仮実装）
                Text("カレンダーコンテンツ（開発中）")
                    .font(AppFonts.headline)
                    .padding(.vertical, 50)
                
                Divider()
                
                // 選択日のイベント一覧
                VStack(alignment: .leading, spacing: 10) {
                    Text(formatSelectedDate())
                        .font(AppFonts.headline)
                        .padding(.horizontal)
                        .padding(.top, 10)
                    
                    if viewModel.filteredEvents.isEmpty {
                        VStack {
                            Spacer()
                            Text("予定はありません")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textSecondary)
                                .padding()
                            Spacer()
                        }
                        .frame(maxHeight: 200)
                    } else {
                        List {
                            ForEach(viewModel.filteredEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                                    EventRowView(event: event)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 300)
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
                        viewModel.setSelectedDate(Date())
                    }) {
                        Text("今日")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEventView(initialDate: selectedDate)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                viewModel.fetchEvents()
                viewModel.setSelectedDate(selectedDate)
            }
        }
    }
    
    // ヘッダー日付のフォーマット
    private func formatHeaderDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        
        switch calendarMode {
        case .month:
            formatter.dateFormat = "yyyy年M月"
        case .week:
            formatter.dateFormat = "yyyy年M月第W週"
        case .day:
            formatter.dateFormat = "yyyy年M月d日(E)"
        }
        
        return formatter.string(from: selectedDate)
    }
    
    // 選択日のフォーマット
    private func formatSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日(E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: selectedDate)
    }
    
    // 前の期間に移動
    private func navigateToPreviousPeriod() {
        let calendar = Calendar.current
        
        switch calendarMode {
        case .month:
            if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        case .week:
            if let newDate = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        case .day:
            if let newDate = calendar.date(byAdding: .day, value: -1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        }
    }
    
    // 次の期間に移動
    private func navigateToNextPeriod() {
        let calendar = Calendar.current
        
        switch calendarMode {
        case .month:
            if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        case .week:
            if let newDate = calendar.date(byAdding: .weekOfYear, value: 1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        case .day:
            if let newDate = calendar.date(byAdding: .day, value: 1, to: selectedDate) {
                selectedDate = newDate
                viewModel.setSelectedDate(newDate)
            }
        }
    }
}

// カレンダー月ビュー（仮）
struct MonthCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        Text("月カレンダー（開発中）")
            .padding()
    }
}

// カレンダー週ビュー（仮）
struct WeekCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        Text("週カレンダー（開発中）")
            .padding()
    }
}

// カレンダー日ビュー（仮）
struct DayCalendarView: View {
    @Binding var selectedDate: Date
    var events: [EventEntity]
    var onDateSelected: (Date) -> Void
    
    var body: some View {
        Text("日カレンダー（開発中）")
            .padding()
    }
}
