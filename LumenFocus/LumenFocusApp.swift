import SwiftUI

@main
struct LumenFocusApp: App {
    let persistenceController = CoreDataManager.shared
    let notificationService = NotificationService.shared
    let cloudKitService = CloudKitService.shared
    let focusModeService = FocusModeService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(\.managedObjectContext, persistenceController.context)
                .onAppear {
                    setupServices()
                }
        }
    }
    
    private func setupServices() {
        // Setup notification categories
        notificationService.setupNotificationCategories()
        
        // Request notification permissions
        notificationService.requestPermission()
        
        // Check CloudKit status
        Task {
            await cloudKitService.checkForUpdates()
        }
        
        // Check Focus Mode status
        Task {
            await focusModeService.requestFocusModeAccess()
        }
    }
}
