//
//  ResumeAppApp.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/28/23.
//

import CoreSpotlight
import SwiftUI

@main
/// Application to show off my SwiftUI skills
struct ResumeAppApp: App {
    @StateObject var dataController: DataController
    @StateObject var unlockManager: UnlockManager
    @Environment(\.scenePhase) var scenePhase

    init() {
        let dataController = DataController()
        let unlockManager = UnlockManager(dataController: dataController)

        _dataController = StateObject(wrappedValue: dataController)
        _unlockManager = StateObject(wrappedValue: unlockManager)
    }

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(datacontroller: dataController)
            } content: {
                ContentView(dataController: dataController)
                    .onAppear(perform: dataController.appLaunched)
            } detail: {
                DetailView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
            .environmentObject(dataController)
            .environmentObject(unlockManager)
            .onChange(of: scenePhase) { phase in
                if phase != .active {
                    dataController.save()
                }
            }
            .onContinueUserActivity(CSSearchableItemActionType, perform: loadSpotlightItem)
        }
    }

    /// This method will be called when we're launched from something found in Spotlight
    /// - Parameter userActivity: The input that spotlight will give us when we're called
    func loadSpotlightItem(_ userActivity: NSUserActivity) {
        if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
            dataController.selectedIssue = dataController.issue(with: uniqueIdentifier)
            dataController.selectedFilter = .all
        }
    }
}
