// Persistence.swift
import CoreData

struct PersistenceController {
    // シングルトンインスタンス
    static let shared = PersistenceController()
    
    // プレビュー用のインスタンス
    @MainActor
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        // プレビュー用にサンプルデータを作成
        let viewContext = controller.container.viewContext
        
        // 先にデータモデルを読み込み
        try? viewContext.save()
        
        // テンプレートアイテム作成（古いコード互換用）
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
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
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
