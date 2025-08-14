import Foundation
import FocusState
import Intents
import IntentsUI

@MainActor
class FocusModeService: ObservableObject {
    static let shared = FocusModeService()
    
    @Published var currentFocusStatus: FocusStatus = .unknown
    @Published var availableFocusModes: [FocusMode] = []
    @Published var isFocusModeEnabled = false
    
    private let focusStateCenter = FocusStateCenter.shared
    private let notificationService = NotificationService.shared
    
    enum FocusStatus {
        case unknown
        case available
        case unavailable
        case restricted
    }
    
    struct FocusMode: Identifiable, Hashable {
        let id: String
        let name: String
        let icon: String
        let isActive: Bool
        let allowsNotifications: Bool
        let allowsCalls: Bool
        let allowsMessages: Bool
        let allowsApps: Bool
    }
    
    private init() {
        setupFocusModeMonitoring()
        loadAvailableFocusModes()
    }
    
    // MARK: - Focus Mode Monitoring
    
    private func setupFocusModeMonitoring() {
        // Monitor focus state changes
        focusStateCenter.addObserver(self) { [weak self] focusState in
            DispatchQueue.main.async {
                self?.handleFocusStateChange(focusState)
            }
        }
        
        // Check initial focus state
        checkCurrentFocusState()
    }
    
    private func handleFocusStateChange(_ focusState: FocusState) {
        isFocusModeEnabled = focusState.isFocused
        
        // Update available focus modes
        loadAvailableFocusModes()
        
        // Handle app-specific focus mode logic
        if isFocusModeEnabled {
            handleFocusModeActivated(focusState)
        } else {
            handleFocusModeDeactivated()
        }
    }
    
    private func checkCurrentFocusState() {
        Task {
            do {
                let focusState = try await focusStateCenter.requestAuthorization(for: .individual)
                await MainActor.run {
                    self.currentFocusStatus = focusState == .authorized ? .available : .restricted
                    self.isFocusModeEnabled = focusState == .authorized
                }
            } catch {
                await MainActor.run {
                    self.currentFocusStatus = .unavailable
                    self.isFocusModeEnabled = false
                }
            }
        }
    }
    
    // MARK: - Focus Mode Management
    
    func requestFocusModeAccess() async -> Bool {
        do {
            let status = try await focusStateCenter.requestAuthorization(for: .individual)
            await MainActor.run {
                self.currentFocusStatus = status == .authorized ? .available : .restricted
            }
            return status == .authorized
        } catch {
            await MainActor.run {
                self.currentFocusStatus = .unavailable
            }
            return false
        }
    }
    
    func activateFocusMode(for preset: Preset) async {
        guard currentFocusStatus == .available else { return }
        
        do {
            // Create focus mode intent
            let intent = INFocusStatusCenterIntent()
            intent.focusStatus = .focused
            
            // Set focus mode duration based on preset
            let totalDuration = TimeInterval(preset.workDuration * preset.rounds + preset.shortBreakDuration * (preset.rounds - 1) + preset.longBreakDuration)
            
            // Schedule focus mode deactivation
            let deactivationDate = Date().addingTimeInterval(totalDuration)
            
            // Set focus mode parameters
            intent.focusStatus = .focused
            intent.focusStatusDescription = "Lumen Focus Session - \(preset.name)"
            
            // Request focus mode activation
            try await focusStateCenter.requestAuthorization(for: .individual)
            
            // Schedule automatic deactivation
            scheduleFocusModeDeactivation(at: deactivationDate)
            
            // Update UI
            await MainActor.run {
                self.isFocusModeEnabled = true
            }
            
        } catch {
            print("Failed to activate focus mode: \(error)")
        }
    }
    
    func deactivateFocusMode() async {
        guard currentFocusStatus == .available else { return }
        
        do {
            // Create deactivation intent
            let intent = INFocusStatusCenterIntent()
            intent.focusStatus = .unfocused
            
            // Request focus mode deactivation
            try await focusStateCenter.requestAuthorization(for: .individual)
            
            // Update UI
            await MainActor.run {
                self.isFocusModeEnabled = false
            }
            
        } catch {
            print("Failed to deactivate focus mode: \(error)")
        }
    }
    
    // MARK: - Focus Mode Scheduling
    
    func scheduleFocusMode(at date: Date, duration: TimeInterval, preset: Preset) {
        // Schedule focus mode activation
        let activationDate = date
        let deactivationDate = activationDate.addingTimeInterval(duration)
        
        // Schedule activation notification
        notificationService.scheduleFocusModeReminder(at: activationDate)
        
        // Schedule automatic deactivation
        scheduleFocusModeDeactivation(at: deactivationDate)
        
        // Store focus mode schedule
        storeFocusModeSchedule(activationDate: activationDate, deactivationDate: deactivationDate, preset: preset)
    }
    
