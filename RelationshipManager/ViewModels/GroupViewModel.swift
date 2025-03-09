
import Foundation
import CoreData
import SwiftUI

class GroupViewModel: ObservableObject {
    @Published var groups: [GroupEntity] = []
    @Published var filteredGroups: [GroupEntity] = []
    @Published var selectedCategory: AppConstants.Category?
    @Published var searchText: String = ""
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchGroups()
    }
    
    // すべてのグループを取得
    func fetchGroups() {
        let request = NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \GroupEntity.name, ascending: true)]
        
        do {
            groups = try viewContext.fetch(request)
            filterGroups()
        } catch {
            print("グループの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // グループのフィルタリング
    func filterGroups() {
        // カテゴリと検索テキストに基づいてフィルタリング
        filteredGroups = groups.filter { group in
            // カテゴリフィルタ
            if let selectedCategory = selectedCategory, group.category != selectedCategory.rawValue {
                return false
            }
            
            // 検索テキストフィルタ
            if !searchText.isEmpty {
                let searchableText = "\(group.name) \(group.description ?? "")"
                return searchableText.lowercased().contains(searchText.lowercased())
            }
            
            return true
        }
    }
    
    // カテゴリフィルタを設定
    func setCategory(_ category: AppConstants.Category?) {
        selectedCategory = category
        filterGroups()
    }
    
    // 検索テキストを設定
    func setSearchText(_ text: String) {
        searchText = text
        filterGroups()
    }
    
    // 新しいグループを追加
    func addGroup(name: String, description: String?, category: String) -> GroupEntity {
        let newGroup = GroupEntity(context: viewContext)
        newGroup.id = UUID()
        newGroup.name = name
        newGroup.description = description
        newGroup.category = category
        newGroup.createdAt = Date()
        newGroup.updatedAt = Date()
        
        saveContext()
        fetchGroups()
        
        return newGroup
    }
    
    // グループを更新
    func updateGroup(_ group: GroupEntity, name: String, description: String?, category: String) {
        group.name = name
        group.description = description
        group.category = category
        group.updatedAt = Date()
        
        saveContext()
        fetchGroups()
    }
    
    // グループを削除
    func deleteGroup(_ group: GroupEntity) {
        viewContext.delete(group)
        saveContext()
        fetchGroups()
    }
    
    // 複数のグループを削除
    func deleteGroups(_ groups: [GroupEntity]) {
        for group in groups {
            viewContext.delete(group)
        }
        saveContext()
        fetchGroups()
    }
    
    // グループに連絡先を追加
    func addContactToGroup(_ contact: ContactEntity, group: GroupEntity) {
        group.addToContacts(contact)
        saveContext()
        fetchGroups()
    }
    
    // グループから連絡先を削除
    func removeContactFromGroup(_ contact: ContactEntity, group: GroupEntity) {
        group.removeFromContacts(contact)
        saveContext()
        fetchGroups()
    }
    
    // グループにイベントを追加
    func addEventToGroup(_ event: EventEntity, group: GroupEntity) {
        group.addToEvents(event)
        saveContext()
        fetchGroups()
    }
    
    // グループからイベントを削除
    func removeEventFromGroup(_ event: EventEntity, group: GroupEntity) {
        group.removeFromEvents(event)
        saveContext()
        fetchGroups()
    }
    
    // 変更を保存
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("データの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // グループのメンバー数を取得
    func getMemberCount(for group: GroupEntity) -> Int {
        return group.contacts?.count ?? 0
    }
    
    // グループのイベント数を取得
    func getEventCount(for group: GroupEntity) -> Int {
        return group.events?.count ?? 0
    }
    
    // グループのメンバーを取得
    func getMembers(for group: GroupEntity) -> [ContactEntity] {
        return group.contacts?.allObjects as? [ContactEntity] ?? []
    }
    
    // グループのイベントを取得
    func getEvents(for group: GroupEntity) -> [EventEntity] {
        return group.events?.allObjects as? [EventEntity] ?? []
    }
    
    // カテゴリに基づいて色を取得
    func getCategoryColor(for group: GroupEntity) -> Color {
        if group.category == AppConstants.Category.business.rawValue {
            return AppColors.businessCategory
        } else {
            return AppColors.privateCategory
        }
    }
}
