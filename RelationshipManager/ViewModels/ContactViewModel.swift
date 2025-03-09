
import Foundation
import CoreData
import SwiftUI

class ContactViewModel: ObservableObject {
    @Published var contacts: [ContactEntity] = []
    @Published var filteredContacts: [ContactEntity] = []
    @Published var selectedCategory: AppConstants.Category?
    @Published var searchText: String = ""
    
    private var viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
        fetchContacts()
    }
    
    // すべての連絡先を取得
    func fetchContacts() {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \ContactEntity.firstName, ascending: true)]
        
        do {
            contacts = try viewContext.fetch(request)
            filterContacts()
        } catch {
            print("連絡先の取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 連絡先のフィルタリング
    func filterContacts() {
        // カテゴリと検索テキストに基づいてフィルタリング
        filteredContacts = contacts.filter { contact in
            // カテゴリフィルタ
            if let selectedCategory = selectedCategory, contact.category != selectedCategory.rawValue {
                return false
            }
            
            // 検索テキストフィルタ
            if !searchText.isEmpty {
                let searchableText = "\(contact.firstName) \(contact.lastName) \(contact.email ?? "") \(contact.phoneNumber ?? "")"
                return searchableText.lowercased().contains(searchText.lowercased())
            }
            
            return true
        }
    }
    
    // カテゴリフィルタを設定
    func setCategory(_ category: AppConstants.Category?) {
        selectedCategory = category
        filterContacts()
    }
    
    // 検索テキストを設定
    func setSearchText(_ text: String) {
        searchText = text
        filterContacts()
    }
    
    // 新しい連絡先を追加
    func addContact(firstName: String, lastName: String, phoneNumber: String?, email: String?,
                   birthday: Date?, notes: String?, category: String, profileImage: UIImage? = nil) -> ContactEntity {
        let newContact = ContactEntity(context: viewContext)
        newContact.id = UUID()
        newContact.firstName = firstName
        newContact.lastName = lastName
        newContact.phoneNumber = phoneNumber
        newContact.email = email
        newContact.birthday = birthday
        newContact.notes = notes
        newContact.category = category
        newContact.createdAt = Date()
        newContact.updatedAt = Date()
        
        // プロフィール画像がある場合は保存
        if let profileImage = profileImage {
            newContact.profileImageData = profileImage.jpegData(compressionQuality: 0.7)
        }
        
        saveContext()
        fetchContacts()
        
        return newContact
    }
    
    // 連絡先を更新
    func updateContact(_ contact: ContactEntity, firstName: String, lastName: String, phoneNumber: String?,
                      email: String?, birthday: Date?, notes: String?, category: String, profileImage: UIImage? = nil) {
        contact.firstName = firstName
        contact.lastName = lastName
        contact.phoneNumber = phoneNumber
        contact.email = email
        contact.birthday = birthday
        contact.notes = notes
        contact.category = category
        contact.updatedAt = Date()
        
        // プロフィール画像がある場合は保存
        if let profileImage = profileImage {
            contact.profileImageData = profileImage.jpegData(compressionQuality: 0.7)
        }
        
        saveContext()
        fetchContacts()
    }
    
    // 連絡先を削除
    func deleteContact(_ contact: ContactEntity) {
        viewContext.delete(contact)
        saveContext()
        fetchContacts()
    }
    
    // 複数の連絡先を削除
    func deleteContacts(_ contacts: [ContactEntity]) {
        for contact in contacts {
            viewContext.delete(contact)
        }
        saveContext()
        fetchContacts()
    }
    
    // 連絡先をグループに追加
    func addContactToGroup(_ contact: ContactEntity, group: GroupEntity) {
        group.addToContacts(contact)
        saveContext()
    }
    
    // 連絡先をグループから削除
    func removeContactFromGroup(_ contact: ContactEntity, group: GroupEntity) {
        group.removeFromContacts(contact)
        saveContext()
    }
    
    // 連絡先をお気に入りに追加/削除
    func toggleFavorite(_ contact: ContactEntity) {
        contact.isFavorite.toggle()
        saveContext()
        fetchContacts()
    }
    
    // 変更を保存
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("データの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 連絡先の完全な名前を取得
    func getFullName(for contact: ContactEntity) -> String {
        return "\(contact.firstName) \(contact.lastName)"
    }
    
    // カテゴリに基づいて色を取得
    func getCategoryColor(for contact: ContactEntity) -> Color {
        if contact.category == AppConstants.Category.business.rawValue {
            return AppColors.businessCategory
        } else {
            return AppColors.privateCategory
        }
    }
    
    // 連絡先のイニシャルを取得
    func getInitials(for contact: ContactEntity) -> String {
        let firstInitial = contact.firstName.prefix(1).uppercased()
        let lastInitial = contact.lastName.prefix(1).uppercased()
        return "\(firstInitial)\(lastInitial)"
    }
}
