//
//  ContentView.swift
//  HabitU
//
//  Created by Mark Martin on 6/7/23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController

    func delete(_ offsets: IndexSet) {
        let issues = dataController.issuesForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
    
    var body: some View {
            List(selection: $dataController.selectedIssue) {
                ForEach(dataController.issuesForSelectedFilter()) { issue in
                    IssueRow(issue: issue)
                }
                .onDelete(perform: delete)
                .listRowSeparator(.hidden)
                .listRowBackground(Color(UIColor.systemBackground))
            }
            .navigationTitle("Issues")
            .searchable(text: $dataController.filterText, tokens: $dataController.filterTokens, suggestedTokens: .constant(dataController.suggestedFilterTokens), prompt: "Filter issues, or type # to add tags") { tag in
                Text(tag.tagName)
            }
            .toolbar(content: ContentViewToolbar.init)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
