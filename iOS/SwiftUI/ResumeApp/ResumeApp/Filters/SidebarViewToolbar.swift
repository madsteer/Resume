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

    @Binding var showingAwards: Bool

    var body: some View {
        Button {
            showingAwards.toggle()
        } label: {
            Label("Show awards", systemImage: "rosette")
        }

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
                SidebarViewToolbar(showingAwards: .constant(true))
                    .environmentObject(DataController(inMemory: true))
            }
    }
}
