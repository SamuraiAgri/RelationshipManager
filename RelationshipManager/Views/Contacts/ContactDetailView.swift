
import SwiftUI

struct ContactDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var contactViewModel: ContactViewModel
    @StateObject private var communicationViewModel: CommunicationViewModel
    @StateObject private var eventViewModel: EventViewModel
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingAddCommunicationSheet = false
    @State private var showingAddEventSheet = false
    @State private var selectedTab = 0
    
    var contact: ContactEntity
    
    init(contact: ContactEntity) {
        self.contact = contact
        
        _contactViewModel = StateObject(wrappedValue: ContactViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
        
        _communicationViewModel = StateObject(wrappedValue: CommunicationViewModel(
            context: PersistenceController.shared.container.viewContext,
            contact: contact
        ))
        
        _eventViewModel = StateObject(wrappedValue: EventViewModel(
            context: PersistenceController.shared.container.viewContext,
            contact: contact
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // プロフィールヘッダー
                VStack {
                    AvatarView(
                        imageData: contact.profileImageData,
                        initials: contact.initials,
                        size: 100,
                        backgroundColor: contact.category == AppConstants.Category.business.rawValue ?
                            AppColors.businessCategory : AppColors.privateCategory
                    )
                    .padding(.top)
                    
                    Text(contact.fullName)
                        .font(AppFonts.title2)
                        .padding(.top, 8)
                    
                    CategoryBadgeView(category: contact.category)
                        .padding(.top, 4)
                    
                    // 連絡先ボタン
                    HStack(spacing: 30) {
                        if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                            Button(action: {
                                callPhoneNumber(phoneNumber)
                            }) {
                                VStack {
                                    Image(systemName: "phone.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.callType)
                                    
                                    Text("通話")
                                        .font(AppFonts.caption1)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                        }
                        
                        if let email = contact.email, !email.isEmpty {
                            Button(action: {
                                sendEmail(email)
                            }) {
                                VStack {
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(AppColors.emailType)
                                    
                                    Text("メール")
                                        .font(AppFonts.caption1)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                            }
                        }
                        
                        Button(action: {
                            showingAddEventSheet = true
                        }) {
                            VStack {
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.meetingType)
                                
                                Text("予定")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        
                        Button(action: {
                            showingAddCommunicationSheet = true
                        }) {
                            VStack {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppColors.messageType)
                                
                                Text("記録")
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.bottom)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // 情報カード
                VStack(alignment: .leading, spacing: 16) {
                    Text("連絡先情報")
                        .font(AppFonts.title3)
                        .padding(.horizontal)
                    
                    if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                        InfoRow(icon: "phone", title: "電話番号", value: phoneNumber)
                    }
                    
                    if let email = contact.email, !email.isEmpty {
                        InfoRow(icon: "envelope", title: "メール", value: email)
                    }
                    
                    if let birthday = contact.birthday {
                        InfoRow(
                            icon: "gift",
                            title: "誕生日",
                            value: birthday.formatted(style: .medium),
                            detail: contact.age != nil ? "\(contact.age!)歳" : nil
                        )
                    }
                    
                    if let notes = contact.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(AppColors.textTertiary)
                                
                                Text("メモ")
                                    .font(AppFonts.headline)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            
                            Text(notes)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
                
                // タブビュー
                VStack {
                    Picker("表示", selection: $selectedTab) {
                        Text("コミュニケーション").tag(0)
                        Text("イベント").tag(1)
                        Text("グループ").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // コミュニケーション履歴
                    if selectedTab == 0 {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("コミュニケーション履歴")
                                    .font(AppFonts.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddCommunicationSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if communicationViewModel.communications.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("履歴がありません")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding()
                                    Spacer()
                                }
                            } else {
                                ForEach(communicationViewModel.communications.prefix(5)) { communication in
                                    CommunicationRowView(communication: communication)
                                    
                                    if communication.id != communicationViewModel.communications.prefix(5).last?.id {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                                
                                if communicationViewModel.communications.count > 5 {
                                    NavigationLink(destination: CommunicationListView(contact: contact)) {
                                        Text("すべて表示")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                }
                            }
                        }
                    }
                    
                    // イベント
                    else if selectedTab == 1 {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("予定")
                                    .font(AppFonts.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAddEventSheet = true
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                            
                            if eventViewModel.events.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("予定がありません")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding()
                                    Spacer()
                                }
                            } else {
                                ForEach(eventViewModel.upcomingEvents.prefix(3)) { event in
                                    NavigationLink(destination: EventDetailView(event: event)) {
                                        EventRowView(event: event)
                                    }
                                    
                                    if event.id != eventViewModel.upcomingEvents.prefix(3).last?.id {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                                
                                if eventViewModel.events.count > 3 {
                                    NavigationLink(destination: EventListView(contact: contact)) {
                                        Text("すべて表示")
                                            .font(AppFonts.subheadline)
                                            .foregroundColor(AppColors.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                                }
                            }
                        }
                    }
                    
                    // グループ
                    else if selectedTab == 2 {
                        VStack(alignment: .leading) {
                            Text("所属グループ")
                                .font(AppFonts.headline)
                                .padding(.horizontal)
                                .padding(.top)
                            
                            if contact.groupsArray.isEmpty {
                                HStack {
                                    Spacer()
                                    Text("グループがありません")
                                        .font(AppFonts.body)
                                        .foregroundColor(AppColors.textSecondary)
                                        .padding()
                                    Spacer()
                                }
                            } else {
                                ForEach(contact.groupsArray) { group in
                                    NavigationLink(destination: GroupDetailView(group: group)) {
                                        GroupRowView(group: group)
                                    }
                                    
                                    if group.id != contact.groupsArray.last?.id {
                                        Divider()
                                            .padding(.horizontal)
                                    }
                                }
                            }
                        }
                    }
                }
                .background(AppColors.cardBackground)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("\(contact.firstName) \(contact.lastName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditSheet = true
                    }) {
                        Label("編集", systemImage: "pencil")
                    }
                    
                    Button(action: {
                        contactViewModel.toggleFavorite(contact)
                    }) {
                        if contact.isFavorite {
                            Label("お気に入りから削除", systemImage: "star.slash")
                        } else {
                            Label("お気に入りに追加", systemImage: "star")
                        }
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditContactView(contact: contact)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddCommunicationSheet) {
            AddCommunicationView(contact: contact)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddEventSheet) {
            AddEventView(initialDate: Date())
                .environment(\.managedObjectContext, viewContext)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("連絡先を削除"),
                message: Text("\(contact.fullName)の連絡先を削除してもよろしいですか？関連するコミュニケーション履歴もすべて削除されます。"),
                primaryButton: .destructive(Text("削除")) {
                    deleteContact()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .onAppear {
            communicationViewModel.fetchCommunications()
            eventViewModel.fetchEvents()
        }
    }
    
    // 連絡先を削除
    private func deleteContact() {
        contactViewModel.deleteContact(contact)
        presentationMode.wrappedValue.dismiss()
    }
    
    // 電話をかける
    private func callPhoneNumber(_ phoneNumber: String) {
        let cleanedPhoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
        if let url = URL(string: "tel://\(cleanedPhoneNumber)") {
            UIApplication.shared.open(url)
        }
    }
    
    // メールを送信
    private func sendEmail(_ email: String) {
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// 編集画面（省略版 - 実際はAddContactViewのような編集機能を実装）
struct EditContactView: View {
    @Environment(\.presentationMode) private var presentationMode
    var contact: ContactEntity
    
    var body: some View {
        NavigationView {
            Text("連絡先編集画面")
                .navigationTitle("連絡先を編集")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("キャンセル") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("保存") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

// イベント一覧画面（省略版）
struct EventListView: View {
    var contact: ContactEntity
    
    var body: some View {
        Text("\(contact.fullName)のイベント一覧")
            .navigationTitle("予定")
    }
}

// 情報行コンポーネント
struct InfoRow: View {
    var icon: String
    var title: String
    var value: String
    var detail: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.textTertiary)
                
                Text(title)
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            HStack {
                Text(value)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                if let detail = detail {
                    Spacer()
                    
                    Text(detail)
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    NavigationView {
        ContactDetailView(contact: PersistenceController.preview.container.viewContext.registeredObjects.first { $0 is ContactEntity } as! ContactEntity)
    }
}
