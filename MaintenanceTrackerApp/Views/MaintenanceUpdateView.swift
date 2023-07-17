//
//  MaintenanceUpdateView.swift
//  MaintenanceTrackerApp
//
//  Created by Mark Martin on 7/10/23.
//

import SwiftUI

struct MaintenanceUpdateView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    @State private var date = Date()
    @State private var description = ""
    @State private var sheetPresented = true
    
    let onAdd: (MaintenanceUpdate) -> Void
    
    func newUpdate() {
        let update = MaintenanceUpdate(context: dataController.container.viewContext)
        update.updateDate = .now
        update.updateDescription = description
        issue.addToUpdates(update)
        print(issue.issueUpdates.count)
        dataController.save()
    }

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Description", text: $description)
            }
            .navigationBarTitle("Add Maintenance Update")
            .navigationBarItems(trailing: Button("Add") {
                newUpdate()
                
                
            })
        }
    }
}
