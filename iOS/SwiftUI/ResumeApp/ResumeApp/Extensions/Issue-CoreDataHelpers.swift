//
//  Issue-CoreDataHelpers.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/1/23.
//

import Foundation

extension Issue {
    /// Non-optional representation of an issue's title
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    /// Non-optional representation of an issue's content
    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    /// Non-optional representation of an issue's creation date
    var issueCreationDate: Date {
        creationDate ?? .now
    }

    /// Non-optional representation of an issue's modification date
    var issueModificationDate: Date {
        modificationDate ?? .now
    }

    /// A sorted, non-optional representation of an issue's tags
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }

    /// A sorted, non-optional representation of an issue's tags as a string of text
    var issueTagsList: String {
        let localizedNoTags = NSLocalizedString("No tags", comment: "This user has not created any tags yet.")
        guard let tags else { return localizedNoTags }

        if tags.count == 0 {
            return localizedNoTags
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }

    /// Non-optional representation of an issue's status
    var issueStatus: String {
        if completed {
            return NSLocalizedString("Closed", comment: "This issue has been resolved.")
        } else {
            return NSLocalizedString("Open", comment: "This issue is currently not resolved.")
        }
    }

    /// Non-optional representation of an issue's reminder time
    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }

    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.creationDate = .now

        return issue
    }
}

extension Issue: Comparable {
    /// Compare two issues for equality based on either their title or their creation date
    /// - Parameters:
    ///   - lhs: First issue to be compared
    ///   - rhs: Second issue to be compared
    /// - Returns: A boolean stating if the left issue is less than the right issue
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreationDate < rhs.issueCreationDate
        }

        return left < right
    }
}
