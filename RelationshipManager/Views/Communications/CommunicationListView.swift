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
        .navigationTitle("\(contact.firstName ?? "") \(contact.lastName ?? "")")
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
