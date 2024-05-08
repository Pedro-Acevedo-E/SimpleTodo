//
//  SimpleTodoApp.swift
//  SimpleTodo
//
//  Created by Pedro Acevedo on 08/05/24.
//

import SwiftUI

@main
struct SimpleTodoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
