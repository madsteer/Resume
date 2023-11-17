//
//  IssueExtensionTests.swift
//  ResumeAppTests
//
//  Created by Cory Steers on 11/15/23.
//

import CoreData
import XCTest
@testable import ResumeApp

final class ExtensionTests: BaseTestCase {
    func testIssueTitleUnwrap() {
        let issue = Issue(context: managedObjectContext)

        XCTAssertNil(issue.title, "unset title should be nil")
        XCTAssertEqual(issue.issueTitle, "", "even if title isn't set, issueTitle should not be nil")

        issue.title = "Example Issue"
        XCTAssertEqual(issue.issueTitle, "Example Issue", "Changing title should also change issueTitle")

        issue.issueTitle = "Updated Issue"
        XCTAssertEqual(issue.title, "Updated Issue", "Changing issueTitle should also change title")
    }

    func testIssueContentUnwrap() {
        let issue = Issue(context: managedObjectContext)

        XCTAssertNil(issue.content, "unset content should be nil")
        XCTAssertEqual(issue.issueContent, "", "even if content isn't set, issueContent should not be nil")

        issue.content = "Example Issue"
        XCTAssertEqual(issue.issueContent, "Example Issue", "Changing content should also change issueContent")

        issue.issueContent = "Updated Issue"
        XCTAssertEqual(issue.content, "Updated Issue", "Changing issueContent should also change content")
    }

    // sometimes this fails
//    func testIssueCreationDateUnwrap() {
//        let issue = Issue(context: managedObjectContext)
//
//        XCTAssertNil(issue.creationDate, "unset creationDate should be nil")
//        XCTAssertEqual(issue.issueCreationDate, .now, 
//                       "even if creationDate isn't set, issueCreationDate should be set")
//    }

    func testIssueTagsUnwrap() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        XCTAssertEqual(issue.issueTags.count, 0, "A new issue should have not tags.")

        issue.addToTags(tag)
        XCTAssertEqual(issue.issueTags.count, 1,
                       "Adding 1 tag to an issue should result in issueTags having a count of 1")
    }

    func testIssueTagsList() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        tag.name = "My Tag"
        issue.addToTags(tag)

        XCTAssertEqual(issue.issueTagsList, "My Tag",
                       "An Issue with 1 tag should have an issueTagList matching the tag")
    }

    func testIssueSortingIsStable() {
        let issue1 = Issue(context: managedObjectContext)
        issue1.title = "B Issue"
        issue1.creationDate = .now

        let issue2 = Issue(context: managedObjectContext)
        issue2.title = "B Issue"
        issue2.creationDate = .now.addingTimeInterval(1)

        let issue3 = Issue(context: managedObjectContext)
        issue3.title = "A Issue"
        issue3.creationDate = .now.addingTimeInterval(100)

        let allIssues = [issue1, issue2, issue3]
        let sorted = allIssues.sorted()

        XCTAssertEqual([issue3, issue1, issue2], sorted,
                       "Sorting issue arrays should use the name, then creation date.")
    }

    func testTagNameUnwrap() {
        let tag = Tag(context: managedObjectContext)

        XCTAssertNil(tag.name, "unset name should be nil")
        XCTAssertEqual(tag.tagName, "", "even if name isn't set, tagName should not be nil")

        tag.name = "Example Tag"
        XCTAssertEqual(tag.tagName, "Example Tag", "Changing name should also change tagName")
    }

    func testTagIDUnwrap() {
        let tag = Tag(context: managedObjectContext)

        XCTAssertNil(tag.id, "unset id should be nil")
        XCTAssertNotNil(tag.tagID, "even if id isn't set, tagID should not be nil")

        tag.id = UUID()
        XCTAssertEqual(tag.tagID, tag.id, "Changing the id should also change tagID")
    }

    func testActiveIssuesWorks() {
        let tag = Tag(context: managedObjectContext)
        let issue = Issue(context: managedObjectContext)

        XCTAssertEqual(tag.tagActiveIssues, [], "If not tags on an issue then should be no active issues")

        issue.addToTags(tag)
        XCTAssertEqual(tag.tagActiveIssues, [issue], "cuz")

        issue.completed = true
        XCTAssertEqual(tag.tagActiveIssues, [], "tagActiveIssues should not contain completed issues")
    }

    func testTagSortingIsStable() {
        let lowerUUID = UUID(uuidString: "00000000-6998-443E-9AB1-F2922ECB881E")
        let upperUUID = UUID(uuidString: "FFFFFFFF-6998-443E-9AB1-F2922ECB881E")

        let tag1 = Tag(context: managedObjectContext)
        tag1.name = "B tag"
        tag1.id = lowerUUID

        let tag2 = Tag(context: managedObjectContext)
        tag2.name = "B tag"
        tag2.id = upperUUID

        let tag3 = Tag(context: managedObjectContext)
        tag3.name = "A tag"
        tag3.id = UUID()

        let allTags = [tag1, tag2, tag3]
        let sorted = allTags.sorted()

        XCTAssertEqual([tag3, tag1, tag2], sorted, "Sorting tag arrays should use the name, then UUID value")
    }

    func testBundleDecodingAwards() {
        let awards = Bundle.main.decode("Awards.json", as: [Award].self)
        XCTAssertFalse(awards.isEmpty, "Awards.json should decode to an array of awards.")
    }

    func testDecodingString() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableString.json", as: String.self)
        XCTAssertEqual(data, "Never ask a starfish for directions.", "The string must match DecodableString.json")
    }

    func testDecodingDictionary() {
        let bundle = Bundle(for: ExtensionTests.self)
        let data = bundle.decode("DecodableDictionary.json", as: [String: Int].self)
        XCTAssertEqual(data.count, 3, "There should be 3 items decoded from DecodableDictionary.json")
        XCTAssertEqual(data, [ "One": 1, "Two": 2, "Three": 3], "The dictionary must match DecodableDictionary.json")
    }
}
