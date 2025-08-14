import SwiftUI

struct FocusView: View {
    @StateObject private var timerViewModel = TimerViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Timer Display
                VStack {
                    Text(timerViewModel.timeString)
                        .font(.system(size: 70, weight: .thin, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text(timerViewModel.isRunning ? "Focusing..." : "Ready to Focus")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                // Progress Bar
                ProgressBarView(progress: timerViewModel.progress)
                    .frame(height: 8)
                    .padding(.horizontal, 40)
                
                // Timer Controls
                HStack(spacing: 30) {
                    Button(action: timerViewModel.resetTimer) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .disabled(timerViewModel.isRunning)
                    
                    Button(action: timerViewModel.toggleTimer) {
                        Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 80, height: 80)
                            .background(timerViewModel.isRunning ? Color.orange : Color.green)
                            .clipShape(Circle())
                    }
                    
                    Button(action: timerViewModel.skipTimer) {
                        Image(systemName: "forward.fill")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .disabled(timerViewModel.isRunning)
                }
                
                // Preset Switcher
                PresetSwitcherView(selectedPreset: $timerViewModel.selectedPreset)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Focus Timer")
        }
    }
}

#Preview {
    FocusView()
}
