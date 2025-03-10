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
                
                Text(group.name ?? "")
                    .font(AppFonts.title2)
                    .padding(.top, 8)
                
                CategoryBadgeView(category: group.category ?? "")
                    .padding(.top, 4)
                
                if let description = group.descriptionText, !description.isEmpty {
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
                DetailMembersTab(
                    group: group,
                    members: viewModel.getMembers(for: group),
                    onAddMember: {
                        showingAddMemberSheet = true
                    }
                )
                .tag(0)
                
                // イベントタブ
                DetailEventsTab(
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

// 名前の変更によって重複を避ける
struct DetailMembersTab: View {
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

// 名前の変更によって重複を避ける
struct DetailEventsTab: View {
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
