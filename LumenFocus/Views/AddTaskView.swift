import SwiftUI

struct AddTaskView: View {
    let onSave: (Task) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var selectedColor: TaskColor = .violet
    @State private var selectedIcon = "book"
    @State private var tags: [String] = []
    @State private var newTag = ""
    
    private let availableIcons = [
        "book", "pencil", "function", "laptopcomputer", "magnifyingglass",
        "figure.walk", "brain.head.profile", "leaf", "star", "heart",
        "lightbulb", "flame", "bolt", "drop", "mountain.2"
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Title input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Title")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("Enter task title", text: $title)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.surface)
                            .cornerRadius(12)
                    }
                    
                    // Color selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Color")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(TaskColor.allCases, id: \.self) { color in
                                Button(action: { selectedColor = color }) {
                                    Circle()
                                        .fill(color.color)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    selectedColor == color ? Color.white : Color.clear,
                                                    lineWidth: 3
                                                )
                                        )
                                        .shadow(
                                            color: selectedColor == color ? color.color.opacity(0.5) : Color.clear,
                                            radius: 8,
                                            x: 0,
                                            y: 4
                                        )
                                }
                                .scaleEffect(selectedColor == color ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedColor)
                            }
                        }
                    }
                    
                    // Icon selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Icon")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 12) {
                            ForEach(availableIcons, id: \.self) { icon in
                                Button(action: { selectedIcon = icon }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(selectedIcon == icon ? Color.accentPrimary : Color.surface)
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: icon)
                                            .font(.title3)
                                            .foregroundColor(selectedIcon == icon ? .white : .primary)
                                    }
                                }
                                .scaleEffect(selectedIcon == icon ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedIcon)
                            }
                        }
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Tags")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Add new tag
                        HStack {
                            TextField("Add tag", text: $newTag)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color.surface)
                                .cornerRadius(8)
                            
                            Button("Add") {
                                if !newTag.isEmpty {
                                    tags.append(newTag)
                                    newTag = ""
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newTag.isEmpty)
                        }
                        
                        // Display existing tags
                        if !tags.isEmpty {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    HStack {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(selectedColor.color.opacity(0.2))
                                            .foregroundColor(selectedColor.color)
                                            .cornerRadius(8)
                                        
                                        Button(action: { tags.removeAll { $0 == tag } }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(selectedColor.color)
                                                .font(.caption)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(24)
            }
            .background(Color.background)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newTask = Task(
                            title: title,
                            color: selectedColor,
                            icon: selectedIcon,
                            tags: tags
                        )
                        onSave(newTask)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddTaskView { _ in }
}
