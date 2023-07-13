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
    @State private var isSheetPresented = false
    @State private var remindMe = false
    @State private var reminderTime: Date = .now
    @State private var historyText: String = ""


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
            //MARK: Need to add list of updates here via core data
            Section(header: Text("History")) {
                VStack {
                    Text("Updates go here")
                    //Problem is here..how to add list of MaintenanceUpdates assigned to issue
                    ForEach(issue.issueUpdates) { update in
                        VStack {
                            Text("Update: \(update.updateContent)")
                        }
                        
                    }
                    
                }
                Button("Add Maintenance Update") {
                    isSheetPresented = true
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
        .sheet(isPresented: $isSheetPresented) {
            // Sheet content with input fields and an "Add" button
            MaintenanceUpdateView(issue: issue) { update in
                
            }
            
        }
    }
    
    func save() {
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
            .environmentObject(DataController.init())
    }
}
