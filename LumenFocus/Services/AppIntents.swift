import Foundation
import AppIntents

struct StartFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Focus Session"
    static var description: LocalizedStringResource = "Start a new focus session with the specified preset"
    
    @Parameter(title: "Preset")
    var preset: String
    
    @Parameter(title: "Task")
    var task: String?
    
    init() {
        self.preset = "Pomodoro"
        self.task = nil
    }
    
    init(preset: String, task: String? = nil) {
        self.preset = preset
        self.task = task
    }
    
    func perform() async throws -> some IntentResult {
        // In a real app, this would start the focus session
        print("Starting focus session with preset: \(preset), task: \(task ?? "None")")
        
        return .result()
    }
}

struct StopFocusSessionIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Focus Session"
    static var description: LocalizedStringResource = "Stop the current focus session"
    
    func perform() async throws -> some IntentResult {
        // In a real app, this would stop the current focus session
        print("Stopping focus session")
        
        return .result()
    }
}

struct GetFocusStatsIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Focus Statistics"
    static var description: LocalizedStringResource = "Get your focus session statistics"
    
    func perform() async throws -> some IntentResult {
        // In a real app, this would return focus statistics
        let stats = "Focus sessions: 0, Total time: 0h"
        print("Focus stats: \(stats)")
        
        return .result()
    }
}

struct LumenFocusAppShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: StartFocusSessionIntent(),
            phrases: [
                "Start focus session",
                "Begin focusing",
                "Start timer"
            ],
            shortTitle: "Start Focus",
            systemImageName: "timer"
        )
        
        AppShortcut(
            intent: StopFocusSessionIntent(),
            phrases: [
                "Stop focus session",
                "End focusing",
                "Stop timer"
            ],
            shortTitle: "Stop Focus",
            systemImageName: "stop.circle"
        )
        
        AppShortcut(
            intent: GetFocusStatsIntent(),
            phrases: [
                "How am I doing",
                "Focus statistics",
                "Show my progress"
            ],
            shortTitle: "Focus Stats",
            systemImageName: "chart.bar"
        )
    }
}
