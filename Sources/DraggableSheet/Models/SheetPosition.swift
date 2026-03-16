import SwiftUI

// MARK: - SheetPosition

/// Represents a snap position for the draggable sheet.
///
/// Each position defines a height (absolute, percentage-based, or dynamically computed)
/// and a semantic name used for identity and comparison.
///
/// ```swift
/// // Built-in positions
/// let small: SheetPosition = .small   // 180pt
/// let medium: SheetPosition = .medium // 500pt
/// let large: SheetPosition = .large   // 80%
/// let full: SheetPosition = .full     // 100%
///
/// // Custom positions
/// let custom = SheetPosition(name: "compact", mode: .absolute(120))
/// let half = SheetPosition(name: "half", mode: .percentage(0.5))
/// ```
public struct SheetPosition: Sendable, Identifiable, Hashable {

    // MARK: - HeightMode

    /// Defines how the sheet height is calculated relative to the container.
    public enum HeightMode: Sendable {
        /// Fixed height in points, clamped to container height.
        case absolute(CGFloat)
        /// Fraction of container height (`0.0`–`1.0`), clamped.
        case percentage(CGFloat)
        /// Height returned by a closure evaluated at layout time.
        case dynamic(@Sendable () -> CGFloat)
    }

    // MARK: - Properties

    /// Stable identity string — used for `Identifiable`, `Hashable`, and `Equatable`.
    public let id: String

    /// Human-readable name (also used as `id`).
    public var name: String { id }

    /// How the height is resolved.
    public let mode: HeightMode

    // MARK: - Init

    /// Creates a sheet position with a semantic name and height mode.
    /// - Parameters:
    ///   - name: Unique name used for identity and equality checks.
    ///   - mode: How the sheet height is computed.
    public init(name: String, mode: HeightMode) {
        self.id = name
        self.mode = mode
    }

    // MARK: - Height Resolution

    /// Resolves the height in points for a given container height.
    public func height(in containerHeight: CGFloat) -> CGFloat {
        switch mode {
        case .absolute(let h):
            return min(h, containerHeight)
        case .percentage(let p):
            return min(containerHeight * p, containerHeight)
        case .dynamic(let calc):
            return min(calc(), containerHeight)
        }
    }

    // MARK: - Hashable / Equatable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SheetPosition, rhs: SheetPosition) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Convenience Statics

    /// 180pt fixed height.
    public static let small = SheetPosition(name: "small", mode: .absolute(180))
    /// 500pt fixed height.
    public static let medium = SheetPosition(name: "medium", mode: .absolute(500))
    /// 80% of container height.
    public static let large = SheetPosition(name: "large", mode: .percentage(0.8))
    /// 100% of container height.
    public static let full = SheetPosition(name: "full", mode: .percentage(1.0))

    /// Default set of positions: small, medium, full.
    public static let defaults: [SheetPosition] = [.small, .medium, .full]
}
