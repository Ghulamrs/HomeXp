//
//  HomeXpApp.swift
//  HomeXp
//
//  Created by Home on 3/28/21.
//

import SwiftUI

@main
struct HomeXpApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
