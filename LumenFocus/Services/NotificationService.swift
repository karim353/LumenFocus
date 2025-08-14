import UserNotifications
import Foundation

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
            }
            
            if let error = error {
                print("Error requesting notification permission: \(error)")
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    func setupNotificationCategories() {
        let focusCompleteAction = UNNotificationAction(
            identifier: "FOCUS_COMPLETE",
            title: "Complete",
            options: [.foreground]
        )
        
        let breakStartAction = UNNotificationAction(
            identifier: "BREAK_START",
            title: "Start Break",
            options: [.foreground]
        )
        
        let focusCategory = UNNotificationCategory(
            identifier: "FOCUS_SESSION",
            actions: [focusCompleteAction, breakStartAction],
            intentIdentifiers: [],
            options: []
        )
        
        let breakCategory = UNNotificationCategory(
            identifier: "BREAK_SESSION",
            actions: [],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([focusCategory, breakCategory])
    }
    
    func scheduleFocusCompleteNotification(in timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎯"
        content.body = "Great job! Time to take a break."
        content.sound = .default
        content.categoryIdentifier = "FOCUS_SESSION"
        content.userInfo = ["type": "focus_complete"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "focus_complete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling focus complete notification: \(error)")
            }
        }
    }
    
    func scheduleBreakStartNotification(in timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Break Time! ☕️"
        content.body = "Your break is starting now."
        content.sound = .default
        content.categoryIdentifier = "BREAK_SESSION"
        content.userInfo = ["type": "break_start"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "break_start", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break start notification: \(error)")
            }
        }
    }
    
    func scheduleBreakCompleteNotification(in timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Break Complete! 🚀"
        content.body = "Ready for your next focus session?"
        content.sound = .default
        content.userInfo = ["type": "break_complete"]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: "break_complete", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling break complete notification: \(error)")
            }
        }
    }
    
    func scheduleDailyReminder(at hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Time to Focus! 🎯"
        content.body = "Don't forget to schedule your focus sessions today."
        content.sound = .default
        content.userInfo = ["type": "daily_reminder"]
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            completion(requests)
        }
    }
}
