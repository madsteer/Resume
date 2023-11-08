//
//  NoIssueView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/3/23.
//

import SwiftUI

struct NoIssueView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("No Issue Selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New Issue") {
            // make a new issue
        }
    }
}

#Preview {
    NoIssueView()
}
