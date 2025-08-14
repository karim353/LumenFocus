import ActivityKit
import Foundation
import SwiftUI

struct FocusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var timeRemaining: TimeInterval
        var currentPhase: String
        var currentRound: Int
        var totalRounds: Int
        var isRunning: Bool
    }
    
    var taskName: String
    var presetName: String
}

@MainActor
class LiveActivityManager: ObservableObject {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<FocusTimerAttributes>?
    
    private init() {}
    
    func startLiveActivity(
        taskName: String,
        presetName: String,
        timeRemaining: TimeInterval,
        currentPhase: String,
        currentRound: Int,
        totalRounds: Int
    ) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are not enabled")
            return
        }
        
        let attributes = FocusTimerAttributes(
            taskName: taskName,
            presetName: presetName
        )
        
        let contentState = FocusTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            currentPhase: currentPhase,
            currentRound: currentRound,
            totalRounds: totalRounds,
            isRunning: true
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState,
                pushType: nil
            )
            currentActivity = activity
            print("Live Activity started successfully")
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity(
        timeRemaining: TimeInterval,
        currentPhase: String,
        currentRound: Int,
        totalRounds: Int,
        isRunning: Bool
    ) {
        guard let activity = currentActivity else { return }
        
        let contentState = FocusTimerAttributes.ContentState(
            timeRemaining: timeRemaining,
            currentPhase: currentPhase,
            currentRound: currentRound,
            totalRounds: totalRounds,
            isRunning: isRunning
        )
        
        Task {
            await activity.update(using: contentState)
        }
    }
    
    func stopLiveActivity() {
        guard let activity = currentActivity else { return }
        
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
        }
    }
    
    func pauseLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let contentState = FocusTimerAttributes.ContentState(
            timeRemaining: 0,
            currentPhase: "Paused",
            currentRound: 0,
            totalRounds: 0,
            isRunning: false
        )
        
        Task {
            await activity.update(using: contentState)
        }
    }
}

// MARK: - Live Activity Views

struct FocusTimerLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.attributes.taskName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.attributes.presetName)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Round \(context.state.currentRound)/\(context.state.totalRounds)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(context.state.currentPhase)
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 8) {
                        Text(formatTime(context.state.timeRemaining))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        ProgressView(value: Double(context.state.totalRounds - context.state.currentRound + 1), total: Double(context.state.totalRounds))
                            .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                            .foregroundColor(.accentColor)
                        Text(context.state.isRunning ? "Tap to pause" : "Tap to resume")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.accentColor)
            } compactTrailing: {
                Text(formatTime(context.state.timeRemaining))
                    .font(.caption2)
                    .foregroundColor(.primary)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.accentColor)
            }
        }
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<FocusTimerAttributes>
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.attributes.taskName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(context.attributes.presetName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Round \(context.state.currentRound)/\(context.state.totalRounds)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(context.state.currentPhase)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            
            Text(formatTime(context.state.timeRemaining))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            ProgressView(value: Double(context.state.totalRounds - context.state.currentRound + 1), total: Double(context.state.totalRounds))
                .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
            
            HStack {
                Image(systemName: context.state.isRunning ? "pause.fill" : "play.fill")
                    .foregroundColor(.accentColor)
                Text(context.state.isRunning ? "Timer is running" : "Timer is paused")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
