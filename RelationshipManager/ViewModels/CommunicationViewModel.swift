
import Foundation
import CoreData
import SwiftUI

class CommunicationViewModel: ObservableObject {
    @Published var communications: [CommunicationEntity] = []
    @Published var filteredCommunications: [CommunicationEntity] = []
    @Published var selectedType: AppConstants.CommunicationType?
    @Published var searchText: String = ""
    
    private var viewContext: NSManagedObjectContext
    private var contact: ContactEntity?
    
    init(context: NSManagedObjectContext, contact: ContactEntity? = nil) {
        self.viewContext = context
        self.contact = contact
        fetchCommunications()
    }
    
    // コミュニケーション履歴を取得
    func fetchCommunications() {
        let request = NSFetchRequest<CommunicationEntity>(entityName: "CommunicationEntity")
        
        // 特定の連絡先が指定されている場合はフィルタリング
        if let contact = contact {
            request.predicate = NSPredicate(format: "contact == %@", contact)
        }
        
        // 日付の降順でソート
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CommunicationEntity.date, ascending: false)]
        
        do {
            communications = try viewContext.fetch(request)
            filterCommunications()
        } catch {
            print("コミュニケーションの取得に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // コミュニケーションのフィルタリング
    func filterCommunications() {
        // タイプと検索テキストに基づいてフィルタリング
        filteredCommunications = communications.filter { communication in
            // タイプフィルタ
            if let selectedType = selectedType, communication.type != selectedType.rawValue {
                return false
            }
            
            // 検索テキストフィルタ
            if !searchText.isEmpty {
                let searchableText = "\(communication.content) \(communication.contact?.firstName ?? "") \(communication.contact?.lastName ?? "")"
                return searchableText.lowercased().contains(searchText.lowercased())
            }
            
            return true
        }
    }
    
    // タイプフィルタを設定
    func setType(_ type: AppConstants.CommunicationType?) {
        selectedType = type
        filterCommunications()
    }
    
    // 検索テキストを設定
    func setSearchText(_ text: String) {
        searchText = text
        filterCommunications()
    }
    
    // 新しいコミュニケーションを追加
    func addCommunication(type: String, content: String, date: Date, contact: ContactEntity) -> CommunicationEntity {
        let newCommunication = CommunicationEntity(context: viewContext)
        newCommunication.id = UUID()
        newCommunication.type = type
        newCommunication.content = content
        newCommunication.date = date
        newCommunication.contact = contact
        newCommunication.createdAt = Date()
        newCommunication.updatedAt = Date()
        
        saveContext()
        fetchCommunications()
        
        return newCommunication
    }
    
    // コミュニケーションを更新
    func updateCommunication(_ communication: CommunicationEntity, type: String, content: String, date: Date) {
        communication.type = type
        communication.content = content
        communication.date = date
        communication.updatedAt = Date()
        
        saveContext()
        fetchCommunications()
    }
    
    // コミュニケーションを削除
    func deleteCommunication(_ communication: CommunicationEntity) {
        viewContext.delete(communication)
        saveContext()
        fetchCommunications()
    }
    
    // 複数のコミュニケーションを削除
    func deleteCommunications(_ communications: [CommunicationEntity]) {
        for communication in communications {
            viewContext.delete(communication)
        }
        saveContext()
        fetchCommunications()
    }
    
    // 連絡先に関連するすべてのコミュニケーションを削除
    func deleteAllCommunicationsForContact(_ contact: ContactEntity) {
        let request = NSFetchRequest<CommunicationEntity>(entityName: "CommunicationEntity")
        request.predicate = NSPredicate(format: "contact == %@", contact)
        
        do {
            let communications = try viewContext.fetch(request)
            for communication in communications {
                viewContext.delete(communication)
            }
            saveContext()
            fetchCommunications()
        } catch {
            print("コミュニケーションの削除に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // 変更を保存
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("データの保存に失敗しました: \(error.localizedDescription)")
        }
    }
    
    // コミュニケーションタイプに基づいて色を取得
    func getTypeColor(for communication: CommunicationEntity) -> Color {
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
    
    // コミュニケーションタイプに基づいてアイコン名を取得
    func getTypeIconName(for communication: CommunicationEntity) -> String {
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
    
    // 日付に基づいて相対的な時間表現を取得
    func getRelativeTimeString(for date: Date) -> String {
        return date.relativeFormatted
    }
}
