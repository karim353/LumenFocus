import SwiftUI

struct TasksView: View {
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(tasks) { task in
                    TaskRowView(task: task)
                }
                .onDelete(perform: deleteTasks)
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
                AddTaskView { newTask in
                    tasks.append(newTask)
                }
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct TaskRowView: View {
    let task: Task
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.headline)
                Text("Created: \(task.createdAt, style: .date)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Color indicator
            Circle()
                .fill(task.color.color)
                .frame(width: 12, height: 12)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TasksView()
}
