import SwiftUI

struct GroupDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel: GroupViewModel
    @StateObject private var eventViewModel: EventViewModel
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    @State private var showingAddMemberSheet = false
    @State private var showingAddEventSheet = false
    @State private var selectedTab = 0
    
    var group: GroupEntity
    
    init(group: GroupEntity) {
        self.group = group
        
        _viewModel = StateObject(wrappedValue: GroupViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
        
        _eventViewModel = StateObject(wrappedValue: EventViewModel(
            context: PersistenceController.shared.container.viewContext,
            group: group
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // グループヘッダー
            VStack {
                ZStack {
                    Circle()
                        .fill(group.category == AppConstants.Category.business.rawValue ? AppColors.businessCategory : AppColors.privateCategory)
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.white)
                }
                .padding(.top)
                
                Text(group.name)
                    .font(AppFonts.title2)
                    .padding(.top, 8)
                
                CategoryBadgeView(category: group.category)
                    .padding(.top, 4)
                
                if let description = group.description, !description.isEmpty {
                    Text(description)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                        .padding(.horizontal)
                }
                
                HStack {
                    VStack {
                        Text("\(viewModel.getMemberCount(for: group))")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("メンバー")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Divider()
                        .frame(height: 30)
                    
                    VStack {
                        Text("\(viewModel.getEventCount(for: group))")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("イベント")
                            .font(AppFonts.caption1)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.top, 16)
            }
            .padding(.bottom)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            .padding()
            
            // タブビュー
            Picker("表示", selection: $selectedTab) {
                Text("メンバー").tag(0)
                Text("イベント").tag(1)
                Text("関係図").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            TabView(selection: $selectedTab) {
                // メンバータブ
                MembersTab(
                    group: group,
                    members: viewModel.getMembers(for: group),
                    onAddMember: {
                        showingAddMemberSheet = true
                    }
                )
                .tag(0)
                
                // イベントタブ
                EventsTab(
                    events: eventViewModel.events,
                    onAddEvent: {
                        showingAddEventSheet = true
                    }
                )
                .tag(1)
                
                // 関係図タブ
                RelationshipMapView(group: group)
                    .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("グループ詳細")
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
            EditGroupView(group: group)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddMemberSheet) {
            AddMemberView(group: group)
                .environment(\.managedObjectContext, viewContext)
        }
        .sheet(isPresented: $showingAddEventSheet) {
            AddEventView(initialDate: Date(), group: group)
                .environment(\.managedObjectContext, viewContext)
        }
        .alert(isPresented: $showingDeleteAlert) {
            Alert(
                title: Text("グループを削除"),
                message: Text("このグループを削除してもよろしいですか？"),
                primaryButton: .destructive(Text("削除")) {
                    deleteGroup()
                },
                secondaryButton: .cancel(Text("キャンセル"))
            )
        }
        .onAppear {
            viewModel.fetchGroups()
            eventViewModel.fetchEvents()
        }
    }
    
    // グループを削除
    private func deleteGroup() {
        viewModel.deleteGroup(group)
        presentationMode.wrappedValue.dismiss()
    }
}

// メンバータブ
struct MembersTab: View {
    @Environment(\.managedObjectContext) private var viewContext
    var group: GroupEntity
    var members: [ContactEntity]
    var onAddMember: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("メンバー")
                    .font(AppFonts.title3)
                
                Spacer()
                
                Button(action: onAddMember) {
                    Image(systemName: "person.badge.plus")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            if members.isEmpty {
                Spacer()
                Text("メンバーがいません")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(members) { contact in
                        NavigationLink(destination: ContactDetailView(contact: contact)) {
                            ContactRowView(contact: contact)
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                removeMember(contact)
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    // メンバーをグループから削除
    private func removeMember(_ contact: ContactEntity) {
        let groupViewModel = GroupViewModel(context: viewContext)
        groupViewModel.removeContactFromGroup(contact, group: group)
    }
}

// イベントタブ
struct EventsTab: View {
    var events: [EventEntity]
    var onAddEvent: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Text("イベント")
                    .font(AppFonts.title3)
                
                Spacer()
                
                Button(action: onAddEvent) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            if events.isEmpty {
                Spacer()
                Text("イベントがありません")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            } else {
                List {
                    ForEach(events) { event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            EventRowView(event: event)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// グループ編集用ビュー
struct EditGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel = GroupViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var name: String
    @State private var description: String
    @State private var category: String
    
    var group: GroupEntity
    
    init(group: GroupEntity) {
        self.group = group
        _name = State(initialValue: group.name)
        _description = State(initialValue: group.description ?? "")
        _category = State(initialValue: group.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    TextField("グループ名", text: $name)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("説明")
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    
                    Picker("カテゴリ", selection: $category) {
                        Text(AppConstants.Category.business.displayName)
                            .tag(AppConstants.Category.business.rawValue)
                        
                        Text(AppConstants.Category.private.displayName)
                            .tag(AppConstants.Category.private.rawValue)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("グループ編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveGroup()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    // グループを保存
    private func saveGroup() {
        viewModel.updateGroup(
            group,
            name: name,
            description: description.isEmpty ? nil : description,
            category: category
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// グループ新規作成用ビュー
struct AddGroupView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var viewModel = GroupViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var name = ""
    @State private var description = ""
    @State private var category = AppConstants.Category.private.rawValue
    
    var body: some View {
        NavigationView {
            Form {
                // 基本情報セクション
                Section(header: Text("基本情報")) {
                    TextField("グループ名", text: $name)
                    
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("説明")
                                .foregroundColor(AppColors.textTertiary)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        
                        TextEditor(text: $description)
                            .frame(minHeight: 100)
                    }
                    
                    Picker("カテゴリ", selection: $category) {
                        Text(AppConstants.Category.business.displayName)
                            .tag(AppConstants.Category.business.rawValue)
                        
                        Text(AppConstants.Category.private.displayName)
                            .tag(AppConstants.Category.private.rawValue)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("グループ追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveGroup()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    // グループを保存
    private func saveGroup() {
        viewModel.addGroup(
            name: name,
            description: description.isEmpty ? nil : description,
            category: category
        )
        
        presentationMode.wrappedValue.dismiss()
    }
}

// グループにメンバーを追加するビュー
struct AddMemberView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @StateObject private var contactViewModel = ContactViewModel(context: PersistenceController.shared.container.viewContext)
    @StateObject private var groupViewModel = GroupViewModel(context: PersistenceController.shared.container.viewContext)
    
    @State private var searchText = ""
    @State private var selectedIds: Set<UUID> = []
    
    var group: GroupEntity
    
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
            .navigationTitle("メンバーを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("追加") {
                        addSelectedContacts()
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                contactViewModel.fetchContacts()
                
                // 既にグループに所属している連絡先をマーク
                if let existingMembers = group.contacts?.allObjects as? [ContactEntity] {
                    selectedIds = Set(existingMembers.compactMap { $0.id })
                }
            }
        }
    }
    
    // 連絡先が選択されているかをチェック
    private func isSelected(_ contact: ContactEntity) -> Bool {
        if let id = contact.id {
            return selectedIds.contains(id)
        }
        return false
    }
    
    // 連絡先の選択を切り替え
    private func toggleSelection(_ contact: ContactEntity) {
        if let id = contact.id {
            if selectedIds.contains(id) {
                selectedIds.remove(id)
            } else {
                selectedIds.insert(id)
            }
        }
    }
    
    // 選択された連絡先をグループに追加
    private func addSelectedContacts() {
        // 既存のメンバーを取得
        let existingMembers = group.contacts?.allObjects as? [ContactEntity] ?? []
        let existingIds = Set(existingMembers.compactMap { $0.id })
        
        // 削除されたメンバーを処理
        for member in existingMembers {
            if let id = member.id, !selectedIds.contains(id) {
                groupViewModel.removeContactFromGroup(member, group: group)
            }
        }
        
        // 追加されたメンバーを処理
        for contact in contactViewModel.contacts {
            if let id = contact.id, selectedIds.contains(id), !existingIds.contains(id) {
                groupViewModel.addContactToGroup(contact, group: group)
            }
        }
    }
}
