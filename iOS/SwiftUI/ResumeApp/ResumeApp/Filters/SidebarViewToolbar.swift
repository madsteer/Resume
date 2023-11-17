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

    var body: some View {
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }
        .sheet(isPresented: $showingAwards, content: AwardsView.init)

        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }

        #if DEBUG
        Button {
            dataController.newTag()
        } label: {
            Label("Add tag", systemImage: "plus")
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
