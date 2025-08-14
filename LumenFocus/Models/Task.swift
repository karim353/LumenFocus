import Foundation
import SwiftUI

struct Task: Identifiable, Codable {
    let id: UUID
    let title: String
    let color: TaskColor
    let icon: String
    let tags: [String]
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        color: TaskColor = .violet,
        icon: String = "book",
        tags: [String] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.color = color
        self.icon = icon
        self.tags = tags
        self.createdAt = createdAt
    }
}

enum TaskColor: String, CaseIterable, Codable {
    case violet = "violet"
    case aqua = "aqua"
    case green = "green"
    case orange = "orange"
    case pink = "pink"
    case blue = "blue"
    
    var color: Color {
        switch self {
        case .violet:
            return Color.accentPrimary
        case .aqua:
            return Color.accentSecondary
        case .green:
            return Color.success
        case .orange:
            return Color.warning
        case .pink:
            return Color.pink
        case .blue:
            return Color.blue
        }
    }
}
