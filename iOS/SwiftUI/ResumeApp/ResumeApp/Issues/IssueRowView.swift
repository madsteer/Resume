//
//  IssueRowView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/3/23.
//

import SwiftUI

/// Provide the SwiftUI components for each row of the listed issues
struct IssueRowView: View {
    @EnvironmentObject var dataController: DataController
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationLink(value: viewModel.issue) {
            HStack {
                Image(systemName: "exclamationmark.circle")
                    .imageScale(.large)
                    .opacity(viewModel.iconOpacity)
                    .accessibilityIdentifier(viewModel.iconIdentifier)

                VStack(alignment: .leading) {
                    Text(viewModel.issue.issueTitle)
                        .font(.headline)
                        .lineLimit(1)

                    Text(viewModel.issue.issueTagsList)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text(viewModel.creationDate)
                        .accessibilityLabel(viewModel.accessibilityLabel)
                        .font(.subheadline)

                    if viewModel.issue.completed {
                        Text("CLOSED")
                            .font(.body.smallCaps())
                    }
                }
                .foregroundColor(.secondary)
            }
        }
        .accessibilityHint(viewModel.accessibilityHint)
        // just for UI testing
        .accessibilityIdentifier(viewModel.issue.issueTitle)
    }

    init(issue: Issue) {
        let viewModel = ViewModel(issue: issue)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
}

#Preview {
    NavigationView {
        IssueRowView(issue: .example)
    }
}
