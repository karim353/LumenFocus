import Foundation

struct Session: Identifiable, Codable {
    let id: UUID
    let taskId: UUID?
    let startDate: Date
    let endDate: Date?
    let phase: SessionPhase
    let presetId: UUID
    let completed: Bool
    let duration: TimeInterval
    
    init(
        id: UUID = UUID(),
        taskId: UUID? = nil,
        startDate: Date,
        endDate: Date? = nil,
        phase: SessionPhase,
        presetId: UUID,
        completed: Bool = false
    ) {
        self.id = id
        self.taskId = taskId
        self.startDate = startDate
        self.endDate = endDate
        self.phase = phase
        self.presetId = presetId
        self.completed = completed
        self.duration = endDate?.timeIntervalSince(startDate) ?? 0
    }
}

enum SessionPhase: String, CaseIterable, Codable {
    case work = "work"
    case shortBreak = "shortBreak"
    case longBreak = "longBreak"
    case paused = "paused"
    
    var displayName: String {
        switch self {
        case .work:
            return "Work"
        case .shortBreak:
            return "Short Break"
        case .longBreak:
            return "Long Break"
        case .paused:
            return "Paused"
        }
    }
    
    var icon: String {
        switch self {
        case .work:
            return "brain.head.profile"
        case .shortBreak:
            return "cup.and.saucer"
        case .longBreak:
            return "leaf"
        case .paused:
            return "pause.circle"
        }
    }
}
