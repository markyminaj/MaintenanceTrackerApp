//
//  MaintenanceUpdate.swift
//  MaintenanceTrackerApp
//
//  Created by Mark Martin on 7/10/23.
//

import Foundation

struct MaintenanceUpdate: Identifiable {
    let id = UUID()
    let date: Date
    let description: String
}

