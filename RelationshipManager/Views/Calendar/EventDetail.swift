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
                eventHeaderSection
                
                // 詳細情報
                detailsSection
                
                // 参加者
                participantsSection
                
                // グループ情報（グループがある場合）
                if let group = event.group {
                    groupInfoSection(group: group)
                }
                
                // アクションボタン
                actionButtonsSection
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
            deleteConfirmationAlert
        }
    }
    
    // イベントヘッダーセクション
    private var eventHeaderSection: some View {
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
                reminderInfoView
            }
        }
        .padding(.bottom)
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // リマインダー情報
    private var reminderInfoView: some View {
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
    
    // 詳細情報セクション
    private var detailsSection: some View {
        Group {
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
        }
    }
    
    // 参加者セクション
    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("参加者")
                .font(AppFonts.title3)
            
            if event.contactsArray.isEmpty {
                Text("参加者はいません")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.vertical)
            } else {
                participantsList
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // 参加者リスト
    private var participantsList: some View {
        ForEach(event.contactsArray) { contact in
            NavigationLink(destination: ContactDetailView(contact: contact)) {
                participantRow(contact: contact)
            }
            .padding(.vertical, 4)
            
            if contact.id != event.contactsArray.last?.id {
                Divider()
            }
        }
    }
    
    // 参加者の行
    private func participantRow(contact: ContactEntity) -> some View {
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
            
            CategoryBadgeView(category: contact.category ?? "")
        }
    }
    
    // グループ情報セクション
    private func groupInfoSection(group: GroupEntity) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("グループ")
                .font(AppFonts.title3)
            
            NavigationLink(destination: GroupDetailView(group: group)) {
                groupRow(group: group)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // グループの行
    private func groupRow(group: GroupEntity) -> some View {
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
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            CategoryBadgeView(category: group.category ?? "")
        }
    }
    
    // アクションボタンセクション
    private var actionButtonsSection: some View {
        HStack(spacing: 20) {
            // カレンダーに追加ボタン (イベントが未来の場合のみ表示)
            calendarAddButton
            
            // 編集ボタン
            Button(action: {
                showingEditSheet = true
            }) {
                actionButtonContent(
                    imageName: "pencil",
                    color: AppColors.accent,
                    text: "編集"
                )
            }
            .frame(maxWidth: .infinity)
            
            // 削除ボタン
            Button(action: {
                showingDeleteAlert = true
            }) {
                actionButtonContent(
                    imageName: "trash",
                    color: AppColors.error,
                    text: "削除"
                )
            }
            .frame(maxWidth: .infinity)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    // カレンダーに追加ボタン
    private var calendarAddButton: some View {
        Group {
            if let startDate = event.startDate,
               let calendar = Calendar.current.date(byAdding: .minute, value: -10, to: startDate),
               calendar > Date() {
                Button(action: {
                    addToCalendar()
                }) {
                    actionButtonContent(
                        imageName: "calendar.badge.plus",
                        color: AppColors.primary,
                        text: "カレンダーに追加"
                    )
                }
                .frame(maxWidth: .infinity)
            } else {
                Spacer()
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    // アクションボタンの共通コンテンツ
    private func actionButtonContent(imageName: String, color: Color, text: String) -> some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(text)
                .font(AppFonts.caption1)
        }
    }
    
    // 削除確認アラート
    private var deleteConfirmationAlert: Alert {
        Alert(
            title: Text("予定を削除"),
            message: Text("この予定を削除してもよろしいですか？"),
            primaryButton: .destructive(Text("削除")) {
                deleteEvent()
            },
            secondaryButton: .cancel(Text("キャンセル"))
        )
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

// イベント編集画面も同様に分割
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
        
        _title = State(initialValue: event.title ?? "")
        _details = State(initialValue: event.details ?? "")
        
        // startDateがnilの場合は現在時刻を使用
        let defaultDate = Date()
        _startDate = State(initialValue: event.startDate ?? defaultDate)
        
        // endDateがnilの場合はstartDateの1時間後を使用
        let endDateValue: Date
        if let eventEndDate = event.endDate {
            endDateValue = eventEndDate
        } else if let eventStartDate = event.startDate {
            endDateValue = eventStartDate.addingTimeInterval(3600)
        } else {
            endDateValue = defaultDate.addingTimeInterval(3600)
        }
        _endDate = State(initialValue: endDateValue)
        
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location ?? "")
        _reminder = State(initialValue: event.reminder)
        
        // reminderDateがnilの場合はstartDateの30分前を使用
        let reminderDateValue: Date
        if let eventReminderDate = event.reminderDate {
            reminderDateValue = eventReminderDate
        } else if let eventStartDate = event.startDate {
            reminderDateValue = eventStartDate.addingTimeInterval(-1800)
        } else {
            reminderDateValue = defaultDate.addingTimeInterval(-1800)
        }
        _reminderDate = State(initialValue: reminderDateValue)
        
        // 既存の参加者を取得
        if let contacts = event.contacts as? Set<ContactEntity> {
            _selectedContactIds = State(initialValue: Set(contacts.compactMap { $0.id }))
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                basicInfoSection
                dateTimeSection
                locationSection
                reminderSection
                participantsSection
                
                // グループ情報（グループがある場合）
                if let group = event.group {
                    groupSection(group: group)
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
            
            selectedParticipantsList
        }
    }
    
    // 選択された参加者リスト
    private var selectedParticipantsList: some View {
        ForEach(contactViewModel.contacts.filter { contact in
            guard let id = contact.id else { return false }
            return selectedContactIds.contains(id)
        }) { contact in
            participantRow(contact: contact)
        }
    }
    
    // 参加者の行
    private func participantRow(contact: ContactEntity) -> some View {
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
    
    // グループセクション
    private func groupSection(group: GroupEntity) -> some View {
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
