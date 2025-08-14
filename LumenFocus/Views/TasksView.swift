import SwiftUI
import CoreData

struct TasksView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var tasks: [Task] = []
    @State private var showingAddTask = false
    @State private var selectedTask: Task?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(tasks) { task in
                        TaskCardView(task: task) {
                            selectedTask = task
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.background)
            .navigationTitle("Tasks")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddTask = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentPrimary)
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddTaskView { newTask in
                    // Create task in Core Data
                    let _ = coreDataManager.createTask(
                        title: newTask.title,
                        color: newTask.color.rawValue,
                        icon: newTask.icon,
                        tags: newTask.tags
                    )
                    loadTasks()
                }
            }
            .onAppear {
                loadTasks()
            }
        }
    }
    
    private func loadTasks() {
        tasks = coreDataManager.fetchTasks()
    }
}

struct TaskCardView: View {
    let task: Task
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon with color background
                ZStack {
                    Circle()
                        .fill(TaskColor(rawValue: task.color ?? "blue")?.color.opacity(0.2) ?? Color.blue.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: task.icon ?? "circle")
                        .font(.title2)
                        .foregroundColor(TaskColor(rawValue: task.color ?? "blue")?.color ?? Color.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if let tags = task.tags, !tags.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.surface.opacity(0.5))
                                    .foregroundColor(.secondary)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(TaskColor(rawValue: task.color ?? "blue")?.color.opacity(0.2) ?? Color.blue.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: (TaskColor(rawValue: task.color ?? "blue")?.color ?? Color.blue).opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    TasksView()
}
