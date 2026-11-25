import UIKit

enum CineTheme {
    static func background() -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(red: 0.05, green: 0.04, blue: 0.07, alpha: 1) : UIColor(red: 0.98, green: 0.97, blue: 0.97, alpha: 1)
        }
    }

    static func surface() -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(red: 0.12, green: 0.1, blue: 0.14, alpha: 1) : .white
        }
    }

    static func primaryText() -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? .white : UIColor(red: 0.1, green: 0.08, blue: 0.1, alpha: 1)
        }
    }

    static func secondaryText() -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor.white.withAlphaComponent(0.6) : UIColor.black.withAlphaComponent(0.55)
        }
    }

    static let accent = UIColor(red: 0.91, green: 0.19, blue: 0.32, alpha: 1)
    static let gold = UIColor(red: 0.99, green: 0.75, blue: 0.29, alpha: 1)

    static func font(_ size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        .systemFont(ofSize: size, weight: weight)
    }
}
