//
//  DataController.swift
//
//  Created by Mark Martin on 6/7/23.
//

import CoreData
import CoreSpotlight
import UserNotifications

enum SortType: String {
    case dateCreated = "createdDate"
    case dateModified = "modificationDate"
}

enum Status {
    case all, open, closed
}

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer
    var searchableItems: [CSSearchableItem] = []
    

    @Published var selectedFilter: Filter? = Filter.all
    @Published var selectedIssue: Issue?
    @Published var filterTokens = [Tag]()
    @Published var filterText = ""
    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.dateCreated
    @Published var sortNewestFirst = true
    @Published var historyUpdates = [MaintenanceUpdate]()

    var suggestedFilterTokens: [Tag] {
        guard filterText.starts(with: "#") else {
            return []
        }

        let trimmedFilterText = String(filterText.dropFirst()).trimmingCharacters(in: .whitespaces)
        let request = Tag.fetchRequest()

        if trimmedFilterText.isEmpty == false {
            request.predicate = NSPredicate(format: "name CONTAINS[c] %@", trimmedFilterText)
        }

        return (try? container.viewContext.fetch(request).sorted()) ?? []
    }
    
    var sortedHistoryUpdates: [MaintenanceUpdate] {
        //return historyUpdates.sorted()
        return historyUpdates
    }
    
    
    private var saveTask: Task<Void, Error>?
    
    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()
    
    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
    

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged)
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }
    
    func missingTags(from issue: Issue) -> [Tag] {
        let request = Tag.fetchRequest()
        let allTags = (try? container.viewContext.fetch(request)) ?? []

        let allTagsSet = Set(allTags)
        let difference = allTagsSet.symmetricDifference(issue.issueTags)

        return difference.sorted()
    }
    
    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }
    
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
            let titlePredicate = NSPredicate(
                format: "title CONTAINS[c] %@",
                trimmedFilterText)
            let contentPredicate = NSPredicate(
                format: "content CONTAINS[c] %@",
                trimmedFilterText)
            let combinedPredicate = NSCompoundPredicate(
                orPredicateWithSubpredicates: [titlePredicate, contentPredicate])
            predicates.append(combinedPredicate)
        }
        
        if filterTokens.isEmpty == false {
            for filterToken in filterTokens {
                let tokenPredicate = NSPredicate(
                    format: "tags CONTAINS %@",
                    filterToken)
                predicates.append(tokenPredicate)
            }
        }
        
        if filterEnabled {
            if filterPriority >= 0 {
                let priorityFilter = NSPredicate(
                    format: "priority = %d",
                    filterPriority)
                predicates.append(priorityFilter)
            }

            if filterStatus != .all {
                let lookForClosed = filterStatus == .closed
                let statusFilter = NSPredicate(
                    format: "completed = %@",
                    NSNumber(value: lookForClosed))
                predicates.append(statusFilter)
            }
        }

        let request = Issue.fetchRequest()
        request.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [
            NSSortDescriptor(
            key: sortType.rawValue,
            ascending: sortNewestFirst)
        ]

        let allIssues = (try? container.viewContext.fetch(request)) ?? []
        return allIssues
    }
    
    func createSampleData() {
        let viewContext = container.viewContext
        let stations = ["FOH", "BOH", "Hennys", "Vents", "Toaster", "Merco"]

        for station in stations {
            let tag = Tag(context: viewContext)
            tag.id = UUID()
            tag.name = station
            
            for issueCounter in 1...3 {
                let issue = Issue(context: viewContext)
                issue.title = "\(station) issue-\(issueCounter)"
                issue.content = "description goes here"
                issue.createdDate = .now
                issue.completed = Bool.random()
                issue.priority = Int16.random(in: 0...2)
                tag.addToIssues(issue)
            }
        }
        
        try? viewContext.save()
    }
    
    func newIssue() {
        let issue = Issue(context: container.viewContext)
        issue.title = NSLocalizedString("New issue", comment: "Create a new issue")
        issue.createdDate = .now
        if let tag = selectedFilter?.tag {
            issue.addToTags(tag)
        }
        save()
        selectedIssue = issue
    }
    
    func newTag() {
        let tag = Tag(context: container.viewContext)
        tag.id = UUID()
        tag.name = NSLocalizedString("New tag", comment: "Create a new tag")
        save()
    }
    
    func save() {
        saveTask?.cancel()
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
            print("Issue saved")
        }
    }
    
    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }
    
    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }
    
    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [
                NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []
            ]
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: changes,
                into: [container.viewContext])
        }
    }
    
    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Tag.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = Issue.fetchRequest()
        delete(request2)
        save()
    }
    
    func update(with issue: Issue) {
        if issue.remindMe {
            self.addReminders(for: issue) { success in
                if success == false {
                    issue.reminderTime = nil
                    issue.remindMe = false
                    
                }
            }
        } else {
            issue.reminderTime = nil
            self.removeReminders(for: issue)
        }
        
        let issueID = issue.objectID.uriRepresentation().absoluteString
        let tagID = issue.issueTags.first?.objectID.uriRepresentation().absoluteString
        let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
        attributeSet.title = issue.issueTitle
        attributeSet.contentDescription = issue.issueContent
        
        
        let indexable = CSSearchableIndex.isIndexingAvailable()
        
        let searchableIssue = CSSearchableItem(
            uniqueIdentifier: issueID,
            domainIdentifier: tagID,
            attributeSet: attributeSet)
        
        searchableItems.append(searchableIssue)
        
        
        CSSearchableIndex.default().indexSearchableItems(searchableItems) { error in
            if let error = error {
                print("Failed to index searchable items: \(error.localizedDescription)")
            } else {
                
            }
        }
        save()
    }
    
    func addReminders(for issue: Issue, completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestNotifications { success in
                    if success {
                        self.placeReminders(for: issue, completion: completion)
                    } else {
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            case .authorized:
                self.placeReminders(for: issue, completion: completion)
            default:
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
            let id = issue.objectID.uriRepresentation().absoluteString
            center.removePendingNotificationRequests(withIdentifiers: [id])
    }

    private func requestNotifications(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

            center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                completion(granted)
            }
    }

    private func placeReminders(for issue: Issue, completion: @escaping (Bool) -> Void) {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.title = issue.issueTitle

        if let issueDetail = issue.content {
            content.subtitle = issueDetail
        }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: issue.reminderTime ?? Date())
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let id = issue.objectID.uriRepresentation().absoluteString
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if error == nil {
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
        }
    }
}
