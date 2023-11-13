//
//  IssueView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/3/23.
//

import SwiftUI

/// Provide components for displaying the actual issue in the detail view
struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading) {
                    TextField("Title", text: $issue.issueTitle, prompt: Text("Enter the issue title here"))
                        .font(.title)

                    // swiftlint:disable:next line_length
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))") // **Modified** is Markdown bold
                        .foregroundStyle(.secondary)

                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }

                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }

               TagsMenuView(issue: issue)
            }

            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)

                    TextField("Description",
                              text: $issue.issueContent,
                              prompt: Text("Enter the issue description here"),
                              axis: .vertical)
                }
            }
        }
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
}

#Preview {
    IssueView(issue: .example)
}