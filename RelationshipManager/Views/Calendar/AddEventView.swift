import SwiftUI

struct AddEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var eventViewModel = EventViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var contactViewModel = ContactViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var title = ""
    @State private var details = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay = false
    @State private var location = ""
    @State private var reminder = false
    @State private var reminderDate: Date
    @State private var selectedContactIds: Set<UUID> = []
    @State private var showingContactPicker = false
    
    // グループが指定された場合に使用
    var group: GroupEntity?
    
    init(initialDate: Date = Date(), group: GroupEntity? = nil) {
        self.group = group
        
        // 初期日時の設定を簡素化
        let calendar = Calendar.current
        
        // 初期日を取得し、確実に非オプショナル値にする
        let date = initialDate
        
        // 現在の時刻を30分単位に切り上げる
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let minute = components.minute ?? 0
        
        // 新しい日付コンポーネントを作成
        var newComponents = components
        
        // 30分単位に切り上げる処理
        if minute < 30 {
            newComponents.minute = 30
        } else {
            newComponents.minute = 0
            newComponents.hour = (components.hour ?? 0) + 1
        }
        
        // 新しい日時を作成（見つからない場合は元の日時を使用）
        let newDate = calendar.date(from: newComponents) ?? date
        
        // 各Stateプロパティを初期化
        _startDate = State(initialValue: newDate)
        
        // 終了時間は開始時間の1時間後
        let oneHourLater = calendar.date(byAdding: .hour, value: 1, to: newDate) ?? newDate
        _endDate = State(initialValue: oneHourLater)
        
        // リマインダー時間は開始時間の30分前
        let thirtyMinutesBefore = calendar.date(byAdding: .minute, value: -30, to: newDate) ?? newDate
        _reminderDate = State(initialValue: thirtyMinutesBefore)
    }
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                dateTimeSection
                locationSection
                reminderSection
                participantsSection
                
                if let group = group {
                    groupInfoSection(group: group)
                }
            }
            .navigationTitle("予定の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarItems
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView(selectedContactIds: $selectedContactIds)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                contactViewModel.fetchContacts()
            }
        }
    }
    
    // 基本情報セクション
    private var basicInfoSection: some View {
        Section(header: Text("基本情報")) {
            TextField("タイトル", text: $title)
            
            ZStack(alignment: .topLeading) {
                if details.isEmpty {
                    Text("詳細")
                        .foregroundColor(AppColors.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }
                
                TextEditor(text: $details)
                    .frame(minHeight: 80)
            }
        }
    }
    
    // 日時設定セクション
    private var dateTimeSection: some View {
        Section(header: Text("日時")) {
            Toggle("終日", isOn: $isAllDay)
            
            if isAllDay {
                DatePicker("日付", selection: $startDate, displayedComponents: .date)
            } else {
                DatePicker("開始", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("終了", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    // 場所セクション
    private var locationSection: some View {
        Section(header: Text("場所")) {
            TextField("場所", text: $location)
        }
    }
    
    // リマインダーセクション
    private var reminderSection: some View {
        Section(header: Text("リマインダー")) {
            Toggle("リマインダー", isOn: $reminder)
            
            if reminder {
                DatePicker("通知時間", selection: $reminderDate, in: ...startDate, displayedComponents: [.date, .hourAndMinute])
            }
        }
    }
    
    // 参加者セクション
    private var participantsSection: some View {
        Section(header: Text("参加者")) {
            Button(action: {
                showingContactPicker = true
            }) {
                HStack {
                    Text(selectedContactIds.isEmpty ? "参加者を追加" : "\(selectedContactIds.count)人の参加者")
                        .foregroundColor(selectedContactIds.isEmpty ? AppColors.textTertiary : AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            if !selectedContactIds.isEmpty {
                // 選択された連絡先を表示
                ForEach(contactViewModel.contacts.filter { contact in
                    guard let id = contact.id else { return false }
                    return selectedContactIds.contains(id)
                }) { contact in
                    contactRow(for: contact)
                }
            }
        }
    }
    
    // 連絡先の行を表示するヘルパーメソッド
    private func contactRow(for contact: ContactEntity) -> some View {
        HStack {
            let category = contact.category ?? ""
            let backgroundColor = category == AppConstants.Category.business.rawValue ?
                AppColors.businessCategory : AppColors.privateCategory
            
            AvatarView(
                imageData: contact.profileImageData,
                initials: contact.initials,
                size: 40,
                backgroundColor: backgroundColor
            )
            
            Text(contact.fullName)
                .font(AppFonts.body)
        }
    }
    
    // グループ情報セクション
    private func groupInfoSection(group: GroupEntity) -> some View {
        Section(header: Text("グループ")) {
            HStack {
                ZStack {
                    Circle()
                        .fill(group.categoryColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                Text(group.name ?? "")
                    .font(AppFonts.body)
                
                Spacer()
                
                CategoryBadgeView(category: group.category ?? "")
            }
        }
    }
    
    // ツールバーアイテム
    private var toolbarItems: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveEvent()
                }
                .disabled(title.isEmpty)
            }
        }
    }
    
    // イベントを保存
    private func saveEvent() {
        // 選択された連絡先をフィルタリング
        let selectedContacts = contactViewModel.contacts.filter { contact in
            guard let id = contact.id else { return false }
            return selectedContactIds.contains(id)
        }
        
        // 新しいイベントを追加
        eventViewModel.addEvent(
            title: title,
            details: details.isEmpty ? nil : details,
            startDate: startDate,
            endDate: isAllDay ? startDate : endDate,
            isAllDay: isAllDay,
            location: location.isEmpty ? nil : location,
            reminder: reminder,
            reminderDate: reminder ? reminderDate : nil,
            contacts: selectedContacts,
            group: group
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// 連絡先選択ビュー - 複雑さを減らすために分割
struct ContactPickerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var contactViewModel = ContactViewModel(context: PersistenceController.shared.container.viewContext)
    @Binding var selectedContactIds: Set<UUID>
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
                // 検索バー
                searchBar
                
                // カテゴリフィルター
                CategoryFilterView(
                    selectedCategory: Binding(
                        get: { contactViewModel.selectedCategory },
                        set: { contactViewModel.setCategory($0) }
                    )
                )
                .padding(.vertical, 10)
                
                // 連絡先リスト
                contactList
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("参加者を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                navigationButtons
            }
            .onAppear {
                contactViewModel.fetchContacts()
            }
        }
    }
    
    // 検索バー
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(searchText.isEmpty ? AppColors.textTertiary : AppColors.primary)
            
            TextField("連絡先を検索", text: $searchText)
                .onChange(of: searchText) { _, newValue in
                    contactViewModel.setSearchText(newValue)
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    contactViewModel.setSearchText("")
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.textTertiary)
                }
            }
        }
        .padding(10)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
        .padding(.horizontal)
        .padding(.top)
    }
    
    // 連絡先リスト
    private var contactList: some View {
        List {
            ForEach(contactViewModel.filteredContacts) { contact in
                contactRow(for: contact)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // 連絡先行
    private func contactRow(for contact: ContactEntity) -> some View {
        HStack {
            ContactRowView(contact: contact)
            
            Spacer()
            
            Image(systemName: isSelected(contact) ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected(contact) ? AppColors.primary : AppColors.textTertiary)
                .font(.system(size: 22))
        }
        .contentShape(Rectangle())
        .onTapGesture {
            toggleSelection(contact)
        }
    }
    
    // ナビゲーションボタン
    private var navigationButtons: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完了") {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    // 連絡先が選択されているかをチェック
    private func isSelected(_ contact: ContactEntity) -> Bool {
        guard let id = contact.id else { return false }
        return selectedContactIds.contains(id)
    }
    
    // 連絡先の選択を切り替え
    private func toggleSelection(_ contact: ContactEntity) {
        guard let id = contact.id else { return }
        
        if selectedContactIds.contains(id) {
            selectedContactIds.remove(id)
        } else {
            selectedContactIds.insert(id)
        }
    }
}

#Preview {
    AddEventView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
