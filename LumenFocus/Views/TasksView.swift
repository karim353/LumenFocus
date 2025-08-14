import SwiftUI
import CoreData

struct TasksView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.createdAt, ascending: false)],
        animation: .default)
    private var tasks: FetchedResults<Task>
    
    @State private var showingAddTask = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            List {
                if tasks.isEmpty {
                    Text("No tasks yet. Tap + to add your first task!")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                } else {
                    ForEach(tasks) { task in
                        TaskRowView(task: task)
                    }
                    .onDelete(perform: deleteTasks)
                }
            }
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView { title, color, icon, tags in
                    createTask(title: title, color: color, icon: icon, tags: tags)
                }
            }
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createTask(title: String, color: String, icon: String, tags: [String]) {
        let newTask = Task(context: viewContext)
        newTask.id = UUID()
        newTask.title = title
        newTask.color = color
        newTask.icon = icon
        newTask.tags = tags
        newTask.createdAt = Date()
        
        do {
            try viewContext.save()
        } catch {
            errorMessage = "Failed to save task: \(error.localizedDescription)"
            showingError = true
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { tasks[$0] }.forEach(viewContext.delete)
            
            do {
                try viewContext.save()
            } catch {
                errorMessage = "Failed to delete task: \(error.localizedDescription)"
                showingError = true
            }
        }
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            // Icon
            if let icon = task.icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.primary)
                    .frame(width: 30, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title ?? "Untitled")
                    .font(.headline)
                
                if let createdAt = task.createdAt {
                    Text("Created: \(createdAt, style: .date)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Tags
                if let tags = task.tags, !tags.isEmpty {
                    HStack {
                        ForEach(tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.2))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        
                        if tags.count > 3 {
                            Text("+\(tags.count - 3)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Color indicator
            if let colorString = task.color {
                Circle()
                    .fill(TaskColor(rawValue: colorString)?.color ?? Color.gray)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    TasksView()
}
