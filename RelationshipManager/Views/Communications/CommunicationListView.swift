
// CommunicationListView.swift
import SwiftUI

struct CommunicationListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: CommunicationViewModel
    
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var selectedCommunication: CommunicationEntity?
    
    var contact: ContactEntity
    
    init(contact: ContactEntity) {
        self.contact = contact
        _viewModel = StateObject(wrappedValue: CommunicationViewModel(
            context: PersistenceController.shared.container.viewContext,
            contact: contact
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searchText.isEmpty ? AppColors.textTertiary : AppColors.primary)
                
                TextField("コミュニケーションを検索", text: $searchText)
                    .onChange(of: searchText) { _, newValue in
                        viewModel.setSearchText(newValue)
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.setSearchText("")
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
            .padding(.bottom, 10)
            
            // タイプフィルター
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    TypeFilterButton(
                        title: "すべて",
                        isSelected: viewModel.selectedType == nil,
                        color: AppColors.primary
                    ) {
                        viewModel.setType(nil)
                    }
                    
                    ForEach(AppConstants.CommunicationType.allCases) { type in
                        TypeFilterButton(
                            title: type.displayName,
                            isSelected: viewModel.selectedType == type,
                            color: getCommunicationTypeColor(type: type.rawValue)
                        ) {
                            viewModel.setType(type)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)
            
            // コミュニケーションリスト
            if viewModel.filteredCommunications.isEmpty {
                Spacer()
                Text("コミュニケーションが見つかりません")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(viewModel.filteredCommunications) { communication in
                        CommunicationRowView(communication: communication)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedCommunication = communication
                                showingDeleteAlert = true
                            }
                    }
                    .onDelete(perform: deleteCommunications)
                }
                .listStyle(PlainListStyle())
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("\(contact.firstName) \(contact.lastName)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingAddSheet = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddCommunicationView(contact: contact)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("コミュニケーションを削除"),
                message: Text("このコミュニケーション記録を削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    if let communication = selectedCommunication {
                        viewModel.deleteCommunication(communication)
                    }
                    selectedCommunication = nil
                },
                secondaryButton: .cancel(Text("キャンセル")) {
                    selectedCommunication = nil
                }
            )
        }
        .onAppear {
            viewModel.fetchCommunications()
        }
    }
    
    // コミュニケーションタイプの色を取得
    private func getCommunicationTypeColor(type: String) -> Color {
        switch type {
        case AppConstants.CommunicationType.call.rawValue:
            return AppColors.callType
        case AppConstants.CommunicationType.email.rawValue:
            return AppColors.emailType
        case AppConstants.CommunicationType.meeting.rawValue:
            return AppColors.meetingType
        case AppConstants.CommunicationType.message.rawValue:
            return AppColors.messageType
        default:
            return AppColors.primary
        }
    }
    
    // スワイプで削除
    private func deleteCommunications(at offsets: IndexSet) {
        let communicationsToDelete = offsets.map { viewModel.filteredCommunications[$0] }
        for communication in communicationsToDelete {
            viewModel.deleteCommunication(communication)
        }
    }
}

// タイプフィルターボタン
struct TypeFilterButton: View {
    var title: String
    var isSelected: Bool
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppFonts.subheadline)
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .cornerRadius(20)
        }
    }
}

// CommunicationRowView.swift
import SwiftUI

struct CommunicationRowView: View {
    var communication: CommunicationEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: getTypeIconName())
                    .foregroundColor(getTypeColor())
                
                Text(getTypeDisplayName())
                    .font(AppFonts.headline)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Text(getRelativeTimeString())
                    .font(AppFonts.caption1)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(communication.content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(3)
        }
        .padding(.vertical, 8)
    }
    
    // コミュニケーションタイプアイコンを取得
    private func getTypeIconName() -> String {
        switch communication.type {
        case AppConstants.CommunicationType.call.rawValue:
            return "phone"
        case AppConstants.CommunicationType.email.rawValue:
            return "envelope"
        case AppConstants.CommunicationType.meeting.rawValue:
            return "person.2"
        case AppConstants.CommunicationType.message.rawValue:
            return "message"
        default:
            return "circle"
        }
    }
    
    // コミュニケーションタイプの色を取得
    private func getTypeColor() -> Color {
        switch communication.type {
        case AppConstants.CommunicationType.call.rawValue:
            return AppColors.callType
        case AppConstants.CommunicationType.email.rawValue:
            return AppColors.emailType
        case AppConstants.CommunicationType.meeting.rawValue:
            return AppColors.meetingType
        case AppConstants.CommunicationType.message.rawValue:
            return AppColors.messageType
        default:
            return AppColors.primary
        }
    }
    
    // コミュニケーションタイプの表示名を取得
    private func getTypeDisplayName() -> String {
        switch communication.type {
        case AppConstants.CommunicationType.call.rawValue:
            return AppConstants.CommunicationType.call.displayName
        case AppConstants.CommunicationType.email.rawValue:
            return AppConstants.CommunicationType.email.displayName
        case AppConstants.CommunicationType.meeting.rawValue:
            return AppConstants.CommunicationType.meeting.displayName
        case AppConstants.CommunicationType.message.rawValue:
            return AppConstants.CommunicationType.message.displayName
        default:
            return communication.type
        }
    }
    
    // 相対的な時間表現を取得
    private func getRelativeTimeString() -> String {
        return communication.date.relativeFormatted
    }
}

// AddCommunicationView.swift
import SwiftUI

struct AddCommunicationView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel: CommunicationViewModel
    
    @State private var type = AppConstants.CommunicationType.call.rawValue
    @State private var content = ""
    @State private var date = Date()
    
    var contact: ContactEntity
    
    init(contact: ContactEntity) {
        self.contact = contact
        _viewModel = StateObject(wrappedValue: CommunicationViewModel(
            context: PersistenceController.shared.container.viewContext,
            contact: contact
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // コミュニケーションタイプ
                Section(header: Text("コミュニケーションタイプ")) {
                    Picker("タイプ", selection: $type) {
                        ForEach(AppConstants.CommunicationType.allCases) { type in
                            Text(type.displayName).tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 日時
                Section(header: Text("日時")) {
                    DatePicker(
                        "日時",
                        selection: $date,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
                
                // 内容
                Section(header: Text("内容")) {
                    ZStack(alignment: .topLeading) {
                        if content.isEmpty {
                            Text("メモ")
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                }
                
                // 連絡先情報
                Section(header: Text("連絡先情報")) {
                    HStack {
                        AvatarView(
                            imageData: contact.profileImageData,
                            initials: "\(contact.firstName.prefix(1))\(contact.lastName.prefix(1))",
                            size: 40,
                            backgroundColor: contact.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory
                        )
                        
                        VStack(alignment: .leading) {
                            Text("\(contact.firstName) \(contact.lastName)")
                                .font(AppFonts.headline)
                            
                            if let phoneNumber = contact.phoneNumber, !phoneNumber.isEmpty {
                                Text(phoneNumber)
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                            } else if let email = contact.email, !email.isEmpty {
                                Text(email)
                                    .font(AppFonts.caption1)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        
                        Spacer()
                        
                        CategoryBadgeView(category: contact.category)
                    }
                }
            }
            .navigationTitle("コミュニケーション追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveCommunication()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
    
    // コミュニケーションを保存
    private func saveCommunication() {
        viewModel.addCommunication(
            type: type,
            content: content,
            date: date,
            contact: contact
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}
