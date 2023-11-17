//
//  IssueRowViewModel.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/17/23.
//

import Foundation

extension IssueRowView {
    @dynamicMemberLookup
    class ViewModel: ObservableObject {
        let issue: Issue

        var iconOpacity: Double {
            issue.priority == 2 ? 1 : 0
        }

        var iconIdentifier: String {
            issue.priority == 2 ? "\(issue.issueTitle) High Priority" : ""
        }

        var accessibilityLabel: String {
            issue.issueCreationDate.formatted(date: .abbreviated, time: .omitted)
        }

        var accessibilityHint: String {
            issue.priority == 2 ? "High priority" : ""
        }

        /// A readable text version of an issue's creation date
        var creationDate: String {
            issue.issueCreationDate.formatted(date: .numeric, time: .omitted)
        }

        init(issue: Issue) {
            self.issue = issue
        }

        subscript<Value>(dynamicMember keyPath: KeyPath<Issue, Value>) -> Value {
            issue[keyPath: keyPath]
        }
    }
}
