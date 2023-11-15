//
//  DevelopmentTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/14/23.
//

import CoreData
import XCTest
@testable import ResumeApp

final class DevelopmentDataTests: BaseTestCase {
    func testSampleDataCreationWorks() {
        dataController.createSampleData()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 5, "There should be 5 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 50, "There should be 50 sample issues.")
    }

    func testDeleteAllClearsEverything() {
        dataController.createSampleData()
        dataController.deleteAll()

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), 0, "There should be 0 sample tags.")
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), 00, "There should be 00 sample issues.")
    }

    func testMakeSureExampleTagHasNoIssues() {
        let tag = Tag.example

        XCTAssertEqual(tag.issues?.count, 0, "The Example tag should have 0 issues.")
    }

    func testMakeSureExampleIssueIsHighPriority() {
        let issue = Issue.example

        XCTAssertEqual(issue.priority, Int16(2), "The example issue should have a high priority.")
    }
}
