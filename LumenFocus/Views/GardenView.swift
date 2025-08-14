import SwiftUI
import CoreData

struct GardenView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var plants: [GardenPlant] = []
    @State private var achievements: [Achievement] = [
        Achievement(title: "First Focus", description: "Complete your first session", unlocked: false, icon: "star.fill"),
        Achievement(title: "Streak Master", description: "5 days in a row", unlocked: false, icon: "flame.fill"),
        Achievement(title: "Deep Work", description: "Complete 10 work sessions", unlocked: false, icon: "brain.head.profile"),
        Achievement(title: "Break Champion", description: "Take all your breaks", unlocked: false, icon: "cup.and.saucer.fill")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Garden Scene
                    GardenSceneView(plants: plants)
                        .frame(height: 300)
                    
                    // Stats
                    StatsView()
                    
                    // Achievements
                    AchievementsView(achievements: achievements)
                }
                .padding(24)
            }
            .background(Color.background)
            .navigationTitle("Garden")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadPlants()
                updateAchievements()
            }
        }
    }
    
    private func loadPlants() {
        plants = coreDataManager.fetchPlants()
    }
    
    private func updateAchievements() {
        let sessions = coreDataManager.fetchSessions()
        
        // First Focus achievement
        if sessions.count >= 1 {
            achievements[0].unlocked = true
        }
        
        // Deep Work achievement
        if sessions.count >= 10 {
            achievements[2].unlocked = true
        }
        
        // Check for streak (simplified)
        let today = Calendar.current.startOfDay(for: Date())
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        let recentSessions = sessions.filter { $0.startedAt ?? Date() >= weekAgo }
        if recentSessions.count >= 5 {
            achievements[1].unlocked = true
        }
    }
}

struct GardenSceneView: View {
    let plants: [GardenPlant]
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.background,
                            Color.surface.opacity(0.3),
                            Color.background
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Plants
            ForEach(plants) { plant in
                PlantView(plant: plant)
                    .position(
                        x: CGFloat.random(in: 50...250),
                        y: CGFloat.random(in: 50...250)
                    )
            }
            
            // Ambient particles
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(Color.accentPrimary.opacity(0.3))
                    .frame(width: 4, height: 4)
                    .position(
                        x: CGFloat.random(in: 20...280),
                        y: CGFloat.random(in: 20...280)
                    )
                    .opacity(0.6)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.surface.opacity(0.3), lineWidth: 1)
        )
    }
}

struct PlantView: View {
    let plant: GardenPlant
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            // Plant icon
            ZStack {
                Circle()
                    .fill(getPlantColor(plant.plantType ?? "neon-sprout").opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: getPlantIcon(plant.plantType ?? "neon-sprout"))
                    .font(.title)
                    .foregroundColor(getPlantColor(plant.plantType ?? "neon-sprout"))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
            }
            .shadow(
                color: getPlantColor(plant.plantType ?? "neon-sprout").opacity(0.3),
                radius: 12,
                x: 0,
                y: 6
            )
            
            // Level indicator
            Text("Lv.\(plant.growthLevel)")
                .font(.caption)
                .foregroundColor(getPlantColor(plant.plantType ?? "neon-sprout"))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(getPlantColor(plant.plantType ?? "neon-sprout").opacity(0.2))
                .cornerRadius(8)
            
            // Water level indicator
            Text("💧 \(plant.waterLevel)%")
                .font(.caption2)
                .foregroundColor(.blue)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
    
    private func getPlantColor(_ plantType: String) -> Color {
        switch plantType {
        case "neon-sprout": return .green
        case "glow-fern": return .blue
        case "crystal-bloom": return .purple
        case "quantum-vine": return .orange
        case "stellar-bud": return .pink
        default: return .green
        }
    }
    
    private func getPlantIcon(_ plantType: String) -> String {
        switch plantType {
        case "neon-sprout": return "leaf"
        case "glow-fern": return "leaf.fill"
        case "crystal-bloom": return "flower"
        case "quantum-vine": return "vines"
        case "stellar-bud": return "star"
        default: return "leaf"
        }
    }
}

struct StatsView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var totalSessions = 0
    @State private var totalFocusTime: TimeInterval = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Garden Stats")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 16) {
                StatCard(title: "Plants", value: "\(coreDataManager.fetchPlants().count)", color: .accentPrimary)
                StatCard(title: "Total Level", value: "\(coreDataManager.fetchPlants().reduce(0) { $0 + Int($1.growthLevel) })", color: .accentSecondary)
                StatCard(title: "Sessions", value: "\(totalSessions)", color: .success)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.surface.opacity(0.3), lineWidth: 1)
                )
        )
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        let sessions = coreDataManager.fetchSessions()
        totalSessions = sessions.count
        totalFocusTime = sessions.reduce(0) { $0 + $1.duration }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct AchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Achievements")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVStack(spacing: 12) {
                ForEach(achievements) { achievement in
                    AchievementRow(achievement: achievement)
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.surface.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct AchievementRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.unlocked ? Color.accentPrimary : Color.surface.opacity(0.5))
                    .frame(width: 40, height: 40)
                
                Image(systemName: achievement.icon)
                    .foregroundColor(achievement.unlocked ? .white : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(achievement.unlocked ? .primary : .secondary)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.unlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(achievement.unlocked ? Color.accentPrimary.opacity(0.1) : Color.clear)
        )
    }
}

// MARK: - Data Models

// Plant and PlantType are now handled by Core Data GardenPlant entity

struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let unlocked: Bool
    let icon: String
}

#Preview {
    GardenView()
}
