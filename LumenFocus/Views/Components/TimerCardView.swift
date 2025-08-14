import SwiftUI

struct TimerCardView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    let selectedPreset: Preset
    
    var body: some View {
        VStack(spacing: 24) {
            // Phase indicator
            HStack {
                Image(systemName: timerViewModel.currentPhase.icon)
                    .font(.title2)
                    .foregroundColor(.accentPrimary)
                
                Text(timerViewModel.currentPhase.displayName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Round indicator
                HStack(spacing: 8) {
                    ForEach(1...timerViewModel.totalRounds, id: \.self) { round in
                        Circle()
                            .fill(round <= timerViewModel.currentRound ? Color.accentPrimary : Color.surface)
                            .frame(width: 8, height: 8)
                    }
                }
            }
            
            // Timer display
            VStack(spacing: 16) {
                Text(timeString)
                    .font(.system(size: 64, weight: .light, design: .monospaced))
                    .foregroundColor(.primary)
                    .contentTransition(.numericText())
                
                // Progress bar
                ProgressBarView(
                    progress: progress,
                    phase: timerViewModel.currentPhase
                )
            }
            
            // Control buttons
            HStack(spacing: 16) {
                Button(action: {
                    if timerViewModel.isRunning {
                        timerViewModel.pauseTimer()
                    } else {
                        timerViewModel.startTimer()
                    }
                }) {
                    HStack {
                        Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        Text(timerViewModel.isRunning ? "Pause" : "Start")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentPrimary)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
                
                Button("Skip") {
                    timerViewModel.skipPhase()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surface)
                .foregroundColor(.primary)
                .cornerRadius(20)
            }
            
            // Additional controls
            HStack(spacing: 16) {
                Button("+5 min") {
                    timerViewModel.addFiveMinutes()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.surface)
                .foregroundColor(.primary)
                .cornerRadius(16)
                
                Button("Stop") {
                    timerViewModel.stopTimer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.surface)
                .foregroundColor(.primary)
                .cornerRadius(16)
            }
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.accentPrimary.opacity(0.3), Color.accentSecondary.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.accentPrimary.opacity(0.1), radius: 20, x: 0, y: 10)
    }
    
    private var timeString: String {
        let minutes = Int(timerViewModel.timeRemaining) / 60
        let seconds = Int(timerViewModel.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: Double {
        let totalTime: TimeInterval
        switch timerViewModel.currentPhase {
        case .work:
            totalTime = selectedPreset.workDuration
        case .shortBreak:
            totalTime = selectedPreset.shortBreakDuration
        case .longBreak:
            totalTime = selectedPreset.longBreakDuration
        case .paused:
            totalTime = 1
        }
        
        return 1.0 - (timerViewModel.timeRemaining / totalTime)
    }
}

#Preview {
    TimerCardView(
        timerViewModel: TimerViewModel(),
        selectedPreset: .pomodoro
    )
    .background(Color.background)
    .padding()
}
