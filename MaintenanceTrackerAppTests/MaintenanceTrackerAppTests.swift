//
//  MaintenanceTrackerAppTests.swift
//  MaintenanceTrackerAppTests
//
//  Created by Mark Martin on 6/28/23.
//

import CoreData
import XCTest
@testable import MaintenanceTrackerApp

class BaseTestCase: XCTestCase {
    var dataController: DataController!
    var managedObjectContext: NSManagedObjectContext!

    override func setUpWithError() throws {
        dataController = DataController(inMemory: true)
        managedObjectContext = dataController.container.viewContext
    }
    
    func testCreatingProjectsAndItems() {
        let targetCount = 10

        for _ in 0..<targetCount {
            let tag = Tag(context: managedObjectContext)

            for _ in 0..<targetCount {
                let issue = Issue(context: managedObjectContext)
                
            }
        }

        XCTAssertEqual(dataController.count(for: Tag.fetchRequest()), targetCount)
        XCTAssertEqual(dataController.count(for: Issue.fetchRequest()), targetCount * targetCount)
    }
    
    
}
