import SwiftUI
import Charts
import CoreData

struct StatisticsView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var selectedTimeframe: Timeframe = .week
    @State private var selectedProject: String? = nil
    @State private var sessions: [Session] = []
    
    private let projects = ["All", "Math", "Essay", "Research", "Code", "Reading"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Timeframe selector
                    TimeframeSelector(selectedTimeframe: $selectedTimeframe)
                    
                    // Overview stats
                    OverviewStatsView()
                    
                    // Time by projects chart
                    ProjectTimeChartView()
                    
                    // Daily activity
                    DailyActivityView()
                    
                    // Streak info
                    StreakView()
                }
                .padding(24)
            }
            .background(Color.background)
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        exportData()
                    }
                    .foregroundColor(.accentPrimary)
                }
            }
            .onAppear {
                loadSessions()
            }
        }
    }
    
    private func loadSessions() {
        sessions = coreDataManager.fetchSessions()
    }
    
    private func exportData() {
        // TODO: Implement CSV export
    }
}

struct TimeframeSelector: View {
    @Binding var selectedTimeframe: Timeframe
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Button(action: { selectedTimeframe = timeframe }) {
                    Text(timeframe.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(selectedTimeframe == timeframe ? .white : .primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            selectedTimeframe == timeframe ? Color.accentPrimary : Color.clear
                        )
                        .cornerRadius(20)
                }
            }
        }
        .padding(4)
        .background(Color.surface)
        .cornerRadius(24)
    }
}

