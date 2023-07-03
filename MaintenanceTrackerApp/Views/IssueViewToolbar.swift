//
//  IssueToolbar.swift
//
//  Created by Mark Martin on 6/21/23.
//

import SwiftUI

struct IssueViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    var openCloseButtonText: LocalizedStringKey {
        issue.completed ? "Re-open Issue" : "Close Issue"
    }

    var body: some View {
        Menu {
            Divider()

            Section("Tags") {
                TagsMenuView(issue: issue)
            }
            Button {
                UIPasteboard.general.string = issue.title
            } label: {
                Label("Copy Issue Title", systemImage: "doc.on.doc")
            }

            Button {
                issue.completed.toggle()
                dataController.save()
            } label: {
                Label(openCloseButtonText,
                      systemImage: "bubble.left.and.exclamationmark.bubble.right")
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}

struct IssueToolbar_Previews: PreviewProvider {
    static var previews: some View {
        IssueViewToolbar(issue: Issue.example)
    }
}
