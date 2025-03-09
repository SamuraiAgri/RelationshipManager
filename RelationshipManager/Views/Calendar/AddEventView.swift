
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
        
        // 初期日時の設定（開始時間は次の30分単位に設定）
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: initialDate)
        
        // 30分単位に切り上げ
        var minute = components.minute ?? 0
        if minute < 30 {
            minute = 30
        } else {
            minute = 0
            // 時間を1時間進める
            var newComponents = components
            newComponents.hour = (components.hour ?? 0) + 1
            newComponents.minute = 0
            if let newDate = calendar.date(from: newComponents) {
                _startDate = State(initialValue: newDate)
                _endDate = State(initialValue: calendar.date(byAdding: .hour, value: 1, to: newDate) ?? newDate)
                _reminderDate = State(initialValue: calendar.date(byAdding: .minute, value: -30, to: newDate) ?? newDate)
                return
            }
        }
        
        var newComponents = components
        newComponents.minute = minute
        let newDate = calendar.date(from: newComponents) ?? initialDate
        
        _startDate = State(initialValue: newDate)
        _endDate = State(initialValue: calendar.date(byAdding: .hour, value: 1, to: newDate) ?? newDate)
        _reminderDate = State(initialValue: calendar.date(byAdding: .minute, value: -30, to: newDate) ?? newDate)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報
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
                
                // 日時設定
                Section(header: Text("日時")) {
                    Toggle("終日", isOn: $isAllDay)
                    
                    if isAllDay {
                        DatePicker("日付", selection: $startDate, displayedComponents: .date)
                    } else {
                        DatePicker("開始", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                        DatePicker("終了", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // 場所
                Section(header: Text("場所")) {
                    TextField("場所", text: $location)
                }
                
                // リマインダー
                Section(header: Text("リマインダー")) {
                    Toggle("リマインダー", isOn: $reminder)
                    
                    if reminder {
                        DatePicker("通知時間", selection: $reminderDate, in: ...startDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                // 参加者
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
                        ForEach(contactViewModel.contacts.filter { contact in
                            guard let id = contact.id else { return false }
                            return selectedContactIds.contains(id)
                        }) { contact in
                            HStack {
                                AvatarView(
                                    imageData: contact.profileImageData,
                                    initials: contact.initials,
                                    size: 40,
                                    backgroundColor: contact.category == AppConstants.Category.business.rawValue ?
                                        AppColors.businessCategory : AppColors.privateCategory
                                )
                                
                                Text(contact.fullName)
                                    .font(AppFonts.body)
                            }
                        }
                    }
                }
                
                // グループ情報（グループが指定されている場合のみ表示）
                if let group = group {
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
                            
                            Text(group.name)
                                .font(AppFonts.body)
                            
                            Spacer()
                            
                            CategoryBadgeView(category: group.category)
                        }
                    }
                }
            }
            .navigationTitle("予定の追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView(selectedContactIds: $selectedContactIds)
                    .environment(\.managedObjectContext, viewContext)
            }
            .onAppear {
                contactViewModel.fetchContacts()
            }
        }
    }
    
    // イベントを保存
    private func saveEvent() {
        let selectedContacts = contactViewModel.contacts.filter { contact in
            guard let id = contact.id else { return false }
            return selectedContactIds.contains(id)
        }
        
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

// 連絡先選択ビュー
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
                
                // カテゴリフィルター
                CategoryFilterView(
                    selectedCategory: Binding(
                        get: { contactViewModel.selectedCategory },
                        set: { contactViewModel.setCategory($0) }
                    )
                )
                .padding(.vertical, 10)
                
                // 連絡先リスト
                List {
                    ForEach(contactViewModel.filteredContacts) { contact in
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
                }
                .listStyle(PlainListStyle())
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("参加者を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            .onAppear {
                contactViewModel.fetchContacts()
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
