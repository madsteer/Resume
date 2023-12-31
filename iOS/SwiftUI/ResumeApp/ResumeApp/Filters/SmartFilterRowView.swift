//
//  SmartFilterRowView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/10/23.
//

import SwiftUI

/// Provide the SwiftUI components for the SidebarVIew's smart filter rows
struct SmartFilterRowView: View {
    var filter: Filter

    var body: some View {
        NavigationLink(value: filter) {
            Label(LocalizedStringKey(filter.name), systemImage: filter.icon)
        }
    }
}

var smartFilters: [Filter] = [.all, .recent]
#Preview {
    List {
        ForEach(smartFilters) { _ in
            SmartFilterRowView(filter: .all)
        }
    }
}
