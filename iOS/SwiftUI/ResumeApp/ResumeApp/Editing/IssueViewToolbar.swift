//
//  IssueViewToolbar.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/10/23.
//

// import CoreHaptics // Don't need for simple success
import SwiftUI

/// Provide the view for the Issue view's toolbar menu
struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue

//    @State private var engine = try? CHHapticEngine() // Don't need for simple success

    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = issue.issueTitle
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button {
                toggleCompleted()
            } label: {
                Label(openCloseButtonText, systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
//            .sensoryFeedback(trigger: issue.completed) { _, newValue in // requires iOS 17
//                if newValue {
//                    .success
//                } else {
//                    nil
//                }
//            }

            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }

    func toggleCompleted() {
        issue.completed.toggle()
        dataController.save()

        if issue.completed {
            UINotificationFeedbackGenerator().notificationOccurred(.success)

//            do { // really fancy haptic I'm not going to use
//                try engine?.start()
//
//                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
//                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
//
//                let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
//                let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
//
//                let parameter1 = CHHapticParameterCurve(parameterID: .hapticIntensityControl,
//                                                        controlPoints: [start, end], relativeTime: 0)
//
//                let event1 = CHHapticEvent(eventType: .hapticTransient,
//                                           parameters: [intensity, sharpness], relativeTime: 0)
//                let event2 = CHHapticEvent(eventType: .hapticContinuous,
//                                           parameters: [sharpness, intensity], relativeTime: 0.125, duration: 1)
//
//                let pattern = try CHHapticPattern(events: [event1, event2], parameterCurves: [parameter1])
//                let player = try engine?.makePlayer(with: pattern)
//                try player?.start(atTime: 0)
//            } catch {
//                // didn't work, but that's OK
//            }
        }
    }
}

#Preview {
    NavigationView {
            Text("")
            .toolbar {
                IssueViewToolbar(issue: Issue.example)
                    .environmentObject(DataController(inMemory: true))
        }
    }
}
