//
//  PerformanceTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/16/23.
//

import XCTest
@testable import ResumeApp

/// Performance Test to ensure loading awards data and checking it hasn't slowed down
final class PerformanceTests: BaseTestCase {
    func testAwardCalculationPerformance() {
        for _ in 1...100 {
            dataController.createSampleData()
        }

        let awards = Array(repeating: Award.allAwards, count: 25).joined()
        XCTAssertEqual(awards.count, 500,
                       "This checks the awards count is constant.  Change this if you add awards.")

        measure {
            _ = awards.filter(dataController.hasEarned)
        }
    }
}
