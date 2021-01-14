//
//  Simply_Good_HabitsApp.swift
//  Shared
//
//  Created by Paul Krakow on 12/28/20.
//

import SwiftUI
import CoreData

@main
struct Simply_Good_HabitsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
