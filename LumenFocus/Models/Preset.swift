import Foundation

struct Preset: Identifiable, Codable {
    let id: UUID
    let name: String
    let workDuration: TimeInterval
    let shortBreakDuration: TimeInterval
    let longBreakDuration: TimeInterval
    let rounds: Int
    let autoSwitch: Bool
    
    init(
        id: UUID = UUID(),
        name: String,
        workDuration: TimeInterval,
        shortBreakDuration: TimeInterval,
        longBreakDuration: TimeInterval,
        rounds: Int,
        autoSwitch: Bool = true
    ) {
        self.id = id
        self.name = name
        self.workDuration = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration = longBreakDuration
        self.rounds = rounds
        self.autoSwitch = autoSwitch
    }
    
    // Default presets
    static let pomodoro = Preset(
        name: "Pomodoro",
        workDuration: 25 * 60,
        shortBreakDuration: 5 * 60,
        longBreakDuration: 15 * 60,
        rounds: 4
    )
    
    static let exam = Preset(
        name: "Exam",
        workDuration: 50 * 60,
        shortBreakDuration: 10 * 60,
        longBreakDuration: 20 * 60,
        rounds: 2
    )
    
    static let thesis = Preset(
        name: "Thesis",
        workDuration: 90 * 60,
        shortBreakDuration: 15 * 60,
        longBreakDuration: 30 * 60,
        rounds: 3
    )
    
    static let allPresets: [Preset] = [.pomodoro, .exam, .thesis]
}
