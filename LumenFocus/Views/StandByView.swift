import SwiftUI

struct StandByView: View {
    @ObservedObject var timerViewModel: TimerViewModel
    @State private var isMinimal = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color.background, Color.surface],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isMinimal {
                    minimalView
                } else {
                    expandedView
                }
            }
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isMinimal.toggle()
                }
            }
        }
    }
    
    private var minimalView: some View {
        VStack(spacing: 20) {
            // App icon and name
            VStack(spacing: 12) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)
                
                Text("Lumen Focus")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            // Current time
            Text(Date(), style: .time)
                .font(.system(size: 36, weight: .light, design: .rounded))
                .foregroundColor(.primary)
            
            // Date
            Text(Date(), style: .date)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private var expandedView: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 8) {
                Text("Lumen Focus")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Красиво концентрируйся")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Timer status
            if timerViewModel.isRunning {
                VStack(spacing: 16) {
                    // Current phase
                    Text(timerViewModel.currentPhase.rawValue)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                    
                    // Time remaining
                    Text(formatTime(timerViewModel.timeRemaining))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    // Progress indicator
                    ProgressView(value: Double(timerViewModel.currentRound), total: Double(timerViewModel.totalRounds))
                        .progressViewStyle(LinearProgressViewStyle(tint: .accentColor))
                        .scaleEffect(1.2)
                    
                    // Round info
                    Text("Round \(timerViewModel.currentRound) of \(timerViewModel.totalRounds)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "timer.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.accentColor)
                    
                    Text("Timer not running")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Open the app to start focusing")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Current time
            VStack(spacing: 8) {
                Text(Date(), style: .time)
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 20)
    }
    
    private func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    StandByView(timerViewModel: TimerViewModel())
}
