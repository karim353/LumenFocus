import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let background = Color(red: 0.043, green: 0.059, blue: 0.078) // #0B0F14
    static let backgroundSecondary = Color(red: 0.059, green: 0.086, blue: 0.133) // #0F1622
    
    // MARK: - Surface Colors
    static let surface = Color.white.opacity(0.1) // 8-12% white + blur
    
    // MARK: - Accent Colors
    static let accentPrimary = Color(red: 0.651, green: 0.424, blue: 1.0) // #A66CFF
    static let accentPrimaryDark = Color(red: 0.486, green: 0.302, blue: 1.0) // #7C4DFF
    
    static let accentSecondary = Color(red: 0.0, green: 0.898, blue: 1.0) // #00E5FF
    static let accentSecondaryDark = Color(red: 0.133, green: 0.827, blue: 0.933) // #22D3EE
    
    // MARK: - Status Colors
    static let success = Color(red: 0.133, green: 0.773, blue: 0.369) // #22C55E
    static let warning = Color(red: 0.961, green: 0.620, blue: 0.043) // #F59E0B
    static let danger = Color(red: 0.957, green: 0.247, blue: 0.369) // #F43F5E
    
    // MARK: - Gradient Colors
    static let gradientStart = accentPrimary
    static let gradientEnd = accentSecondary
    
    // MARK: - Glassmorphism Colors
    static let glassBackground = Color.white.opacity(0.08)
    static let glassBorder = Color.white.opacity(0.12)
    
    // MARK: - Neon Glow Colors
    static let neonGlow = accentPrimary.opacity(0.3)
    static let neonGlowSecondary = accentSecondary.opacity(0.3)
}

// MARK: - Color Schemes

extension ColorScheme {
    var isDark: Bool {
        self == .dark
    }
}

// MARK: - Dynamic Colors

extension Color {
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .light:
                return UIColor(light)
            case .dark:
                return UIColor(dark)
            case .unspecified:
                return UIColor(dark)
            @unknown default:
                return UIColor(dark)
            }
        })
    }
}

// MARK: - Opacity Variants

extension Color {
    func opacity(_ opacity: Double) -> Color {
        self.opacity(opacity)
    }
    
    var light: Color {
        self.opacity(0.3)
    }
    
    var medium: Color {
        self.opacity(0.6)
    }
    
    var dark: Color {
        self.opacity(0.8)
    }
}

// MARK: - Semantic Colors

extension Color {
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color.secondary.opacity(0.6)
    
    static let primaryBackground = Color.background
    static let secondaryBackground = Color.backgroundSecondary
    static let tertiaryBackground = Color.surface
    
    static let primaryAccent = Color.accentPrimary
    static let secondaryAccent = Color.accentSecondary
    static let tertiaryAccent = Color.accentPrimary.opacity(0.7)
}
