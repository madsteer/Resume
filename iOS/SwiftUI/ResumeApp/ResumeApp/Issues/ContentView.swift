//
//  ContentView.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/28/23.
//

import SwiftUI

/// Provide the SwiftUI components for the SidebarVIew's filter content
struct ContentView: View {
    @Environment(\.requestReview) var requestReview

    @StateObject var viewModel: ViewModel

    var body: some View {
        List(selection: $viewModel.selectedIssue) {
            ForEach(viewModel.dataController.issuesForSelectedFilter()) { issue in
                IssueRowView(issue: issue)
            }
            .onDelete(perform: viewModel.delete)
        }
        .navigationTitle("Issues")
        .searchable(text: $viewModel.filterText,
                    tokens: $viewModel.filterTokens,
                    suggestedTokens: .constant(viewModel.suggestedFilterTokens),
                    prompt: "Filter issues, or type # to add tags") { tag in
            Text(tag.tagName)
        }
        .toolbar { ContentViewToolbar() }
        .onAppear(perform: askForReview)
    }

    init(dataController: DataController) {
        let viewModel = ViewModel(dataController: dataController)
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    func askForReview() {
        if viewModel.shouldRequestReview {
            requestReview()
        }
    }
}

#Preview {
    ContentView(dataController: .preview)
}
