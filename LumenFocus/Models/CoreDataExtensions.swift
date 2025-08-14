import Foundation
import SwiftUI

// MARK: - Preset Extensions

extension Preset {
    static let pomodoro: Preset = {
        let preset = Preset()
        preset.id = UUID()
        preset.name = "Pomodoro"
        preset.workDuration = 25 * 60
        preset.shortBreakDuration = 5 * 60
        preset.longBreakDuration = 15 * 60
        preset.rounds = 4
        preset.createdAt = Date()
        return preset
    }()
    
    static let exam: Preset = {
        let preset = Preset()
        preset.id = UUID()
        preset.name = "Exam"
        preset.workDuration = 50 * 60
        preset.shortBreakDuration = 10 * 60
        preset.longBreakDuration = 20 * 60
        preset.rounds = 2
        preset.createdAt = Date()
        return preset
    }()
    
    static let thesis: Preset = {
        let preset = Preset()
        preset.id = UUID()
        preset.name = "Thesis"
        preset.workDuration = 90 * 60
        preset.shortBreakDuration = 15 * 60
        preset.longBreakDuration = 30 * 60
        preset.rounds = 3
        preset.createdAt = Date()
        return preset
    }()
    
    static var allPresets: [Preset] {
        return [.pomodoro, .exam, .thesis]
    }
}

// MARK: - Task Extensions

extension Task {
    var taskDescription: String {
        get { "" } // Core Data Task не имеет description
        set { } // Игнорируем
    }
    
    var isCompleted: Bool {
        get { false } // Core Data Task не имеет isCompleted
        set { } // Игнорируем
    }
}

// MARK: - Session Extensions

extension Session {
    var startDate: Date {
        get { startedAt ?? Date() }
        set { startedAt = newValue }
    }
    
    var endDate: Date? {
        get { completedAt }
        set { completedAt = newValue }
    }
    
    var phase: SessionPhase {
        get { 
            if let phaseString = currentPhase {
                return SessionPhase(rawValue: phaseString) ?? .work
            }
            return .work
        }
        set { currentPhase = newValue.rawValue }
    }
    
    var presetId: UUID {
        get { UUID() } // Временное решение
        set { } // Игнорируем
    }
    
    var completed: Bool {
        get { isCompleted }
        set { isCompleted = newValue }
    }
}

// MARK: - SessionPhase Enum

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

// MARK: - TaskColor Enum

enum TaskColor: String, CaseIterable, Codable {
    case violet = "violet"
    case aqua = "aqua"
    case green = "green"
    case orange = "orange"
    case pink = "pink"
    case blue = "blue"
    
    var color: Color {
        switch self {
        case .violet:
            return Color.purple
        case .aqua:
            return Color.cyan
        case .green:
            return Color.green
        case .orange:
            return Color.orange
        case .pink:
            return Color.pink
        case .blue:
            return Color.blue
        }
    }
}
