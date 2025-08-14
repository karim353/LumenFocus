import SwiftUI

struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("darkModeEnabled") private var darkModeEnabled = true
    @AppStorage("autoStartBreaks") private var autoStartBreaks = false
    @AppStorage("focusModeEnabled") private var focusModeEnabled = true
    
    var body: some View {
        NavigationView {
            List {
                Section("Timer Settings") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Auto-start Breaks", isOn: $autoStartBreaks)
                    Toggle("Focus Mode Integration", isOn: $focusModeEnabled)
                }
                
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $darkModeEnabled)
                }
                
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    
                    if notificationsEnabled {
                        NavigationLink("Notification Preferences") {
                            NotificationPreferencesView()
                        }
                    }
                }
                
                Section("Data & Privacy") {
                    NavigationLink("Export Data") {
                        ExportDataView()
                    }
                    
                    NavigationLink("Privacy Policy") {
                        PrivacyPolicyView()
                    }
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink("Terms of Service") {
                        TermsOfServiceView()
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct NotificationPreferencesView: View {
    var body: some View {
        List {
            Section("Session Notifications") {
                Toggle("Session Complete", isOn: .constant(true))
                Toggle("Break Reminders", isOn: .constant(true))
                Toggle("Daily Goals", isOn: .constant(true))
            }
            
            Section("Sound & Haptics") {
                Toggle("Vibration", isOn: .constant(true))
                Toggle("Sound Alerts", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
    }
}

struct ExportDataView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Your Data")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Download all your focus sessions, tasks, and statistics in CSV format.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Export CSV") {
                // TODO: Implement export functionality
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Export Data")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Your privacy is important to us. This app does not collect personal information and all data is stored locally on your device.")
                    .font(.body)
                
                Text("Data Storage")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("• All focus sessions are stored locally\n• No data is transmitted to external servers\n• You can export your data at any time")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("By using this app, you agree to these terms of service.")
                    .font(.body)
                
                Text("Usage")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("• Use the app responsibly\n• Respect your device's focus mode settings\n• Export your data before uninstalling")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

#Preview {
    SettingsView()
}
