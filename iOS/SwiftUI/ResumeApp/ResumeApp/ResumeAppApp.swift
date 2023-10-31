//
//  ResumeAppApp.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/28/23.
//

import SwiftUI

@main
struct ResumeAppApp: App {
    @State var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView()
            } content: {
                ContentView()
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
        }
    }
}
