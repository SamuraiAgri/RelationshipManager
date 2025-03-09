
import SwiftUI

struct ContactsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel: ContactViewModel
    
    @State private var showingAddContactSheet = false
    @State private var searchText = ""
    @State private var showingFilterOptions = false
    @State private var showingDeleteConfirmation = false
    @State private var multiSelectionMode = false
    @State private var selectedContacts: Set<UUID> = []
    
    init() {
        _viewModel = StateObject(wrappedValue: ContactViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 検索バー
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(searchText.isEmpty ? AppColors.textTertiary : AppColors.primary)
                    
                    TextField("連絡先を検索", text: $searchText)
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
                
                // 連絡先リスト
                if viewModel.filteredContacts.isEmpty {
                    Spacer()
                    Text("連絡先が見つかりません")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.filteredContacts) { contact in
                            NavigationLink(destination: ContactDetailView(contact: contact)) {
                                ContactRowView(
                                    contact: contact,
                                    isSelected: selectedContacts.contains(contact.id ?? UUID()),
                                    isMultiSelectionMode: multiSelectionMode
                                )
                                .onTapGesture {
                                    if multiSelectionMode {
                                        toggleSelection(for: contact)
                                    }
                                }
                            }
                            .disabled(multiSelectionMode)
                        }
                        .onDelete(perform: deleteContacts)
                    }
                    .listStyle(PlainListStyle())
                    
                    // 複数選択モードのツールバー
                    if multiSelectionMode {
                        HStack {
                            Button(action: {
                                selectedContacts.removeAll()
                                multiSelectionMode = false
                            }) {
                                Text("キャンセル")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.primary)
                            }
                            
                            Spacer()
                            
                            Text("\(selectedContacts.count)件選択")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                            
                            Spacer()
                            
                            Button(action: {
                                showingDeleteConfirmation = true
                            }) {
                                Text("削除")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.error)
                            }
                            .disabled(selectedContacts.isEmpty)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("連絡先")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !multiSelectionMode {
                        Menu {
                            Button(action: {
                                showingAddContactSheet = true
                            }) {
                                Label("新規連絡先", systemImage: "person.badge.plus")
                            }
                            
                            Button(action: {
                                multiSelectionMode = true
                            }) {
                                Label("選択", systemImage: "checkmark.circle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !multiSelectionMode {
                        Button(action: {
                            showingAddContactSheet = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddContactSheet) {
                AddContactView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .alert(isPresented: $showingDeleteConfirmation) {
                Alert(
                    title: Text("連絡先の削除"),
                    message: Text("選択した\(selectedContacts.count)件の連絡先を削除してもよろしいですか？"),
                    primaryButton: .destructive(Text("削除")) {
                        deleteSelectedContacts()
                    },
                    secondaryButton: .cancel(Text("キャンセル"))
                )
            }
            .onAppear {
                viewModel.fetchContacts()
            }
        }
    }
    
    // 連絡先の選択を切り替え
    private func toggleSelection(for contact: ContactEntity) {
        if let id = contact.id {
            if selectedContacts.contains(id) {
                selectedContacts.remove(id)
            } else {
                selectedContacts.insert(id)
            }
        }
    }
    
    // 選択した連絡先を削除
    private func deleteSelectedContacts() {
        let contactsToDelete = viewModel.filteredContacts.filter { contact in
            if let id = contact.id {
                return selectedContacts.contains(id)
            }
            return false
        }
        
        viewModel.deleteContacts(contactsToDelete)
        selectedContacts.removeAll()
        multiSelectionMode = false
    }
    
    // スワイプで連絡先を削除
    private func deleteContacts(at offsets: IndexSet) {
        let contactsToDelete = offsets.map { viewModel.filteredContacts[$0] }
        viewModel.deleteContacts(contactsToDelete)
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
