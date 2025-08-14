import SwiftUI

struct RecentSessionsGraphView: View {
    // Mock data for preview - in real app this would come from ViewModel
    private let mockData: [SessionData] = [
        SessionData(date: Date().addingTimeInterval(-6 * 24 * 3600), duration: 25, completed: true),
        SessionData(date: Date().addingTimeInterval(-5 * 24 * 3600), duration: 30, completed: true),
        SessionData(date: Date().addingTimeInterval(-4 * 24 * 3600), duration: 0, completed: false),
        SessionData(date: Date().addingTimeInterval(-3 * 24 * 3600), duration: 45, completed: true),
        SessionData(date: Date().addingTimeInterval(-2 * 24 * 3600), duration: 20, completed: true),
        SessionData(date: Date().addingTimeInterval(-1 * 24 * 3600), duration: 35, completed: true),
        SessionData(date: Date(), duration: 0, completed: false)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Sessions")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(mockData, id: \.date) { session in
                    VStack(spacing: 8) {
                        // Bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                session.completed ? 
                                LinearGradient(
                                    colors: [Color.accentPrimary, Color.accentSecondary],
                                    startPoint: .bottom,
                                    endPoint: .top
                                ) :
                                Color(.systemGray6).opacity(0.3)
                            )
                            .frame(
                                width: 24,
                                height: max(20, CGFloat(session.duration) * 0.8)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(
                                        session.completed ? Color.accentPrimary.opacity(0.3) : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                            .shadow(
                                color: session.completed ? Color.accentPrimary.opacity(0.2) : Color.clear,
                                radius: 4,
                                x: 0,
                                y: 2
                            )
                        
                        // Day label
                        Text(dayLabel(for: session.date))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .frame(height: 120)
            
            // Summary stats
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completedSessions)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentPrimary)
                    Text("Completed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(totalMinutes) min")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentSecondary)
                    Text("Total Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.systemGray6).opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var completedSessions: Int {
        mockData.filter { $0.completed }.count
    }
    
    private var totalMinutes: Int {
        mockData.filter { $0.completed }.reduce(0) { $0 + $1.duration }
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
}

// Mock data structure
struct SessionData {
    let date: Date
    let duration: Int // in minutes
    let completed: Bool
}

#Preview {
    RecentSessionsGraphView()
        .background(Color(.systemBackground))
        .padding()
}
