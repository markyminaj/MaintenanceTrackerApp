//
//  SidebarToolbar.swift
//  HabitU
//
//  Created by Mark Martin on 6/21/23.
//

import SwiftUI

struct SidebarViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    var body: some View {
        Button {
            dataController.deleteAll()
            dataController.createSampleData()
        } label: {
            Label("ADD SAMPLES", systemImage: "flame")
        }
        Button(action: dataController.newTag) {
            Label("Add tag", systemImage: "plus")
        }
    }
}

struct SidebarViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        SidebarViewToolbar()
    }
}