    private func scheduleFocusModeDeactivation(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete"
        content.body = "Time to take a break and reflect on your progress"
        content.sound = .default
        content.categoryIdentifier = "FOCUS_COMPLETE"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "focus-deactivation-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling focus deactivation: \(error)")
            }
        }
    }
    
    // MARK: - Focus Mode Integration
    
    private func handleFocusModeActivated(_ focusState: FocusState) {
        // Adjust app behavior when focus mode is active
        adjustAppBehaviorForFocusMode()
        
        // Schedule focus mode completion notification
        scheduleFocusModeCompletionNotification()
        
        // Update app appearance for focus mode
        updateAppAppearanceForFocusMode()
    }
    
    private func handleFocusModeDeactivated() {
        // Restore normal app behavior
        restoreNormalAppBehavior()
        
        // Update app appearance
        updateAppAppearanceForNormalMode()
    }
    
    private func adjustAppBehaviorForFocusMode() {
        // Reduce notification frequency
        notificationService.cancelAllNotifications()
        
        // Schedule only essential notifications
        scheduleEssentialNotifications()
        
        // Enable do not disturb mode for audio
        AudioService.shared.enableDoNotDisturb()
    }
    
    private func restoreNormalAppBehavior() {
        // Restore normal notification behavior
        notificationService.setupNotificationCategories()
        
        // Disable do not disturb mode
        AudioService.shared.disableDoNotDisturb()
    }
    
    private func scheduleEssentialNotifications() {
        // Only schedule critical notifications during focus mode
        // Such as session completion or emergency alerts
    }
    
    private func updateAppAppearanceForFocusMode() {
        // Update app appearance to be more minimal during focus mode
        // This could include reducing animations, changing color scheme, etc.
    }
    
    private func updateAppAppearanceForNormalMode() {
        // Restore normal app appearance
    }
    
    // MARK: - Focus Mode Analytics
    
    func trackFocusModeUsage(duration: TimeInterval, preset: Preset) {
        // Track how long focus mode was active
        // This can be used for analytics and insights
        
        let focusSession = FocusSession(
            startTime: Date(),
            duration: duration,
            preset: preset.name,
            wasCompleted: true
        )
        
        // Store focus session data
        storeFocusSession(focusSession)
    }
    
    // MARK: - Focus Mode Settings
    
    func updateFocusModeSettings() {
        // Update focus mode settings based on user preferences
        // This could include notification preferences, app restrictions, etc.
    }
    
    // MARK: - Helper Methods
    
    private func loadAvailableFocusModes() {
        // Load available focus modes from system
        // This would typically involve querying the system for available focus modes
        
        availableFocusModes = [
            FocusMode(id: "work", name: "Work", icon: "💼", isActive: false, allowsNotifications: false, allowsCalls: false, allowsMessages: false, allowsApps: true),
            FocusMode(id: "personal", name: "Personal", icon: "🏠", isActive: false, allowsNotifications: true, allowsCalls: true, allowsMessages: true, allowsApps: true),
            FocusMode(id: "sleep", name: "Sleep", icon: "😴", isActive: false, allowsNotifications: false, allowsCalls: false, allowsMessages: false, allowsApps: false)
        ]
    }
    
    private func storeFocusModeSchedule(activationDate: Date, deactivationDate: Date, preset: Preset) {
        // Store focus mode schedule in UserDefaults or Core Data
        let schedule = FocusModeSchedule(
            activationDate: activationDate,
            deactivationDate: deactivationDate,
            preset: preset.name,
            isActive: false
        )
        
        // Save to UserDefaults for now
        if let encoded = try? JSONEncoder().encode(schedule) {
            UserDefaults.standard.set(encoded, forKey: "focusModeSchedule")
        }
    }
    
    private func storeFocusSession(_ session: FocusSession) {
        // Store focus session data
        if let encoded = try? JSONEncoder().encode(session) {
            UserDefaults.standard.set(encoded, forKey: "focusSession-\(session.startTime.timeIntervalSince1970)")
        }
    }
    
    private func scheduleFocusModeCompletionNotification() {
        // Schedule notification for when focus mode should complete
        // This helps users stay on track with their focus sessions
    }
}

// MARK: - Data Models

struct FocusSession: Codable {
    let startTime: Date
    let duration: TimeInterval
    let preset: String
    let wasCompleted: Bool
}

struct FocusModeSchedule: Codable {
    let activationDate: Date
    let deactivationDate: Date
    let preset: String
    let isActive: Bool
}
