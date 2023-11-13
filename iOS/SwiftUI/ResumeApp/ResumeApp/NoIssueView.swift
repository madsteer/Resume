//
//  NoIssueView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/3/23.
//

import SwiftUI

/// A simple view to fill the page when no issue is selected and provide a button to create one
struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New Issue", action: dataController.newIssue)
    }
}

#Preview {
    NoIssueView()
}
