import SwiftUI

struct FocusView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    @State private var selectedPreset: Preset = .pomodoro
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Main Timer Card
                    TimerCardView(
                        timerViewModel: timerViewModel,
                        selectedPreset: selectedPreset
                    )
                    
                    // Preset Switcher
                    PresetSwitcherView(
                        selectedPreset: $selectedPreset
                    )
                    
                    // Recent Sessions Graph
                    RecentSessionsGraphView()
                    
                    // Action Buttons
                    HStack(spacing: 16) {
                        Button("Garden") {
                            // Navigate to Garden
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("Statistics") {
                            // Navigate to Statistics
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(24)
            }
            .background(Color.background)
            .navigationTitle("Focus")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    FocusView()
}
