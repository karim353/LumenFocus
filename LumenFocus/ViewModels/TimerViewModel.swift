import Foundation
import Combine
import CoreHaptics
import CoreData

@MainActor
class TimerViewModel: ObservableObject {
    @Published var currentPhase: SessionPhase = .work
    @Published var timeRemaining: TimeInterval = 0
    @Published var isRunning = false
    @Published var currentRound = 1
    @Published var totalRounds = 4
    @Published var selectedTask: Task?
    
    private var timer: Timer?
    private var startDate: Date?
    private var pauseOffset: TimeInterval = 0
    private var currentPreset: Preset = .pomodoro
    private var engine: CHHapticEngine?
    private var sessionStartDate: Date?
    
    private let coreDataManager = CoreDataManager.shared
    private let liveActivityManager = LiveActivityManager.shared
    private let notificationService = NotificationService.shared
    private let focusModeService = FocusModeService.shared
    
    init() {
        setupHaptics()
        resetTimer()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        startDate = Date()
        sessionStartDate = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimer()
        }
        
        // Start Live Activity
        liveActivityManager.startLiveActivity(
            taskName: selectedTask?.title ?? "Focus Session",
            presetName: currentPreset.name,
            timeRemaining: timeRemaining,
            currentPhase: currentPhase.rawValue,
            currentRound: currentRound,
            totalRounds: totalRounds
        )
        
        // Activate Focus Mode if enabled
        Task {
            await focusModeService.activateFocusMode(for: currentPreset)
        }
        
        // Setup smart notifications
        setupSmartNotifications()
        
        triggerHaptic(.success)
    }
    
    func pauseTimer() {
        guard isRunning else { return }
        
        isRunning = false
        pauseOffset = timeRemaining
        timer?.invalidate()
        timer = nil
        
        // Pause Live Activity
        liveActivityManager.pauseLiveActivity()
        
        triggerHaptic(.medium)
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // Stop Live Activity
        liveActivityManager.stopLiveActivity()
        
        resetTimer()
        
        triggerHaptic(.light)
    }
    
    func addFiveMinutes() {
        timeRemaining += 5 * 60
        triggerHaptic(.light)
    }
    
    func skipPhase() {
        switch currentPhase {
        case .work:
            if currentRound % 4 == 0 {
                currentPhase = .longBreak
            } else {
                currentPhase = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
            if currentPhase == .shortBreak || currentPhase == .longBreak {
                currentRound += 1
            }
        case .paused:
            break
        }
        
        resetTimer()
        triggerHaptic(.medium)
    }
    
    // MARK: - Private Methods
    
    private func updateTimer() {
        guard timeRemaining > 0 else {
            completePhase()
            return
        }
        
        timeRemaining -= 1
        
        // Update Live Activity
        liveActivityManager.updateLiveActivity(
            timeRemaining: timeRemaining,
            currentPhase: currentPhase.rawValue,
            currentRound: currentRound,
            totalRounds: totalRounds,
            isRunning: isRunning
        )
        
        // Pulse every 60 seconds
        if Int(timeRemaining) % 60 == 0 {
            triggerHaptic(.light)
        }
    }
    
    private func completePhase() {
        switch currentPhase {
        case .work:
            if currentRound % 4 == 0 {
                currentPhase = .longBreak
                timeRemaining = currentPreset.longBreakDuration
            } else {
                currentPhase = .shortBreak
                timeRemaining = currentPreset.shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentPhase = .work
            currentRound += 1
            timeRemaining = currentPreset.workDuration
            
            if currentRound > totalRounds {
                completeSession()
                return
            }
        case .paused:
            break
        }
        
        triggerHaptic(.success)
    }
    
    private func completeSession() {
        // Save session to Core Data
        if let startDate = sessionStartDate {
            let duration = Date().timeIntervalSince(startDate)
            let session = coreDataManager.createSession(
                startedAt: startDate,
                completedAt: Date(),
                duration: duration,
                currentPhase: currentPhase.rawValue,
                presetName: currentPreset.name,
                rounds: Int16(currentRound),
                isCompleted: true,
                task: selectedTask
            )
            
            // Update garden based on session completion
            updateGardenAfterSession(session)
        }
        
        stopTimer()
    }
    
    private func updateGardenAfterSession(_ session: Session) {
        // Create a new plant or grow existing ones based on session completion
        let plantTypes = ["neon-sprout", "glow-fern", "crystal-bloom", "quantum-vine", "stellar-bud"]
        let randomPlantType = plantTypes.randomElement() ?? "neon-sprout"
        
        let plant = coreDataManager.createPlant(plantType: randomPlantType)
        
        // Water and grow the plant
        coreDataManager.waterPlant(plant)
        coreDataManager.growPlant(plant)
    }
    
    private func resetTimer() {
        switch currentPhase {
        case .work:
            timeRemaining = currentPreset.workDuration
        case .shortBreak:
            timeRemaining = currentPreset.shortBreakDuration
        case .longBreak:
            timeRemaining = currentPreset.longBreakDuration
        case .paused:
            break
        }
    }
    
    func setPreset(_ preset: Preset) {
        currentPreset = preset
        totalRounds = preset.rounds
        currentRound = 1
        currentPhase = .work
        resetTimer()
    }
    
    // MARK: - Haptics
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    private func triggerHaptic(_ intensity: CHHapticEvent.Intensity) {
        guard let engine = engine else { return }
        
        let event = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(intensity.rawValue))],
            relativeTime: 0
        )
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
    
    // MARK: - Smart Notifications
    
    private func setupSmartNotifications() {
        guard let sessionStartDate = sessionStartDate else { return }
        
        // Create a temporary session for notification scheduling
        let tempSession = coreDataManager.createSession(
            startedAt: sessionStartDate,
            completedAt: nil,
            duration: 0,
            currentPhase: currentPhase.rawValue,
            presetName: currentPreset.name,
            rounds: Int16(totalRounds),
            isCompleted: false,
            task: selectedTask
        )
        
        // Schedule smart notifications
        notificationService.scheduleSmartNotifications(for: tempSession)
    }
    
    // MARK: - Focus Mode Integration
    
    func deactivateFocusMode() async {
        await focusModeService.deactivateFocusMode()
    }
}

// MARK: - Haptic Intensity Extensions

extension CHHapticEvent.Intensity {
    static let light = CHHapticEvent.Intensity(0.3)
    static let medium = CHHapticEvent.Intensity(0.6)
    static let success = CHHapticEvent.Intensity(0.8)
}
