//
//  DetailView.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/31/23.
//

import SwiftUI

/// Provide the SwiftUI components for the sidebar view's details or if no issue is selected a view for no issue detail
struct DetailView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            if let issue = dataController.selectedIssue {
                IssueView(issue: issue)
            } else {
                NoIssueView()
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailView()
}
