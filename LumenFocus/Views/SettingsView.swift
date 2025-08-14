import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true
    @AppStorage("autoSwitch") private var autoSwitch = true
    @AppStorage("antiMistapDelay") private var antiMistapDelay = 0.3
    @AppStorage("theme") private var theme = "auto"
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("focusModeIntegration") private var focusModeIntegration = true
    @AppStorage("dontInterruptMusic") private var dontInterruptMusic = true
    @AppStorage("soundVolume") private var soundVolume = 0.7
    
    @StateObject private var cloudKitService = CloudKitService.shared
    @StateObject private var focusModeService = FocusModeService.shared
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    var body: some View {
        NavigationView {
            List {
                // Timer Settings
                Section("Timer") {
                    Toggle("Auto-switch phases", isOn: $autoSwitch)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Anti-mistap delay")
                        Text("\(Int(antiMistapDelay * 1000))ms")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: $antiMistapDelay, in: 0.1...1.0, step: 0.1)
                    }
                }
                
                // Notifications
                Section("Notifications") {
                    Toggle("Enable notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        Toggle("Focus mode integration", isOn: $focusModeIntegration)
                        Toggle("Don't interrupt music", isOn: $dontInterruptMusic)
                        
                        // Smart notification settings
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Smart scheduling")
                                .font(.headline)
                            Text("Automatically schedule notifications based on your focus patterns")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Audio & Haptics
                Section("Audio & Haptics") {
                    Toggle("Sound effects", isOn: $soundEnabled)
                    Toggle("Haptic feedback", isOn: $hapticsEnabled)
                    
                    if soundEnabled {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Sound volume")
                            HStack {
                                Image(systemName: "speaker.fill")
                                Slider(value: $soundVolume, in: 0...1)
                                Image(systemName: "speaker.wave.3.fill")
                            }
                        }
                    }
                }
                
                // Appearance
                Section("Appearance") {
                    Picker("Theme", selection: $theme) {
                        Text("Auto").tag("auto")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.segmented)
                }
                
                // CloudKit & Sync
                Section("CloudKit & Sync") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("iCloud Status")
                                .font(.headline)
                            Text(cloudKitService.isSignedInToiCloud ? "Connected" : "Not Connected")
                                .font(.caption)
                                .foregroundColor(cloudKitService.isSignedInToiCloud ? .green : .red)
                        }
                        Spacer()
                        
                        if cloudKitService.isSignedInToiCloud {
                            Button("Sync Now") {
                                Task {
                                    await cloudKitService.manualSync()
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(cloudKitService.syncStatus == .syncing)
                        }
                    }
                    
                    if cloudKitService.isSignedInToiCloud {
                        HStack {
                            Text("Last Sync")
                            Spacer()
                            if let lastSync = cloudKitService.lastSyncDate {
                                Text(lastSync, style: .relative)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Never")
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        HStack {
                            Text("Sync Status")
                            Spacer()
                            switch cloudKitService.syncStatus {
                            case .idle:
                                Text("Idle")
                                    .foregroundColor(.secondary)
                            case .syncing:
                                HStack {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                    Text("Syncing...")
                                        .foregroundColor(.secondary)
                                }
                            case .completed:
                                Text("Completed")
                                    .foregroundColor(.green)
                            case .failed(let error):
                                Text("Failed")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Focus Mode
                Section("Focus Mode") {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Focus Mode Status")
                                .font(.headline)
                            Text(focusModeService.isFocusModeEnabled ? "Active" : "Inactive")
                                .font(.caption)
                                .foregroundColor(focusModeService.isFocusModeEnabled ? .green : .orange)
                        }
                        Spacer()
                        
                        if focusModeService.currentFocusStatus == .available {
                            Button(focusModeService.isFocusModeEnabled ? "Deactivate" : "Activate") {
                                Task {
                                    if focusModeService.isFocusModeEnabled {
                                        await focusModeService.deactivateFocusMode()
                                    } else {
                                        await focusModeService.requestFocusModeAccess()
                                    }
                                }
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Request Access") {
                                Task {
                                    await focusModeService.requestFocusModeAccess()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    if focusModeService.currentFocusStatus == .available {
                        ForEach(focusModeService.availableFocusModes) { mode in
                            HStack {
                                Text(mode.icon)
                                Text(mode.name)
                                Spacer()
                                if mode.isActive {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                }
                            }
                        }
                    }
                }
                
                // Data & Privacy
                Section("Data & Privacy") {
                    Button("Export data") {
                        exportData()
                    }
                    
                    Button("Backup to iCloud") {
                        backupToICloud()
                    }
                    
                    Button("Privacy Policy") {
                        openPrivacyPolicy()
                    }
                }
                
                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button("Rate App") {
                        rateApp()
                    }
                    
                    Button("Send Feedback") {
                        sendFeedback()
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func exportData() {
        let sessions = CoreDataManager.shared.fetchSessions()
        let tasks = CoreDataManager.shared.fetchTasks()
        
        var csvContent = "Date,Task,Phase,Duration,Completed\n"
        
        for session in sessions {
            let date = session.startedAt ?? Date()
            let taskName = session.task?.title ?? "No Task"
            let phase = session.currentPhase ?? "Unknown"
            let duration = session.duration / 60 // Convert to minutes
            let completed = session.isCompleted ? "Yes" : "No"
            
            csvContent += "\(date),\(taskName),\(phase),\(duration),\(completed)\n"
        }
        
        // In a real app, you would save this to a file and share it
        print("CSV Export:\n\(csvContent)")
    }
    
    private func backupToICloud() {
        Task {
            await cloudKitService.syncToCloud()
        }
    }
    
    private func openPrivacyPolicy() {
        // In a real app, this would open a privacy policy document or web page
        print("Privacy policy would open here")
    }
    
    private func rateApp() {
        // In a real app, this would open the App Store rating page
        print("App Store rating would open here")
    }
    
    private func sendFeedback() {
        // In a real app, this would open a feedback form or email
        print("Feedback form would open here")
    }
}

#Preview {
    SettingsView()
}
