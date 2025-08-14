import SwiftUI

struct PresetSwitcherView: View {
    @Binding var selectedPreset: Preset
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Presets")
                .font(.headline)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(Preset.allPresets, id: \.id) { preset in
                        PresetCardView(
                            preset: preset,
                            isSelected: preset.id == selectedPreset.id
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                selectedPreset = preset
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

struct PresetCardView: View {
    let preset: Preset
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(isSelected ? .white : .primary)
                        
                        Text("\(Int(preset.workDuration / 60)) min work")
                            .font(.caption)
                            .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(preset.rounds) rounds")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                }
                
                // Progress indicator
                HStack(spacing: 4) {
                    ForEach(0..<preset.rounds, id: \.self) { round in
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.3) : Color(.systemGray6))
                            .frame(width: 6, height: 6)
                    }
                }
            }
            .padding(16)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isSelected ? 
                        LinearGradient(
                            colors: [Color.accentPrimary, Color.accentSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        Color(.systemGray6)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ? Color.clear : Color(.systemGray6).opacity(0.3),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: isSelected ? Color.accentPrimary.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isSelected)
    }
}

#Preview {
    PresetSwitcherView(selectedPreset: .constant(.pomodoro))
        .background(Color(.systemBackground))
        .padding()
}
