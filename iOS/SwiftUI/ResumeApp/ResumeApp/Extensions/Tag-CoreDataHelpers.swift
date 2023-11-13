//
//  Tag-CoreDataHelpers.swift
//  ResumeApp
//
//  Created by Cory Steers on 11/1/23.
//

import Foundation

extension Tag {
    /// Non-optional representation of a tag's ID
    var tagID: UUID {
        id ?? UUID()
    }

    /// Non-optional representation of a tag's name
    var tagName: String {
        name ?? ""
    }

    /// An array of issues that are open
    var tagActiveIssues: [Issue] {
        let result = issues?.allObjects as? [Issue] ?? []
        return result.filter { $0.completed == false }
    }

    static var example: Tag {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let tag = Tag(context: viewContext)
        tag.id = UUID()
        tag.name = "Example Tag"

        return tag
    }
}

extension Tag: Comparable {
    /// Compare two tags for equality based on either their name or their creation date
    /// - Parameters:
    ///   - lhs: First tag to be compared
    ///   - rhs: Second tag to be compared
    /// - Returns: A boolean stating if the left tag is less than the right tag
    public static func <(lhs: Tag, rhs: Tag) -> Bool {
        let left = lhs.tagName.localizedLowercase
        let right = rhs.tagName.localizedLowercase

        if left == right {
            return lhs.tagID.uuidString < rhs.tagID.uuidString
        }

        return left < right
    }
}
