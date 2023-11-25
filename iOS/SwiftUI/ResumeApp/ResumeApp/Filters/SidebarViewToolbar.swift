//
//  SidebarViewToolbar.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/10/23.
//

import SwiftUI

/// Provide the SwiftUI components for the SidebarView's toolbar
struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingAwards =  false
    @State private var showingStore = false

    var body: some View {
        Button {
            if dataController.newTag() == false {
                showingStore = true
            }
        } label: {
            Label("Add tag", systemImage: "plus")
        }
        .sheet(isPresented: $showingStore, content: StoreView.init)

        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)

        #if DEBUG
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
        #endif
    }
}

#Preview {
    NavigationView {
        Text("")
            .toolbar {
                SidebarViewToolbar()
                    .environmentObject(DataController(inMemory: true))
            }
    }
}
