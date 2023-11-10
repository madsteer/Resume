//
//  UserFilterRowView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/10/23.
//

import SwiftUI

struct UserFilterRowView: View {
    var filter: Filter
    var rename: (Filter) -> Void
    var delete: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
                .badge(filter.activeIssuesCount)
                .contextMenu {
                    Button {
                        rename(filter)
                    } label: {
                        Label("Rename", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        delete(filter)
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .accessibilityElement()
                .accessibilityLabel(filter.name)
                .accessibilityHint("\(filter.activeIssuesCount) issues")
        }
    }
}

var allFilters: [Filter] = [.all]
var tagFilters: [Filter] {
    var taggedFilters = [Filter]()
    for (index, e) in allFilters.enumerated() {
        if index % 2 == 0 {
            let f = Filter(id: e.id, name: e.name, icon: e.icon, tag: .example)
            taggedFilters.append(f)
        }
    }
    return taggedFilters
}

#Preview {
    List {
        Section("Tags") {
            ForEach(tagFilters) { filter in
                UserFilterRowView(filter: filter, rename: { _ in }, delete: { _ in })
            }
        }
    }
}
