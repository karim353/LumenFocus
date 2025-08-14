import SwiftUI

struct ProgressBarView: View {
    let progress: Double
    
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.surface.opacity(0.3))
                    .frame(height: 8)
                
                // Progress fill with neon effect
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 8)
                    .overlay(
                        // Neon glow effect
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors.opacity(0.6),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .blur(radius: 4)
                            .scaleEffect(isAnimating ? 1.05 : 1.0)
                            .opacity(isAnimating ? 0.8 : 1.0)
                    )
                    .shadow(
                        color: primaryColor.opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 0
                    )
                
                // Liquid segments for visual appeal
                HStack(spacing: 2) {
                    ForEach(0..<5, id: \.self) { segment in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: (geometry.size.width - 8) / 5, height: 6)
                            .opacity(segment < Int(progress * 5) ? 1.0 : 0.0)
                            .scaleEffect(segment < Int(progress * 5) ? 1.0 : 0.8)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(segment) * 0.1),
                                value: progress
                            )
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .frame(height: 8)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }
    
    private var gradientColors: [Color] {
        return [Color.accentPrimary, Color.accentSecondary]
    }
    
    private var primaryColor: Color {
        return Color.accentPrimary
    }
}

#Preview {
    VStack(spacing: 20) {
        ProgressBarView(progress: 0.3, phase: .work)
        ProgressBarView(progress: 0.7, phase: .shortBreak)
        ProgressBarView(progress: 0.9, phase: .longBreak)
    }
    .padding()
    .background(Color.background)
}
