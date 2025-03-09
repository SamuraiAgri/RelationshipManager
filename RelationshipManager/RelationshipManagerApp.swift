//
//  RelationshipManagerApp.swift
//  RelationshipManager
//
//  Created by iwamoto rinka on 2025/03/09.
//

import SwiftUI

@main
struct RelationshipManagerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
