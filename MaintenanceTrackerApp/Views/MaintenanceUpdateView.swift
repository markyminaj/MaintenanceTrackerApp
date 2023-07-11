//
//  MaintenanceUpdateView.swift
//  MaintenanceTrackerApp
//
//  Created by Mark Martin on 7/10/23.
//

import SwiftUI

struct MaintenanceUpdateView: View {
    @State private var date = Date()
    @State private var description = ""

    let onAdd: (MaintenanceUpdate) -> Void

    var body: some View {
        NavigationView {
            Form {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Description", text: $description)
            }
            .navigationBarTitle("Add Maintenance Update")
            .navigationBarItems(trailing: Button("Add") {
                let update = MaintenanceUpdate(date: date, description: description)
                onAdd(update)
                
            })
        }
    }
}
