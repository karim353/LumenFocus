import SwiftUI

struct StatisticsView: View {
    @State private var selectedTimeframe: Timeframe = .week
    @State private var sessions: [Session] = []
    
    enum Timeframe: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Timeframe Picker
                    Picker("Timeframe", selection: $selectedTimeframe) {
                        ForEach(Timeframe.allCases, id: \.self) { timeframe in
                            Text(timeframe.rawValue).tag(timeframe)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Stats Cards
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        StatCard(title: "Total Sessions", value: "\(sessions.count)", icon: "timer", color: .blue)
                        StatCard(title: "Focus Time", value: formatTime(totalFocusTime), icon: "clock", color: .green)
                        StatCard(title: "Avg Session", value: formatTime(averageSessionTime), icon: "chart.bar", color: .orange)
                        StatCard(title: "Best Streak", value: "\(bestStreak)", icon: "flame", color: .red)
                    }
                    .padding(.horizontal)
                    
                    // Recent Sessions Graph
                    RecentSessionsGraphView()
                        .frame(height: 200)
                        .padding(.horizontal)
                    
                    // Session List
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Sessions")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(sessions.prefix(5)) { session in
                            SessionRowView(session: session)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Statistics")
            .onAppear {
                loadSampleData()
            }
        }
    }
    
    private var totalFocusTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    private var averageSessionTime: TimeInterval {
        sessions.isEmpty ? 0 : totalFocusTime / Double(sessions.count)
    }
    
    private var bestStreak: Int {
        // Simplified streak calculation
        return min(sessions.count, 7)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    private func loadSampleData() {
        let now = Date()
        // Создаем тестовые сессии для демонстрации
        // В реальном приложении эти данные будут загружаться из Core Data
        let session1 = Session()
        session1.id = UUID()
        session1.startedAt = now.addingTimeInterval(-3600)
        session1.duration = 1500
        session1.currentPhase = "work"
        session1.isCompleted = true
        
        let session2 = Session()
        session2.id = UUID()
        session2.startedAt = now.addingTimeInterval(-7200)
        session2.duration = 1800
        session2.currentPhase = "work"
        session2.isCompleted = true
        
        let session3 = Session()
        session3.id = UUID()
        session3.startedAt = now.addingTimeInterval(-10800)
        session3.duration = 1200
        session3.currentPhase = "shortBreak"
        session3.isCompleted = true
        
        sessions = [session1, session2, session3]
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
}

struct SessionRowView: View {
    let session: Session
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.phase.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(session.startDate, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatDuration(session.duration))
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        return "\(minutes)m"
    }
}

#Preview {
    StatisticsView()
}
