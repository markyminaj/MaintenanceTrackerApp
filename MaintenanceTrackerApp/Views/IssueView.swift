//
//  IssueView.swift
//
//  Created by Mark Martin on 6/11/23.
//

import SwiftUI

struct IssueView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var issue: Issue
    @State private var showingNotificationsError = false
    @State private var remindMe = false
    @State private var reminderTime: Date = .now

    
    
    var body: some View {
        Form {
            Section(header: Text("Issue Reminders")) {
                Toggle("Show Reminders", isOn: $issue.remindMe.animation())
                    .alert(isPresented: $showingNotificationsError) {
                        Alert(
                            title: Text("Oops!"),
                            message: Text("There was a problem. Please check you have notifications enabled."),
                            primaryButton: .default(Text("Check Settings"), action: showAppSettings),
                            secondaryButton: .cancel()
                        )
                    }
                
                if issue.remindMe {
                        DatePicker("Reminder time", selection: $issue.issueReminderTime, displayedComponents: .hourAndMinute)
                            .datePickerStyle(.graphical)
                }
                
            }
            Section {
                VStack(alignment: .leading) {
                    TextField(
                        "Title",
                        text: $issue.issueTitle,
                        prompt: Text("Enter the issue title here")
                    )
                    .font(.title)
                    
                    Text("**Modified:** \(issue.issueModificationDate.formatted(date: .long, time: .shortened))")
                        .foregroundStyle(.secondary)
                    Text("**Status:** \(issue.issueStatus)")
                        .foregroundStyle(.secondary)
                }
                
                Picker("Priority", selection: $issue.priority) {
                    Text("Low").tag(Int16(0))
                    Text("Medium").tag(Int16(1))
                    Text("High").tag(Int16(2))
                }
                Toggle("Completed", isOn: $issue.completed)
                    .onChange(of: issue.completed) { newValue in
                        // Need to test on real device
                        if issue.completed {
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        }
                    }
            }
            
            Section {
                VStack(alignment: .leading) {
                    Text("Basic Information")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    TextField(
                        "Description",
                        text: $issue.issueContent,
                        prompt: Text("Enter the issue description here"),
                        axis: .vertical)
                }
            }
        }
        .onDisappear(perform: save)
        .disabled(issue.isDeleted)
        .onReceive(issue.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onSubmit(dataController.save)
        .toolbar {
            IssueViewToolbar(issue: issue)
        }
    }
    
    func save() {
        print("INSIDE DATACONTROLLER UPDATE ISSUE")
        
        dataController.update(with: issue)
    }
    
    func showAppSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }

        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
    
}

struct IssueView_Previews: PreviewProvider {
    static var previews: some View {
        IssueView(issue: .example)
    }
}
