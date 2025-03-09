import CoreData

struct PersistenceController {
    // シングルトンインスタンス
    static let shared = PersistenceController()
    
    // プレビュー用のインスタンス
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // プレビュー用にサンプルデータを作成
        let viewContext = controller.container.viewContext
        
        // サンプル連絡先
        let contact1 = ContactEntity(context: viewContext)
        contact1.id = UUID()
        contact1.firstName = "山田"
        contact1.lastName = "太郎"
        contact1.phoneNumber = "090-1234-5678"
        contact1.email = "yamada.taro@example.com"
        contact1.category = "Business"
        contact1.createdAt = Date()
        contact1.updatedAt = Date()
        
        let contact2 = ContactEntity(context: viewContext)
        contact2.id = UUID()
        contact2.firstName = "佐藤"
        contact2.lastName = "花子"
        contact2.phoneNumber = "080-9876-5432"
        contact2.email = "sato.hanako@example.com"
        contact2.category = "Private"
        contact2.createdAt = Date()
        contact2.updatedAt = Date()
        
        // サンプルコミュニケーション
        let communication1 = CommunicationEntity(context: viewContext)
        communication1.id = UUID()
        communication1.type = "Call"
        communication1.content = "プロジェクトについての相談"
        communication1.date = Date()
        communication1.contact = contact1
        communication1.createdAt = Date()
        communication1.updatedAt = Date()
        
        // サンプルイベント
        let event1 = EventEntity(context: viewContext)
        event1.id = UUID()
        event1.title = "ミーティング"
        event1.details = "第3四半期のレビュー"
        event1.startDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
        event1.isAllDay = false
        event1.reminder = true
        event1.reminderDate = Calendar.current.date(byAdding: .hour, value: -1, to: event1.startDate!)
        event1.addToContacts(contact1)
        event1.createdAt = Date()
        event1.updatedAt = Date()
        
        // サンプルグループ
        let group1 = GroupEntity(context: viewContext)
        group1.id = UUID()
        group1.name = "プロジェクトA"
        group1.category = "Business"
        group1.addToContacts(contact1)
        group1.createdAt = Date()
        group1.updatedAt = Date()
        
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
        container = NSPersistentContainer(name: "RelationshipManager")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // エラーハンドリング
                /*
                 エラーの理由:
                 * Coreデータストアが見つからない場合
                 * スキーマの互換性がない場合
                 * その他のエラー
                 
                 エラーが発生した場合の対応方法:
                 * 開発中のエラー: アプリを終了してデータを再作成する
                 * 実環境: 移行処理などの対策を行う
                 */
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
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
