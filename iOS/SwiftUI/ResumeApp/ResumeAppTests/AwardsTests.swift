//
//  AwardsTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/14/23.
//

import CoreData
import XCTest
@testable import ResumeApp

final class AwardsTests: BaseTestCase {
    let awards = Award.allAwards

    func testAwardIDMatchesName() throws {
        for award in awards {
            XCTAssertEqual(award.id, award.name, "Awards ID should always match it's name")
        }
    }

    func testNewUserHasNoUnlockedAwards() throws {
        for award in awards {
            XCTAssertFalse(dataController.hasEarned(award: award),
                           "If there are no issues or tags how can \(award.name) be earned?")
        }
    }

    func testCreatingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "issues" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Adding \(value) issues should unlock \(count + 1) awards")
            dataController.deleteAll()
        }
    }

    func testClosingIssuesUnlocksAwards() {
        let values = [1, 10, 20, 50, 100, 250, 500, 1000]

        for (count, value) in values.enumerated() {
            var issues = [Issue]()

            for _ in 0..<value {
                let issue = Issue(context: managedObjectContext)
                issue.completed = true
                issues.append(issue)
            }

            let matches = awards.filter { award in
                award.criterion == "closed" && dataController.hasEarned(award: award)
            }

            XCTAssertEqual(matches.count, count + 1, "Completing \(value) issues should unlock \(count + 1) awards")
            dataController.deleteAll()
        }
    }
}
