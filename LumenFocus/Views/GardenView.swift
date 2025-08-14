import SwiftUI

struct GardenView: View {
    @State private var plants: [Plant] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                    ForEach(plants) { plant in
                        PlantCardView(plant: plant)
                    }
                }
                .padding()
            }
            .navigationTitle("Garden")
            .onAppear {
                loadSamplePlants()
            }
        }
    }
    
    private func loadSamplePlants() {
        plants = [
            Plant(name: "Focus Tree", level: 3, experience: 750, maxExperience: 1000, icon: "🌳"),
            Plant(name: "Productivity Flower", level: 2, experience: 400, maxExperience: 500, icon: "🌸"),
            Plant(name: "Learning Seed", level: 1, experience: 150, maxExperience: 200, icon: "🌱"),
            Plant(name: "Creativity Bush", level: 4, experience: 1200, maxExperience: 1500, icon: "🌿")
        ]
    }
}

struct Plant: Identifiable {
    let id = UUID()
    let name: String
    let level: Int
    let experience: Int
    let maxExperience: Int
    let icon: String
    
    var progress: Double {
        Double(experience) / Double(maxExperience)
    }
}

struct PlantCardView: View {
    let plant: Plant
    
    var body: some View {
        VStack(spacing: 12) {
            Text(plant.icon)
                .font(.system(size: 40))
            
            Text(plant.name)
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("Level \(plant.level)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: plant.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                .scaleEffect(x: 1, y: 2, anchor: .center)
            
            Text("\(plant.experience)/\(plant.maxExperience) XP")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

#Preview {
    GardenView()
}
