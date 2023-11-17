//
//  SidebarView.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/31/23.
//

import SwiftUI

/// Provide view components for the navigation split view's sidebar
struct SidebarView: View {
    @StateObject private var viewModel: ViewModel
    let smartFilters: [Filter] = [.all, .recent]

    init(datacontroller: DataController) {
        let viewModel = ViewModel(dataController: datacontroller)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(selection: $viewModel.dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilters, content: SmartFilterRowView.init)
            }

            Section("Tags") {
                ForEach(viewModel.tagFilters) { filter in
                    UserFilterRowView(filter: filter, rename: viewModel.rename, delete: viewModel.delete)
                }
                .onDelete(perform: viewModel.delete)
            }
        }
        .toolbar(content: SidebarViewToolbar.init)
        .alert("Rename tag", isPresented: $viewModel.renamingTag) {
            Button {
                viewModel.completeRename()
            } label: {
                Text("OK")
            }

            Button("Cancel", role: .cancel) { }

            TextField("New name", text: $viewModel.tagName)
        }
        .navigationTitle("Filters")
    }
}

#Preview {
    SidebarView(datacontroller: .preview)
}
