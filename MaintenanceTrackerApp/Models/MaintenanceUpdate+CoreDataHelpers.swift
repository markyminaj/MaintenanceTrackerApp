//
//  MaintenanceUpdate+CoreDataHelpers.swift
//  MaintenanceTrackerApp
//
//  Created by Mark Martin on 7/10/23.
//

import Foundation

extension MaintenanceUpdate {
    
    var updateContent: String {
        get { updateDescription ?? "" }
        set { updateDescription = newValue }
    }

    var updateCreationDate: Date {
        updateDate ?? .now
    }
    
    static var example: MaintenanceUpdate {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let update = MaintenanceUpdate(context: viewContext)
        update.updateDescription = "Example Update"
        update.updateDate = .now
        return update
    }

}

extension MaintenanceUpdate: Comparable {
    public static func <(lhs: MaintenanceUpdate, rhs: MaintenanceUpdate) -> Bool {
        let left = lhs.updateContent.localizedLowercase
        let right = rhs.updateContent.localizedLowercase

        if left == right {
            return lhs.updateCreationDate < rhs.updateCreationDate
        } else {
            return left < right
        }
    }
}
