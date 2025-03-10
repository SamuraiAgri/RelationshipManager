import SwiftUI

struct EventDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var eventViewModel: EventViewModel
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    var event: EventEntity
    
    init(event: EventEntity) {
        self.event = event
        _eventViewModel = StateObject(wrappedValue: EventViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // イベントヘッダー
                VStack(spacing: 10) {
                    Text(event.title ?? "無題")
                        .font(AppFonts.title2)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(event.formattedStartDate)
                            .font(AppFonts.headline)
                    }
                    
                    HStack {
                        Image(systemName: "clock")
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(event.formattedStartTime)
                            .font(AppFonts.body)
                        
                        if !event.isAllDay {
                            Text("(\(event.durationString))")
                                .font(AppFonts.bodySmall)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if let location = event.location, !location.isEmpty {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(AppColors.textTertiary)
                            
                            Text(location)
                                .font(AppFonts.body)
                        }
                    }
                    
                    if event.reminder {
                        HStack {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppColors.accent)
                            
                            if let reminderDate = event.reminderDate {
                                Text("通知: \(reminderDate.formattedDateTime())")
                                    .font(AppFonts.body)
                            } else {
                                Text("通知: あり")
                                    .font(AppFonts.body)
                            }
                        }
                    }
                }
                .padding(.bottom)
                .frame(maxWidth: .infinity)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 詳細情報
                if let details = event.details, !details.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("詳細")
                            .font(AppFonts.title3)
                        
                        Text(details)
                            .font(AppFonts.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // 参加者
                VStack(alignment: .leading, spacing: 10) {
                    Text("参加者")
                        .font(AppFonts.title3)
                    
                    if event.contactsArray.isEmpty {
                        Text("参加者はいません")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.vertical)
                    } else {
                        ForEach(event.contactsArray) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
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
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    Spacer()
                                    
                                    CategoryBadgeView(category: contact.category)
                                }
                            }
                            
                            if contact.id != event.contactsArray.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // グループ情報（グループがある場合）
                if let group = event.group {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("グループ")
                            .font(AppFonts.title3)
                        
                        NavigationLink(destination: GroupDetailView(group: group)) {
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
                                    .foregroundColor(AppColors.textPrimary)
                                
                                Spacer()
                                
                                CategoryBadgeView(category: group.category)
                            }
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                }
                
                // アクションボタン
                HStack(spacing: 20) {
                    if let startDate = event.startDate,
                       let calendar = Calendar.current.date(byAdding: .minute, value: -10, to: startDate),
                       calendar > Date() {
                        Button(action: {
                            addToCalendar()
                        }) {
                            VStack {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.primary)
                                
                                Text("カレンダーに追加")
                                    .font(AppFonts.caption1)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        VStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.accent)
                            
                            Text("編集")
                                .font(AppFonts.caption1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        VStack {
                            Image(systemName: "trash")
                                .font(.system(size: 24))
                                .foregroundColor(AppColors.error)
                            
                            Text("削除")
                                .font(AppFonts.caption1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("予定詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditEventView(event: event)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("予定を削除"),
                message: Text("この予定を削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    deleteEvent()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
    }
    
    // イベントを削除
    private func deleteEvent() {
        eventViewModel.deleteEvent(event)
        presentationMode.wrappedValue.dismiss()
    }
    
    // カレンダーに追加
    private func addToCalendar() {
        CalendarManager.shared.addEventToCalendar(event: event) { success, error in
            if success {
                // 成功時の処理（必要に応じて通知など）
                print("カレンダーにイベントを追加しました")
            } else if let error = error {
                // エラー処理
                print("カレンダーへの追加エラー: \(error)")
            }
        }
    }
}

// イベント編集画面
struct EditEventView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var eventViewModel = EventViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var contactViewModel = ContactViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var title: String
    @State private var details: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var location: String
    @State private var reminder: Bool
    @State private var reminderDate: Date
    @State private var selectedContactIds: Set<UUID> = []
    @State private var showingContactPicker = false
    
    var event: EventEntity
    
    init(event: EventEntity) {
        self.event = event
        
        _title = State(initialValue: event.title)
        _details = State(initialValue: event.details ?? "")
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate ?? event.startDate.addingTimeInterval(3600))
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location ?? "")
        _reminder = State(initialValue: event.reminder)
        _reminderDate = State(initialValue: event.reminderDate ?? event.startDate.addingTimeInterval(-1800))
        
        // 既存の参加者を取得
        if let contacts = event.contacts as? Set<ContactEntity> {
            _selectedContactIds = State(initialValue: Set(contacts.compactMap { $0.id }))
        }
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
                
                // グループ情報（グループがある場合）
                if let group = event.group {
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
            .navigationTitle("予定を編集")
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
        
        eventViewModel.updateEvent(
            event,
            title: title,
            details: details.isEmpty ? nil : details,
            startDate: startDate,
            endDate: isAllDay ? startDate : endDate,
            isAllDay: isAllDay,
            location: location.isEmpty ? nil : location,
            reminder: reminder,
            reminderDate: reminder ? reminderDate : nil,
            contacts: selectedContacts,
            group: event.group
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    NavigationView {
        let previewContext = PersistenceController.preview.container.viewContext
        let event = previewContext.registeredObjects.first { $0 is EventEntity } as! EventEntity
        
        return EventDetailView(event: event)
    }
}
