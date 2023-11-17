//
//  AwardsView.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/7/23.
//

import SwiftUI

/// Present all award information when the Awards toolbar button is pressed
struct AwardsView: View {
    @EnvironmentObject var dataController: DataController

    @State private var selectedAward = Award.example
    @State private var showingAwardDetails = false

    var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 100, maximum: 100))]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(Award.allAwards) { award in
                        Button {
                            selectedAward = award
                            showingAwardDetails = true
                        } label: {
                            Image(systemName: award.image)
                                .resizable()
                                .scaledToFit()
                                .padding()
                                .frame(width: 100, height: 100)
                                .foregroundStyle(color(for: award))
                        }
                        .accessibilityLabel(label(for: award))
                        .accessibilityHint(award.description)
                    }
                }
            }
            .navigationTitle("Awards")
        }
        .alert(awardTitle, isPresented: $showingAwardDetails) {
        } message: {
            Text(selectedAward.description)
        }
    }

    /// Determine if an award has been reached by this user or not and return a title accordingly
    var awardTitle: LocalizedStringKey {
        if dataController.hasEarned(award: selectedAward) {
            return "Unlocked: \(selectedAward.name)"
        } else {
            return "Locked"
        }
    }

    /// Determine if an award has been reached by the user or not and return a color accordingly
    /// - Parameter award: The award needing a color
    /// - Returns: a Color view representing whether the award has been reached or not
    func color(for award: Award) -> Color {
        dataController.hasEarned(award: award) ? Color(award.color) : .secondary.opacity(0.5)
    }

    /// Determine if an award has been reached by the user or not and return an accessibility label
    /// - Parameter award: The award needing a label
    /// - Returns: a localized string key to let the sight challenged user know if the award has been reached or not
    func label(for award: Award) -> LocalizedStringKey {
        "\(dataController.hasEarned(award: award) ? "Unlocked:" : "Locked:") \(award.name)"
    }
}

#Preview {
    AwardsView()
}
