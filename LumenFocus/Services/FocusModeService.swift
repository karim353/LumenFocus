import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

class FocusModeService: ObservableObject {
    static let shared = FocusModeService()
    
    @Published var currentFocusStatus: FocusStatus = .unavailable
    @Published var isFocusModeEnabled = false
    @Published var availableFocusModes: [FocusMode] = []
    
    private let store = ManagedSettingsStore()
    private let center = AuthorizationCenter.shared
    
    enum FocusStatus {
        case available
        case unavailable
        case denied
        case restricted
    }
    
    struct FocusMode: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        var isActive: Bool
    }
    
    private init() {
        checkAuthorizationStatus()
        loadAvailableFocusModes()
    }
    
    func requestFocusModeAccess() async {
        do {
            let status = try await center.requestAuthorization(for: .individual)
            
            await MainActor.run {
                switch status {
                case .approved:
                    currentFocusStatus = .available
                case .denied:
                    currentFocusStatus = .denied
                case .notDetermined:
                    currentFocusStatus = .unavailable
                @unknown default:
                    currentFocusStatus = .unavailable
                }
            }
        } catch {
            print("Error requesting Focus Mode access: \(error)")
            await MainActor.run {
                currentFocusStatus = .unavailable
            }
        }
    }
    
    func checkAuthorizationStatus() {
        Task {
            let status = await center.authorizationStatus
            
            await MainActor.run {
                switch status {
                case .approved:
                    currentFocusStatus = .available
                case .denied:
                    currentFocusStatus = .denied
                case .notDetermined:
                    currentFocusStatus = .unavailable
                case .restricted:
                    currentFocusStatus = .restricted
                @unknown default:
                    currentFocusStatus = .unavailable
                }
            }
        }
    }
    
    func activateFocusMode() async {
        guard currentFocusStatus == .available else { return }
        
        do {
            // Create a focus mode configuration
            let configuration = FocusModeConfiguration()
            
            // Apply the configuration
            try await applyFocusModeConfiguration(configuration)
            
            await MainActor.run {
                isFocusModeEnabled = true
            }
        } catch {
            print("Error activating Focus Mode: \(error)")
        }
    }
    
    func deactivateFocusMode() async {
        do {
            // Remove focus mode restrictions
            store.shield.applications = .none()
            store.shield.applicationCategories = .none()
            store.shield.webContent = .none()
            
            await MainActor.run {
                isFocusModeEnabled = false
            }
        } catch {
            print("Error deactivating Focus Mode: \(error)")
        }
    }
    
    private func applyFocusModeConfiguration(_ configuration: FocusModeConfiguration) async throws {
        // Apply application restrictions
        if configuration.blockSocialMedia {
            store.shield.applicationCategories = .all()
        }
        
        // Apply web content restrictions
        if configuration.blockDistractingWebsites {
            store.shield.webContent = .all()
        }
        
        // Apply notification restrictions
        if configuration.blockNotifications {
            // Note: This requires additional permissions and setup
            print("Notification blocking requires additional setup")
        }
    }
    
    private func loadAvailableFocusModes() {
        availableFocusModes = [
            FocusMode(name: "Deep Work", icon: "brain.head.profile", isActive: false),
            FocusMode(name: "Study", icon: "book", isActive: false),
            FocusMode(name: "Creative", icon: "paintbrush", isActive: false),
            FocusMode(name: "Exercise", icon: "figure.run", isActive: false)
        ]
    }
    
    func toggleFocusMode(_ mode: FocusMode) {
        guard let index = availableFocusModes.firstIndex(where: { $0.id == mode.id }) else { return }
        
        if availableFocusModes[index].isActive {
            Task {
                await deactivateFocusMode()
            }
        } else {
            Task {
                await activateFocusMode()
            }
        }
        
        availableFocusModes[index].isActive.toggle()
    }
    
    func scheduleFocusMode(startTime: Date, endTime: Date, mode: FocusMode) async {
        guard currentFocusStatus == .available else { return }
        
        do {
            // Create a scheduled focus mode
            let schedule = DeviceActivitySchedule(
                intervalStart: DateComponents(hour: Calendar.current.component(.hour, from: startTime),
                                           minute: Calendar.current.component(.minute, from: startTime)),
                intervalEnd: DateComponents(hour: Calendar.current.component(.hour, from: endTime),
                                         minute: Calendar.current.component(.minute, from: endTime)),
                repeats: true
            )
            
            // Apply the schedule
            try await applyScheduledFocusMode(schedule, mode: mode)
            
        } catch {
            print("Error scheduling Focus Mode: \(error)")
        }
    }
    
    private func applyScheduledFocusMode(_ schedule: DeviceActivitySchedule, mode: FocusMode) async throws {
        // This would implement the logic to apply scheduled focus modes
        // For now, just log the schedule
        print("Scheduled Focus Mode '\(mode.name)' from \(schedule.intervalStart) to \(schedule.intervalEnd)")
    }
}

// MARK: - Focus Mode Configuration

struct FocusModeConfiguration {
    var blockSocialMedia: Bool = true
    var blockDistractingWebsites: Bool = true
    var blockNotifications: Bool = false
    var allowCalls: Bool = true
    var allowMessages: Bool = false
    
    static let deepWork = FocusModeConfiguration(
        blockSocialMedia: true,
        blockDistractingWebsites: true,
        blockNotifications: true,
        allowCalls: false,
        allowMessages: false
    )
    
    static let study = FocusModeConfiguration(
        blockSocialMedia: true,
        blockDistractingWebsites: true,
        blockNotifications: false,
        allowCalls: true,
        allowMessages: false
    )
    
    static let creative = FocusModeConfiguration(
        blockSocialMedia: false,
        blockDistractingWebsites: false,
        blockNotifications: true,
        allowCalls: false,
        allowMessages: false
    )
}
