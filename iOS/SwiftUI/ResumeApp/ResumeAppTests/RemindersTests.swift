//
//  RemindersTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/18/23.
//

import CoreData
import XCTest
@testable import ResumeApp

final class RemindersTests: BaseTestCase {
    func testAddingAnIssue() async {
        let issue = Issue.example

        let result = await dataController.addReminder(for: issue)
        XCTAssertTrue(result, "I should be able to add a reminder for an issue")
    }

    func testRemovingAllIssues() async {
        let issue = Issue.example

        XCTAssertNoThrow(dataController.removeReminders(for: issue),
                         "Removing a reminder for an issue should not throw an error.")
    }
}
