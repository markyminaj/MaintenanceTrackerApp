//
//  Issue-CoreDataHelpers.swift
//
//  Created by Mark Martin on 6/7/23.
//

import Foundation

extension Issue {
    var issueTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }
    

    var issueContent: String {
        get { content ?? "" }
        set { content = newValue }
    }

    var issueCreatedDate: Date {
        createdDate ?? .now
    }
    
    var issueReminderTime: Date {
        get { reminderTime ?? .now }
        set { reminderTime = newValue }
    }

    var issueModificationDate: Date {
        modificationDate ?? .now
    }
    
    var issueFormattedCreatedDate: String {
        issueCreatedDate.formatted(date: .numeric, time: .omitted)
    }
    
    static var example: Issue {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let issue = Issue(context: viewContext)
        issue.title = "Example Issue"
        issue.content = "This is an example issue."
        issue.priority = 2
        issue.createdDate = .now
        return issue
    }
    
    var issueTags: [Tag] {
        let result = tags?.allObjects as? [Tag] ?? []
        return result.sorted()
    }
    
    var issueUpdates: [MaintenanceUpdate] {
        get {
            let history = updates?.allObjects as? [MaintenanceUpdate] ?? []
            return history.sorted()
        }
        set {
            
        }
    }
    
    var issueStatus: String {
        if completed {
            return "Closed"
        } else {
            return "Open"
        }
    }
    
    var issueTagsList: String {
        guard let tags else { return "No tags" }

        if tags.count == 0 {
            return "No tags"
        } else {
            return issueTags.map(\.tagName).formatted()
        }
    }
    
    var issueHistoryList: String {
        if updates?.count == 0 {
            return "No Updates"
        } else {
            return issueUpdates.map(\.updateContent).formatted()
        }
    }
}

extension Issue: Comparable {
    public static func <(lhs: Issue, rhs: Issue) -> Bool {
        let left = lhs.issueTitle.localizedLowercase
        let right = rhs.issueTitle.localizedLowercase

        if left == right {
            return lhs.issueCreatedDate < rhs.issueCreatedDate
        } else {
            return left < right
        }
    }
}
