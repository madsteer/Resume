//
//  DataController.swift
//  ResumeApp
//
//  Created by Cory Steers on 10/29/23.
//

import CoreData
import SwiftUI

/// Different ways to sort issues for viewing
enum SortType: String {
    case dateCreated = "creationDate"
    case dateModified = "modificationDate"
}

/// Various states during the lifecycle of an issue
enum Status {
    case all, open, closed
}

/// An environment singleton that manages the application's Core Data stack, including handling saving,
/// counting fetch requests, tracking orders, and dealing with sample data
class DataController: ObservableObject {

    /// The single CloudKit container used to store all our data
    let container: NSPersistentCloudKitContainer

    /// Delegate to allow us to add data to Spotlight
    var spotlightDelegate: NSCoreDataCoreSpotlightDelegate?

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?

    @Published var filterText = ""
    @Published var filterTokens = [Tag]()

    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true

    private var saveTask: Task<Void, Error>?

    // since DataController is a singleton (see static model below) be careful using
    // this preview var in unit tests
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    // provide a list of existing tokens the user might want to filter issues by
    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else { return [] }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }

    // Never ran into this in actual code execution, but in unit testing kept getting errors
    // until I created this NSManagedObjectModel here and vvvvvvvvvvvvv
    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    /// Initializes a data controller, either in memory (for testing) or on permanent
    /// storage (for regular application use).
    ///
    /// Defaults to permanent storage
    /// - Parameter inMemory: A flag that tells whether to store data in temporary memory or not
    init(inMemory: Bool = false) {
        // ^^^^^^^^^ used the managedObjectModel here in container creation
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        // for testing and previewing purposes we write our data to /dev/null
        // so our database is destroyed after the app finishes running
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true // for cloudkit
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        // make sure to watch iCloud for all changes to be sure we keep our local
        // UI in sync when a remote change happens
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey) // announce when changes are happening

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged)

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                fatalError("Fatal error loading data store: \(error.localizedDescription)")
            }

            // set up code to track changes to issues in Spotlight
            if let description = self?.container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

                if let coordinator = self?.container.persistentStoreCoordinator {
                    self?.spotlightDelegate = NSCoreDataCoreSpotlightDelegate(forStoreWith: description,
                                                                              coordinator: coordinator)

                    self?.spotlightDelegate?.startSpotlightIndexing()
                }
            }

            #if DEBUG
            if CommandLine.arguments.contains("enable-testing") {
                self?.deleteAll()
                UIView.setAnimationsEnabled(false) // speed up UI Testing
            }
            #endif
        }
    }

    /// Helper function for notifying SwiftUI of impending changes
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    /// Helper function to generate fake data for testing
    func createSampleData() {
        let viewContext = container.viewContext

        for tagCounter in 1...5 {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = "Tag \(tagCounter)"

            for issueCounter in 1...10 {
                let issue = Issue(context: viewContext)
                issue.title = "Issue \(tagCounter)-\(issueCounter)"
                issue.content = "Description goes here"
                issue.creationDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }

        try? viewContext.save()
    }

    /// Persists data to Core Data context if there are changes.  This silently
    /// ignores any errors caused by saving, but this should be fine because
    /// all our attributes are optional.
    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }

        saveTask?.cancel()
    }

    /// For efficiency reasons, queue a change in the near future so we don't "over save"
    func queueSave() {
//        if we have recently queued a save, cancel that one before we create a new one
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    /// Delete an issue from the database
    /// - Parameter object: An Issue or Tag to be deleted
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    /// Performs the actual heavy lifting of deleting multiple objects
    /// - Parameter fetchRequest: A fetch request result containing the items to delete
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        // ⚠️ when performing a batch delete we need to make sure we read the
        // result back and merge the changes from that result back into our live view
        // context so the two stay in sync
        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    /// Special delete function to clean out all date before adding more sample data back
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)

        save()
    }

    /// Find all tags not assigned to this issue
    /// - Parameter issue: The issue for which we are looking for tags not assigned to
    /// - Returns: An array of tags not assigned to the issue passed in
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }

    /// Runs a fetch request with various predicates that filter the user's issues based on
    /// tag, title, and content text, search tokens, priority, and completion status.
    /// - Returns: An array of all matching items
    func issuesForSelectedFilter() -> [Issue] {
        let filter = selectedFilter ?? .all
        var predicates = [NSPredicate]()

        if let tag = filter.tag {
            let tagPredicate = NSPredicate(format: "tags CONTAINS %@", tag)
            predicates.append(tagPredicate)
        } else {
            let datePredicate = NSPredicate(
                format: "modificationDate > %@",
                filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)
        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", trimmedFilterText)
            let contentPredicate = NSPredicate(format: "content CONTAINS[c] %@", trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }

//        if filterTokens.isEmpty == false { // OR - any tags
//            let tokenPredicate = NSPredicate(format: "ANY tags IN %@", filterTokens)
//            predicates.append(tokenPredicate)
//        }

        if filterTokens.isEmpty == false { // AND - all tags
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(format: "tags CONTAINS %@", filterToken)
                predicates.append(tokenPredicate)
            }
        }

        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(format: "priority = %d", filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(format: "completed = %@", NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]
        let allIssues = (try? container.viewContext.fetch(request)) ?? []

        return allIssues
    }

    /// Builds a new Tag with stock presets for the name
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")

        save()
    }

    /// Builds a new Issue with stock presets for the title, priority, and creation date
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
        issue.creationDate = .now
        issue.priority = 1

        // if we are browsing a user created tag, immediately add this new issue to the tag
        // otherwise it won't appear in the list of issues they see.
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }

        save()

        selectedIssue = issue
    }

    /// Method to let Core Data (sqlite) count how many items fit the search criteria
    /// so we don't have to spend time and resources counting them in code
    /// - Parameter fetchRequest: What are we looking for?
    /// - Returns: An integer count of the number of items we're looking for in our database
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }

    /// Determine if the user has earned a particular award yet or not.
    /// - Parameter award: The award in question
    /// - Returns: A Boolean answering if has been earned yet or not
    func hasEarned(award: Award) -> Bool {
        switch award.criterion {
        case "issues":
            // return true if they added a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "closed":
            // return true if they closed a certain number of issues
            let fetchRequest = Issue.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "completed = true")
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        case "tags":
            // return true if they created a certain number of tags
            let fetchRequest = Tag.fetchRequest()
            let awardCount = count(for: fetchRequest)
            return awardCount >= award.value

        default:
            // an unknown award criterion; this should never be allowed
            // fatalError("Unknown award criterion: \(award.criterion)")
            return false
        }
    }
    
    /// Find an issue from a unique identifier so we can navigate to an issue from a Spotlight search
    /// - Parameter uniqueIdentifier: the unique identifier of the issue we want to return
    /// - Returns: the issue represented by the unique identifier passed in
    func issue(with uniqueIdentifier: String) -> Issue? {
        guard let url = URL(string: uniqueIdentifier) else { return nil }

        guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
            return nil
        }

        return try? container.viewContext.existingObject(with: id) as? Issue
    }
}
