//
//  ResumeAppTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/13/23.
//

import CoreData
import XCTest
@testable import ResumeApp

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
}
