//
//  Home.swift
//  SimpleTodo
//
//  Created by Pedro Acevedo on 08/05/24.
//

import SwiftUI

struct Home: View {
    @Environment(\.self) private var env
    @State private var filterDate: Date = .init()
    @State private var showPendingTasks: Bool = true
    @State private var showCompletedTasks: Bool = true
    
    var body: some View {
        List {
            DatePicker(selection: $filterDate, displayedComponents: [.date]) {
                
            }
            .labelsHidden()
            .datePickerStyle(.graphical)
            
            CustomFilteringDataView(filterDate: $filterDate) { pendingTasks, completedTasks in
                DisclosureGroup(isExpanded: $showPendingTasks) {
                    // Custom view that will display only pending tasks for this day
                    if pendingTasks.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(pendingTasks) {
                            TaskRow(task: $0, isPendingTask: true)
                        }
                    }
                } label: {
                    Text("Pending Task's \(pendingTasks.isEmpty ? "" : "(\(pendingTasks.count))")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
                DisclosureGroup(isExpanded: $showCompletedTasks) {
                    // Custom view that will display only completed tasks for this day
                    if completedTasks.isEmpty {
                        Text("No Task's Found")
                            .font(.caption)
                            .foregroundStyle(.gray)
                    } else {
                        ForEach(completedTasks) {
                                TaskRow(task: $0, isPendingTask: false)
                        }
                    }
                } label: {
                    Text("Completed Task's \(completedTasks.isEmpty ? "" : "(\(completedTasks.count))")")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    //Open pending task view
                    do {
                        let task = Task(context: env.managedObjectContext)
                        task.id = .init()
                        task.date = filterDate
                        task.title = ""
                        task.isCompleted = false
                        
                        try env.managedObjectContext.save()
                        showPendingTasks = true
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        Text("New Task")
                    }
                    .fontWeight(.bold)
                }
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }
        }
    }
}

#Preview {
    ContentView()
}

struct TaskRow: View {
    @ObservedObject var task: Task
    var isPendingTask: Bool
    @Environment(\.self) private var env
    @FocusState private var showKeyboard: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                task.isCompleted.toggle()
                save()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("Task Title", text: .init(
                    get: {
                        return task.title ?? ""
                    },
                    set: { value in
                        task.title = value
                    })
                )
                .focused($showKeyboard)
                .onSubmit {
                    removeEmptyTask()
                    save()
                }
                .foregroundStyle(isPendingTask ? Color.primary : .gray)
                .strikethrough(!isPendingTask, pattern: .dash, color: .primary)
                
                //Custom DatePicker
                Text((task.date ?? .init()).formatted(
                    date: .omitted,
                    time: .shortened))
                .font(.callout)
                .foregroundStyle(.gray)
                .overlay {
                    DatePicker(selection: .init(
                        get: {
                            return task.date ?? .init()
                        },
                        set: { value in
                            task.date = value
                            //Saving date whenever its updated
                            save()
                        }), displayedComponents: [.hourAndMinute]) {
                            
                        }
                        .labelsHidden()
                        //Hidding view by utilizing Blendmode modifier
                        .blendMode(.destinationOver)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            if (task.title ?? "").isEmpty {
                showKeyboard = true
            }
        }
        .onDisappear {
            removeEmptyTask()
            save()
        }
        //Verifying content when user leaves the app
        .onChange(of: env.scenePhase) {
            if env.scenePhase != .active {
                showKeyboard = false
                DispatchQueue.main.async {
                    //Checking if its empty
                    removeEmptyTask()
                    save()
                }
            }
        }
        //Swipe to delete
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                //Added a little delay to prevent screen tearing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    env.managedObjectContext.delete(task)
                    save()
                }
            } label: {
                Image(systemName: "trash.fill")
            }
        }
    }
    
    //context saving method
    func save() {
        do {
            try env.managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    //Removing empty task
    func removeEmptyTask() {
        if (task.title ?? "").isEmpty {
            env.managedObjectContext.delete(task)
        }
    }
}
