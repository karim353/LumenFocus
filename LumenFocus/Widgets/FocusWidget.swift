import WidgetKit
import SwiftUI

struct FocusWidgetEntryView: View {
    var entry: FocusWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.accentColor)
                Spacer()
                Text("Lumen Focus")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            if let session = entry.recentSession {
                VStack(spacing: 4) {
                    Text(session.taskName)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text("\(session.duration / 60, specifier: "%.0f") min")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                    
                    Text(session.presetName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 4) {
                    Text("No recent sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("Start focusing!")
                        .font(.caption2)
                        .foregroundColor(.accentColor)
                }
            }
            
            Spacer()
            
            HStack {
                Text("Today: \(entry.todaySessions) sessions")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(entry.todayFocusTime / 60, specifier: "%.0f")m")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

struct FocusWidgetEntry: TimelineEntry {
    let date: Date
    let recentSession: RecentSession?
    let todaySessions: Int
    let todayFocusTime: TimeInterval
}

struct RecentSession {
    let taskName: String
    let presetName: String
    let duration: TimeInterval
}

struct FocusWidget: Widget {
    let kind: String = "FocusWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FocusWidgetTimelineProvider()) { entry in
            FocusWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Focus Timer")
        .description("Quick view of your focus sessions and progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct FocusWidgetTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FocusWidgetEntry {
        FocusWidgetEntry(
            date: Date(),
            recentSession: RecentSession(
                taskName: "Sample Task",
                presetName: "Pomodoro",
                duration: 25 * 60
            ),
            todaySessions: 3,
            todayFocusTime: 2 * 60 * 60
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FocusWidgetEntry) -> Void) {
        let entry = FocusWidgetEntry(
            date: Date(),
            recentSession: RecentSession(
                taskName: "Sample Task",
                presetName: "Pomodoro",
                duration: 25 * 60
            ),
            todaySessions: 3,
            todayFocusTime: 2 * 60 * 60
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FocusWidgetEntry>) -> Void) {
        // In a real app, this would fetch data from Core Data
        let currentDate = Date()
        let entry = FocusWidgetEntry(
            date: currentDate,
            recentSession: RecentSession(
                taskName: "Sample Task",
                presetName: "Pomodoro",
                duration: 25 * 60
            ),
            todaySessions: 3,
            todayFocusTime: 2 * 60 * 60
        )
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Bundle

@main
struct FocusWidgetBundle: WidgetBundle {
    var body: some Widget {
        FocusWidget()
    }
}

#Preview(as: .systemSmall) {
    FocusWidget()
} timeline: {
    FocusWidgetEntry(
        date: Date(),
        recentSession: RecentSession(
            taskName: "Sample Task",
            presetName: "Pomodoro",
            duration: 25 * 60
        ),
        todaySessions: 3,
        todayFocusTime: 2 * 60 * 60
    )
}
