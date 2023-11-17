//
//  ContentView.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/28/23.
//

import SwiftUI

/// Provide the SwiftUI components for the SidebarVIew's filter content
struct ContentView: View {
    @StateObject var viewModel: ViewModel

    var body: some View {
        List(selection: $viewModel.dataController.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $viewModel.dataController.filterText,
                    tokens: $viewModel.dataController.filterTokens,
                    suggestedTokens: .constant(viewModel.dataController.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar { ContentViewToolbar() }
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    ContentView(dataController: .preview)
}
