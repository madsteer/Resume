//
//  TagTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/14/23.
//

import CoreData
import XCTest
@testable import ResumeApp

final class TagTests: BaseTestCase {
    func testCreatingTagsAndIssues() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<targetCount {
                let issue = Issue(context: managedObjectContext)
                tag.addToIssues(issue)
            }
        }

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), targetCount,
                       "There should be \(targetCount) tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), targetCount * targetCount,
                       "There should be \(targetCount * targetCount) issues.")
    }

    func testDeletingTagDoesNotDeleteIssues() throws {
        dataController.createSampleData()

        let request = NSFetchRequest<Tag>(entityName: "Tag")
        let tags = try managedObjectContext.fetch(request)

        XCTAssertEqual(tags.count, 5, "Sample data should have 5 tags")

        dataController.delete(tags[0])

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 4,
                       "After deleting 1 there should still be 4 tags left")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50,
                       "Deleting a tag should not have deleted any issues")
    }
}
