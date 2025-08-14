import Foundation
import UserNotifications
import CoreData

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    private let coreDataManager = CoreDataManager.shared
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func scheduleSessionNotification(
        title: String,
        body: String,
        timeInterval: TimeInterval,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func schedulePhaseNotification(
        phase: String,
        timeInterval: TimeInterval,
        identifier: String
    ) {
        let content = UNMutableNotificationContent()
        content.title = "Phase Complete"
        content.body = "Your \(phase) phase is complete!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling phase notification: \(error)")
            }
        }
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Smart Notification Scheduling
    
    func scheduleSmartNotifications(for session: Session) {
        guard let startedAt = session.startedAt else { return }
        
        // Schedule phase completion notifications
        schedulePhaseNotifications(for: session, startedAt: startedAt)
        
        // Schedule achievement notifications
        scheduleAchievementNotifications(for: session)
        
        // Schedule plant watering reminders
        schedulePlantWateringReminders()
    }
    
    private func schedulePhaseNotifications(for session: Session, startedAt: Date) {
        let preset = getPreset(for: session.presetName ?? "Pomodoro")
        let workDuration = preset.workDuration
        let shortBreakDuration = preset.shortBreakDuration
        let longBreakDuration = preset.longBreakDuration
        let rounds = Int(session.rounds)
        
        var currentTime = startedAt
        
        for round in 1...rounds {
            // Work phase notification
            let workEndTime = currentTime.addingTimeInterval(workDuration)
            schedulePhaseNotification(
                phase: "Work",
                at: workEndTime,
                identifier: "\(session.id?.uuidString ?? "")-work-\(round)"
            )
            currentTime = workEndTime
            
            // Short break notification (except after last round)
            if round < rounds {
                let shortBreakEndTime = currentTime.addingTimeInterval(shortBreakDuration)
                schedulePhaseNotification(
                    phase: "Short Break",
                    at: shortBreakEndTime,
                    identifier: "\(session.id?.uuidString ?? "")-short-\(round)"
                )
                currentTime = shortBreakEndTime
            }
        }
        
        // Long break notification after all rounds
        let longBreakEndTime = currentTime.addingTimeInterval(longBreakDuration)
        schedulePhaseNotification(
            phase: "Long Break",
            at: longBreakEndTime,
            identifier: "\(session.id?.uuidString ?? "")-long"
        )
    }
    
    private func schedulePhaseNotification(phase: String, at date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = "Phase Complete"
        content.body = "Your \(phase) phase is complete!"
        content.sound = .default
        content.categoryIdentifier = "PHASE_COMPLETE"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling phase notification: \(error)")
            }
        }
    }
    
    private func scheduleAchievementNotifications(for session: Session) {
        let totalSessions = coreDataManager.fetchSessions().count
        
        // First Focus achievement
        if totalSessions == 1 {
            scheduleAchievementNotification(
                title: "First Focus! 🎯",
                body: "Congratulations on your first focus session!",
                delay: 2.0
            )
        }
        
        // Deep Work achievement (sessions longer than 25 minutes)
        if session.duration > 1500 { // 25 minutes
            scheduleAchievementNotification(
                title: "Deep Work! 🧠",
                body: "You've completed a deep focus session!",
                delay: 2.0
            )
        }
        
        // Streak achievement (check daily usage)
        checkAndScheduleStreakAchievement()
    }
    
    private func scheduleAchievementNotification(title: String, body: String, delay: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "ACHIEVEMENT"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: "achievement-\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling achievement notification: \(error)")
            }
        }
    }
    
    private func checkAndScheduleStreakAchievement() {
        let sessions = coreDataManager.fetchSessions()
        let calendar = Calendar.current
        let today = Date()
        
        var currentStreak = 0
        var checkDate = today
        
        while true {
            let daySessions = sessions.filter { session in
                guard let startedAt = session.startedAt else { return false }
                return calendar.isDate(startedAt, inSameDayAs: checkDate)
            }
            
            if daySessions.isEmpty {
                break
            }
            
            currentStreak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? today
        }
        
        // Schedule streak achievements
        if currentStreak >= 3 {
            scheduleAchievementNotification(
                title: "Streak Master! 🔥",
                body: "You've been focusing for \(currentStreak) days in a row!",
                delay: 3.0
            )
        }
    }
    
    private func schedulePlantWateringReminders() {
        let plants = coreDataManager.fetchPlants()
        let lowWaterPlants = plants.filter { $0.waterLevel < 30 }
        
        for plant in lowWaterPlants {
            let content = UNMutableNotificationContent()
            content.title = "Plant Needs Water! 🌱"
            content.body = "Your \(plant.plantType ?? "plant") is thirsty. Give it some water!"
            content.sound = .default
            content.categoryIdentifier = "PLANT_CARE"
            
            // Schedule for 1 hour from now
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: false)
            let request = UNNotificationRequest(
                identifier: "plant-water-\(plant.id?.uuidString ?? "")",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling plant watering notification: \(error)")
                }
            }
        }
    }
    
    // MARK: - Focus Mode Integration
    
    func scheduleFocusModeReminder(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Time! 🎯"
        content.body = "Time to start your focus session"
        content.sound = .default
        content.categoryIdentifier = "FOCUS_REMINDER"
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "focus-reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling focus reminder: \(error)")
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getPreset(for name: String) -> Preset {
        switch name {
        case "Pomodoro":
            return Preset(name: "Pomodoro", workDuration: 1500, shortBreakDuration: 300, longBreakDuration: 900, rounds: 4, autoSwitch: true)
        case "Exam":
            return Preset(name: "Exam", workDuration: 3600, shortBreakDuration: 600, longBreakDuration: 1800, rounds: 2, autoSwitch: true)
        case "Thesis":
            return Preset(name: "Thesis", workDuration: 2700, shortBreakDuration: 900, longBreakDuration: 2700, rounds: 3, autoSwitch: true)
        default:
            return Preset(name: "Custom", workDuration: 1500, shortBreakDuration: 300, longBreakDuration: 900, rounds: 1, autoSwitch: true)
        }
    }
    
    // MARK: - Notification Categories
    
    func setupNotificationCategories() {
        let phaseCompleteCategory = UNNotificationCategory(
            identifier: "PHASE_COMPLETE",
            actions: [
                UNNotificationAction(identifier: "CONTINUE", title: "Continue", options: [.foreground]),
                UNNotificationAction(identifier: "PAUSE", title: "Pause", options: [.foreground])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let achievementCategory = UNNotificationCategory(
            identifier: "ACHIEVEMENT",
            actions: [
                UNNotificationAction(identifier: "VIEW", title: "View Achievement", options: [.foreground])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let plantCareCategory = UNNotificationCategory(
            identifier: "PLANT_CARE",
            actions: [
                UNNotificationAction(identifier: "WATER", title: "Water Plant", options: [.foreground]),
                UNNotificationAction(identifier: "VIEW_GARDEN", title: "View Garden", options: [.foreground])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let focusReminderCategory = UNNotificationCategory(
            identifier: "FOCUS_REMINDER",
            actions: [
                UNNotificationAction(identifier: "START", title: "Start Focus", options: [.foreground]),
                UNNotificationAction(identifier: "SNOOZE", title: "Snooze 5 min", options: [.foreground])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            phaseCompleteCategory,
            achievementCategory,
            plantCareCategory,
            focusReminderCategory
        ])
    }
}
