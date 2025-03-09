import SwiftUI

@main
struct RelationshipManagerApp: App {
    // 永続化コントローラーの取得
    let persistenceController = PersistenceController.shared
    
    // アプリを終了するときに通知を観察する
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .inactive {
                // アプリがバックグラウンドに移動したときにデータを保存
                persistenceController.save()
            }
        }
    }
}
