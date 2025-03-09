import CoreData

struct PersistenceController {
    // シングルトンインスタンス
    static let shared = PersistenceController()
    
    // プレビュー用のインスタンス
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // プレビュー用にサンプルデータを作成
        let viewContext = controller.container.viewContext
        
        // テンプレートアイテム作成
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
        // サンプル連絡先を作成
        let contact1 = ContactEntity(context: viewContext)
        contact1.id = UUID()
        contact1.firstName = "太郎"
        contact1.lastName = "山田"
        contact1.email = "taro@example.com"
        contact1.phoneNumber = "090-1234-5678"
        contact1.category = "Business"
        contact1.createdAt = Date()
        contact1.updatedAt = Date()
        
        let contact2 = ContactEntity(context: viewContext)
        contact2.id = UUID()
        contact2.firstName = "花子"
        contact2.lastName = "鈴木"
        contact2.email = "hanako@example.com"
        contact2.phoneNumber = "090-8765-4321"
        contact2.category = "Private"
        contact2.createdAt = Date()
        contact2.updatedAt = Date()
        
        // サンプルグループを作成
        let group = GroupEntity(context: viewContext)
        group.id = UUID()
        group.name = "プロジェクトA"
        group.descriptionText = "重要プロジェクト"
        group.category = "Business"
        group.createdAt = Date()
        group.updatedAt = Date()
        group.addToContacts(contact1)
        group.addToContacts(contact2)
        
        // サンプルイベントを作成
        let event = EventEntity(context: viewContext)
        event.id = UUID()
        event.title = "プロジェクトミーティング"
        event.details = "プロジェクトAの進捗確認"
        event.startDate = Date()
        event.endDate = Date().addingTimeInterval(3600)
        event.isAllDay = false
        event.reminder = true
        event.reminderDate = Date().addingTimeInterval(-1800)
        event.createdAt = Date()
        event.updatedAt = Date()
        event.addToContacts(contact1)
        event.addToContacts(contact2)
        event.group = group
        
        // サンプル通信履歴を作成
        let communication = CommunicationEntity(context: viewContext)
        communication.id = UUID()
        communication.type = "Call"
        communication.content = "プロジェクトについての打ち合わせ"
        communication.date = Date().addingTimeInterval(-86400)
        communication.contact = contact1
        communication.createdAt = Date()
        communication.updatedAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return controller
    }()
    
    // NSPersistentContainerの作成
    let container: NSPersistentContainer
    
    // イニシャライザ
    init(inMemory: Bool = false) {
        // 正しいデータモデル名を指定
        container = NSPersistentContainer(name: "RelationshipManager")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }
        
        // マージポリシーの設定
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // 変更を保存するユーティリティ関数
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
