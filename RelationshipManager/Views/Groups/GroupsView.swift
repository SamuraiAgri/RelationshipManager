// GroupsView.swift
import SwiftUI

struct GroupsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: GroupViewModel
    
    @State private var showingAddSheet = false
    @State private var searchText = ""
    @State private var showingDeleteAlert = false
    @State private var selectedGroup: GroupEntity?
    
    init() {
        _viewModel = StateObject(wrappedValue: GroupViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchText.isEmpty ? AppColors.textTertiary : AppColors.primary)
                    
                    TextField("グループを検索", text: $searchText)
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
                
                // カテゴリフィルター
                CategoryFilterView(
                    selectedCategory: Binding(
                        get: { viewModel.selectedCategory },
                        set: { viewModel.setCategory($0) }
                    )
                )
                .padding(.bottom, 10)
                
                // グループリスト
                if viewModel.filteredGroups.isEmpty {
                    Spacer()
                    Text("グループが見つかりません")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredGroups) { group in
                            NavigationLink(destination: GroupDetailView(group: group)) {
                                GroupRowView(group: group)
                            }
                        }
                        .onDelete(perform: deleteGroups)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("グループ")
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
                AddGroupView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("グループを削除"),
                    message: Text("このグループを削除してもよろしいですか？"),
                    primaryButton: .destructive(Text("削除")) {
                        if let group = selectedGroup {
                            viewModel.deleteGroup(group)
                        }
                        selectedGroup = nil
                    },
                    secondaryButton: .cancel(Text("キャンセル")) {
                        selectedGroup = nil
                    }
                )
            }
            .onAppear {
                viewModel.fetchGroups()
            }
        }
    }
    
    // スワイプで削除
    private func deleteGroups(at offsets: IndexSet) {
        let groupsToDelete = offsets.map { viewModel.filteredGroups[$0] }
        for group in groupsToDelete {
            viewModel.deleteGroup(group)
        }
    }
}

// AddGroupView.swift
import SwiftUI

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

// AddMemberView.swift
import SwiftUI

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
                                .foregroundColor(
                                    AppColors.textTertiary)
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
