//
//  IssueRow.swift
//  HabitU
//
//  Created by Mark Martin on 6/11/23.
//

import SwiftUI

struct IssueRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    
    var body: some View {
        NavigationLink(value: issue) {
                HStack {
                    Image(systemName: "exclamationmark.circle")
                        .imageScale(.large)
                        .opacity(issue.priority == 2 ? 1 : 0)
                        .foregroundColor(Color.gray)
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 8)
                    
                    VStack(alignment: .leading) {
                        Text(issue.issueTitle)
                            .font(.headline)
                            .lineLimit(1)
                        
                        Text(issue.issueTagsList)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.trailing, 8)
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(issue.issueFormattedCreatedDate)
                            .accessibilityLabel(issue.issueCreatedDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                        if issue.completed {
                            Text("CLOSED")
                                .font(.body.smallCaps())
                                .foregroundColor(.red)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.7), radius: 2, x: 1, y: 1)
        }
        .accessibilityHint(issue.priority == 2 ? "High priority" : "")
    }
}

struct IssueRow_Previews: PreviewProvider {
    static var previews: some View {
        IssueRow(issue: .example)
    }
}