struct OverviewStatsView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var totalSessions = 0
    @State private var totalFocusTime: TimeInterval = 0
    @State private var completionRate = 0.0
    @State private var currentStreak = 0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                StatCard(title: "Total Sessions", value: "\(totalSessions)", subtitle: "All time", color: .accentPrimary)
                StatCard(title: "Focus Time", value: "\(String(format: "%.1f", totalFocusTime / 3600))h", subtitle: "Total", color: .accentSecondary)
                StatCard(title: "Completion Rate", value: "\(Int(completionRate * 100))%", subtitle: "Last 7 days", color: .success)
                StatCard(title: "Current Streak", value: "\(currentStreak) days", subtitle: "Personal best!", color: .warning)
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
        let allSessions = coreDataManager.fetchSessions()
        totalSessions = allSessions.count
        totalFocusTime = allSessions.reduce(0) { $0 + $1.duration }
        
        // Calculate completion rate for last 7 days
        let today = Calendar.current.startOfDay(for: Date())
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        let recentSessions = allSessions.filter { $0.startedAt ?? Date() >= weekAgo }
        let completedSessions = recentSessions.filter { $0.isCompleted }
        completionRate = recentSessions.isEmpty ? 0 : Double(completedSessions.count) / Double(recentSessions.count)
        
        // Calculate current streak
        currentStreak = calculateCurrentStreak(from: allSessions)
    }
    
    private func calculateCurrentStreak(from sessions: [Session]) -> Int {
        let sortedSessions = sessions.sorted { $0.startedAt ?? Date() > $1.startedAt ?? Date() }
        guard let lastSession = sortedSessions.first else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = Calendar.current.startOfDay(for: lastSession.startedAt ?? Date())
        
        while currentDate >= lastSessionDate {
            let hasSession = sessions.contains { session in
                Calendar.current.isDate(session.startedAt ?? Date(), inSameDayAs: currentDate)
            }
            
            if hasSession {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct ProjectTimeChartView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var projectData: [ProjectData] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Time by Projects")
                .font(.headline)
                .foregroundColor(.primary)
            
            if projectData.isEmpty {
                Text("No project data available")
                    .foregroundColor(.secondary)
                    .frame(height: 200)
            } else {
                Chart(projectData) { project in
                    BarMark(
                        x: .value("Time", project.time),
                        y: .value("Project", project.name)
                    )
                    .foregroundStyle(project.color.color)
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) {
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel()
                    }
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
        .onAppear {
            loadProjectData()
        }
    }
    
    private func loadProjectData() {
        let sessions = coreDataManager.fetchSessions()
        let tasks = coreDataManager.fetchTasks()
        
        var projectTimeMap: [String: TimeInterval] = [:]
        
        for session in sessions {
            if let task = session.task, let taskTitle = task.title {
                projectTimeMap[taskTitle, default: 0] += session.duration
            }
        }
        
        projectData = projectTimeMap.map { name, time in
            let task = tasks.first { $0.title == name }
            let color = TaskColor(rawValue: task?.color ?? "blue") ?? .blue
            return ProjectData(name: name, time: time / 3600, color: color)
        }.sorted { $0.time > $1.time }
    }
}

struct DailyActivityView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var dailyData: [DailyData] = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Activity")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(dailyData, id: \.day) { data in
                    VStack(spacing: 8) {
                        VStack(spacing: 4) {
                            Text("\(data.sessions)")
                                .font(.caption)
                                .foregroundColor(.accentSecondary)
                            
                            Text("\(String(format: "%.1f", data.time))h")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentPrimary, Color.accentSecondary],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .frame(
                                width: 24,
                                height: max(20, CGFloat(data.time) * 15)
                            )
                        
                        Text(data.day)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
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
            loadDailyData()
        }
    }
    
    private func loadDailyData() {
        let sessions = coreDataManager.fetchSessions()
        let calendar = Calendar.current
        let today = Date()
        
        var dailyStats: [String: (sessions: Int, time: TimeInterval)] = [:]
        
        // Initialize with last 7 days
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                let dayName = getDayName(from: date)
                dailyStats[dayName] = (sessions: 0, time: 0)
            }
        }
        
        // Aggregate session data
        for session in sessions {
            if let startDate = session.startedAt {
                let dayName = getDayName(from: startDate)
                if let current = dailyStats[dayName] {
                    dailyStats[dayName] = (
                        sessions: current.sessions + 1,
                        time: current.time + session.duration
                    )
                }
            }
        }
        
        // Convert to DailyData array
        dailyData = dailyStats.map { dayName, stats in
            DailyData(day: dayName, sessions: stats.sessions, time: stats.time / 3600)
        }.sorted { day1, day2 in
            let dayOrder = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let index1 = dayOrder.firstIndex(of: day1.day) ?? 0
            let index2 = dayOrder.firstIndex(of: day2.day) ?? 0
            return index1 < index2
        }
    }
    
    private func getDayName(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct StreakView: View {
    @ObservedObject private var coreDataManager = CoreDataManager.shared
    @State private var currentStreak = 0
    @State private var bestStreak = 0
    @State private var weeklySessions = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Streak")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    Text("🔥")
                        .font(.title)
                    
                    Text("\(currentStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.warning)
                    
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("🏆")
                        .font(.title)
                    
                    Text("\(bestStreak)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.accentPrimary)
                    
                    Text("Best")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    Text("📈")
                        .font(.title)
                    
                    Text("\(weeklySessions)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.success)
                    
                    Text("This Week")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
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
            loadStreakData()
        }
    }
    
    private func loadStreakData() {
        let sessions = coreDataManager.fetchSessions()
        
        // Calculate current streak
        currentStreak = calculateCurrentStreak(from: sessions)
        
        // Calculate best streak (simplified - just use current for now)
        bestStreak = max(bestStreak, currentStreak)
        
        // Calculate weekly sessions
        let today = Calendar.current.startOfDay(for: Date())
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: today) ?? today
        weeklySessions = sessions.filter { $0.startedAt ?? Date() >= weekAgo }.count
    }
    
    private func calculateCurrentStreak(from sessions: [Session]) -> Int {
        let sortedSessions = sessions.sorted { $0.startedAt ?? Date() > $1.startedAt ?? Date() }
        guard let lastSession = sortedSessions.first else { return 0 }
        
        var streak = 0
        var currentDate = Calendar.current.startOfDay(for: Date())
        let lastSessionDate = Calendar.current.startOfDay(for: lastSession.startedAt ?? Date())
        
        while currentDate >= lastSessionDate {
            let hasSession = sessions.contains { session in
                Calendar.current.isDate(session.startedAt ?? Date(), inSameDayAs: currentDate)
            }
            
            if hasSession {
                streak += 1
                currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Data Models

enum Timeframe: CaseIterable {
    case day, week, month, year
    
    var displayName: String {
        switch self {
        case .day: return "Day"
        case .week: return "Week"
        case .month: return "Month"
        case .year: return "Year"
        }
    }
}

struct ProjectData: Identifiable {
    let id = UUID()
    let name: String
    let time: Double
    let color: TaskColor
}

struct DailyData {
    let day: String
    let sessions: Int
    let time: Double
}

#Preview {
    StatisticsView()
}
